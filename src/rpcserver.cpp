#include "rpcserver.h"

#include "base58.h"
#include "init.h"
#include "main.h"
#include "ui_interface.h"
#include "util.h"
#ifdef ENABLE_WALLET
#include "wallet.h"
#endif

#include <boost/algorithm/string.hpp>
#include <boost/asio.hpp>
#include <boost/asio/socket_base.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/bind/bind.hpp>
#include <boost/filesystem.hpp>
#include <boost/foreach.hpp>
#include <boost/iostreams/concepts.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>

#include "json/json_spirit_writer_template.h"
#include "rpcprotocol.h"
#include "rpcserver.h"
#include "univalue/univalue.h"
#include <memory>

using namespace boost;
using namespace boost::asio;
using namespace json_spirit;
using namespace std;

json_spirit::Value help(const json_spirit::Array& params, bool fHelp) // Corrected signature
{
	if (fHelp || params.size() > 1)
		throw runtime_error(
			"help ( \"command\" )\n"
			"\nList all commands, or get help for a specified command.\n"
			"\nArguments:\n"
			"1. \"command\"    (string, optional) The command to get help on\n"
			"\nResult:\n"
			"\"text\"    (string) The help text\n"
		);

	string strCommand;
	if (params.size() > 0)
		strCommand = params[0].get_str();

	return tableRPC.help(strCommand);
}

json_spirit::Value stop(const json_spirit::Array& params, bool fHelp) // Corrected signature
{
	if (fHelp || params.size() > 1)
		throw runtime_error(
			"stop\n"
			"\nStop Worldcoin server.");
	StartShutdown();
	return "Worldcoin server stopping";
}

#if BOOST_VERSION < 106600
using boost::arg;
using boost::local_arg;
namespace ph = boost::placeholders;
#else
#include <boost/bind/placeholders.hpp>
namespace ph = boost::placeholders;
#endif

static std::string strRPCUserColonPass;

static bool fRPCRunning = false;
static bool fRPCInWarmup = true;
static std::string rpcWarmupStatus("RPC server started");
static CCriticalSection cs_rpcWarmup;

// Updated from io_service to io_context
static asio::io_context* rpc_io_service = nullptr;

static map<string, boost::shared_ptr<deadline_timer> > deadlineTimers;

//static ssl::context* rpc_ssl_context = NULL;
static std::shared_ptr<ssl::context> rpc_ssl_context;

static boost::thread_group* rpc_worker_group = NULL;

// Updated work guard initialization to use unique_ptr and modern Asio
static std::unique_ptr<boost::asio::executor_work_guard<boost::asio::io_context::executor_type>> rpc_dummy_work;

static std::vector<CSubNet> rpc_allow_subnets;
static std::vector< boost::shared_ptr<ip::tcp::acceptor> > rpc_acceptors;

void RPCTypeCheck(const Array& params,
					const list<Value_type>& typesExpected,
					bool fAllowNull)
{
	unsigned int i = 0;
	BOOST_FOREACH(Value_type t, typesExpected)
	{
		if (params.size() <= i)
			break;

		const Value& v = params[i];
		if (!((v.type() == t) || (fAllowNull && (v.type() == null_type))))
		{
			string err = strprintf("Expected type %s, got %s",
									 Value_type_name[t], Value_type_name[v.type()]);
			throw JSONRPCError(RPC_TYPE_ERROR, err);
		}
		i++;
	}
}

void RPCTypeCheck(const Object& o,
					const map<string, Value_type>& typesExpected,
					bool fAllowNull)
{
	BOOST_FOREACH(const PAIRTYPE(string, Value_type)& t, typesExpected)
	{
		const Value& v = find_value(o, t.first);
		if (!fAllowNull && v.type() == null_type)
			throw JSONRPCError(RPC_TYPE_ERROR, strprintf("Missing %s", t.first));

		if (!((v.type() == t.second) || (fAllowNull && (v.type() == null_type))))
		{
			string err = strprintf("Expected type %s for %s, got %s",
									 Value_type_name[t.second], t.first, Value_type_name[v.type()]);
			throw JSONRPCError(RPC_TYPE_ERROR, err);
		}
	}
}

static inline int64_t roundint64(double d)
{
	return (int64_t)(d > 0 ? d + 0.5 : d - 0.5);
}

/**
 * Call Table
 */
static const CRPCCommand vRPCCommands[] =
{

	/* Overall control/query calls */
	{ "control",            "getinfo",                &getinfo,                true,      false,      false }, /* uses wallet if enabled */
	{ "control",            "help",                   &help,                   true,      true,       false },
	{ "control",            "stop",                   &stop,                   true,      true,       false },

	/* P2P networking */
	{ "network",            "getnetworkinfo",         &getnetworkinfo,         true,      false,      false },
	{ "network",            "addnode",                &addnode,                true,      true,       false },
	{ "network",            "getaddednodeinfo",       &getaddednodeinfo,       true,      true,       false },
	{ "network",            "getconnectioncount",     &getconnectioncount,     true,      false,      false },
	{ "network",            "getnettotals",           &getnettotals,           true,      true,       false },
	{ "network",            "getpeerinfo",            &getpeerinfo,            true,      false,      false },
	{ "network",            "ping",                   &ping,                   true,      false,      false },

	/* Block chain and UTXO */
	{ "blockchain",         "getblockchaininfo",      &getblockchaininfo,      true,      false,      false },
	{ "blockchain",         "getbestblockhash",       &getbestblockhash,       true,      false,      false },
	{ "blockchain",         "getblockcount",          &getblockcount,          true,      false,      false },
	{ "blockchain",         "getblock",               &getblock,               true,      false,      false },
	{ "blockchain",         "getblockhash",           &getblockhash,           true,      false,      false },
	{ "blockchain",         "getchaintips",           &getchaintips,           true,      false,      false },
	{ "blockchain",         "getdifficulty",          &getdifficulty,          true,      false,      false },
	{ "blockchain",         "getmempoolinfo",         &getmempoolinfo,         true,      true,       false },
	{ "blockchain",         "getrawmempool",          &getrawmempool,          true,      false,      false },
	{ "blockchain",         "gettxout",               &gettxout,               true,      false,      false },
	{ "blockchain",         "gettxoutsetinfo",        &gettxoutsetinfo,        true,      false,      false },
	{ "blockchain",         "verifychain",            &verifychain,            true,      false,      false },
	{ "blockchain",         "invalidateblock",        &invalidateblock,        true,      true,       false },
	{ "blockchain",         "reconsiderblock",        &reconsiderblock,        true,      true,       false },

	/* Mining */
	{ "mining",             "getblocktemplate",       &getblocktemplate,       true,      false,      false },
	{ "mining",             "getmininginfo",          &getmininginfo,          true,      false,      false },
	{ "mining",             "getnetworkhashps",       &getnetworkhashps,       true,      false,      false },
	{ "mining",             "prioritisetransaction",  &prioritisetransaction,  true,      false,      false },
	{ "mining",             "submitblock",            &submitblock,            true,      true,       false },

#ifdef ENABLE_WALLET
	/* Coin generation */
	{ "generating",         "getgenerate",            &getgenerate,            true,      false,      false },
	{ "generating",         "gethashespersec",        &gethashespersec,        true,      false,      false },
	{ "generating",         "setgenerate",            &setgenerate,            true,      true,       false },
#endif

	/* Raw transactions */
	{ "rawtransactions",    "createrawtransaction",   &createrawtransaction,   true,      false,      false },
	{ "rawtransactions",    "decoderawtransaction",   &decoderawtransaction,   true,      false,      false },
	{ "rawtransactions",    "decodescript",           &decodescript,           true,      false,      false },
	{ "rawtransactions",    "getrawtransaction",      &getrawtransaction,      true,      false,      false },
	{ "rawtransactions",    "sendrawtransaction",     &sendrawtransaction,     false,     false,      false },
	{ "rawtransactions",    "signrawtransaction",     &signrawtransaction,     false,     false,      false }, /* uses wallet if enabled */

	/* Utility functions */
	{ "util",               "createmultisig",         &createmultisig,         true,      true ,      false },
	{ "util",               "validateaddress",        &validateaddress,        true,      false,      false }, /* uses wallet if enabled */
	{ "util",               "verifymessage",          &verifymessage,          true,      false,      false },
	{ "util",               "estimatefee",            &estimatefee,            true,      true,       false },
	{ "util",               "estimatepriority",       &estimatepriority,       true,      true,       false },

	/* Not shown in help */
	{ "hidden",             "invalidateblock",        &invalidateblock,        true,      true,       false },
	{ "hidden",             "reconsiderblock",        &reconsiderblock,        true,      true,       false },
	{ "hidden",             "setmocktime",            &setmocktime,            true,      false,      false },

#ifdef ENABLE_WALLET
	/* Wallet */
	{ "wallet",             "addmultisigaddress",     &addmultisigaddress,     true,      false,      true },
	{ "wallet",             "backupwallet",           &backupwallet,           true,      false,      true },
	{ "wallet",             "dumpprivkey",            &dumpprivkey,            true,      false,      true },
	{ "wallet",             "dumpwallet",             &dumpwallet,             true,      false,      true },
	{ "wallet",             "encryptwallet",          &encryptwallet,          true,      false,      true },
	{ "wallet",             "getaccountaddress",      &getaccountaddress,      true,      false,      true },
	{ "wallet",             "getaccount",             &getaccount,             true,      false,      true },
	{ "wallet",             "getaddressesbyaccount",  &getaddressesbyaccount,  true,      false,      true },
	{ "wallet",             "getbalance",             &getbalance,             false,     false,      true },
	{ "wallet",             "getnewaddress",          &getnewaddress,          true,      false,      true },
	{ "wallet",             "getrawchangeaddress",    &getrawchangeaddress,    true,      false,      true },
	{ "wallet",             "getreceivedbyaccount",   &getreceivedbyaccount,   false,     false,      true },
	{ "wallet",             "getreceivedbyaddress",   &getreceivedbyaddress,   false,     false,      true },
	{ "wallet",             "gettransaction",         &gettransaction,         false,     false,      true },
	{ "wallet",             "getunconfirmedbalance",  &getunconfirmedbalance,  false,     false,      true },
	{ "wallet",             "getwalletinfo",          &getwalletinfo,          false,     false,      true },
	{ "wallet",             "importprivkey",          &importprivkey,          true,      false,      true },
	{ "wallet",             "importwallet",           &importwallet,           true,      false,      true },
	{ "wallet",             "importaddress",          &importaddress,          true,      false,      true },
	{ "wallet",             "keypoolrefill",          &keypoolrefill,          true,      false,      true },
	{ "wallet",             "listaccounts",           &listaccounts,           false,     false,      true },
	{ "wallet",             "listaddressgroupings",   &listaddressgroupings,   false,     false,      true },
	{ "wallet",             "listlockunspent",        &listlockunspent,        false,     false,      true },
	{ "wallet",             "listreceivedbyaccount",  &listreceivedbyaccount,  false,     false,      true },
	{ "wallet",             "listreceivedbyaddress",  &listreceivedbyaddress,  false,     false,      true },
	{ "wallet",             "listsinceblock",         &listsinceblock,         false,     false,      true },
	{ "wallet",             "listtransactions",       &listtransactions,       false,     false,      true },
	{ "wallet",             "listunspent",            &listunspent,            false,     false,      true },
	{ "wallet",             "lockunspent",            &lockunspent,            true,      false,      true },
	{ "wallet",             "move",                   &movecmd,                false,     false,      true },
	{ "wallet",             "sendfrom",               &sendfrom,               false,     false,      true },
	{ "wallet",             "sendmany",               &sendmany,               false,     false,      true },
	{ "wallet",             "sendtoaddress",          &sendtoaddress,          false,     false,      true },
	{ "wallet",             "setaccount",             &setaccount,             true,      false,      true },
	{ "wallet",             "settxfee",               &settxfee,               true,      false,      true },
	{ "wallet",             "signmessage",            &signmessage,            true,      false,      true },
	{ "wallet",             "walletlock",             &walletlock,             true,      false,      true },
	{ "wallet",             "walletpassphrasechange", &walletpassphrasechange, true,      false,      true },
	{ "wallet",             "walletpassphrase",       &walletpassphrase,       true,      false,      true },
#endif
};

CAmount AmountFromValue(const Value& value)
{
	double dAmount = value.get_real();
	if (dAmount <= 0.0 || dAmount > 84000000.0)
		throw JSONRPCError(RPC_TYPE_ERROR, "Invalid amount");
	CAmount nAmount = roundint64(dAmount * COIN);
	if (!MoneyRange(nAmount))
		throw JSONRPCError(RPC_TYPE_ERROR, "Invalid amount");
	return nAmount;
}

Value ValueFromAmount(const CAmount& amount)
{
	return (double)amount / (double)COIN;
}

uint256 ParseHashV(const Value& v, string strName)
{
	string strHex;
	if (v.type() == str_type)
		strHex = v.get_str();
	if (!IsHex(strHex))
		throw JSONRPCError(RPC_INVALID_PARAMETER, strName+" must be hexadecimal string (not '"+strHex+"')");
	uint256 result;
	result.SetHex(strHex);
	return result;
}
uint256 ParseHashO(const Object& o, string strKey)
{
	return ParseHashV(find_value(o, strKey), strKey);
}
vector<unsigned char> ParseHexV(const Value& v, string strName)
{
	string strHex;
	if (v.type() == str_type)
		strHex = v.get_str();
	if (!IsHex(strHex))
		throw JSONRPCError(RPC_INVALID_PARAMETER, strName+" must be hexadecimal string (not '"+strHex+"')");
	return ParseHex(strHex);
}
vector<unsigned char> ParseHexO(const Object& o, string strKey)
{
	return ParseHexV(find_value(o, strKey), strKey);
}

string CRPCTable::help(string strCommand) const
{
	string strRet;
	string category;
	set<rpcfn_type> setDone;
	vector<pair<string, const CRPCCommand*> > vCommands;

	for (map<string, const CRPCCommand*>::const_iterator mi = mapCommands.begin(); mi != mapCommands.end(); ++mi)
		vCommands.push_back(make_pair(mi->second->category + mi->first, mi->second));
	sort(vCommands.begin(), vCommands.end());

	BOOST_FOREACH(const PAIRTYPE(string, const CRPCCommand*)& command, vCommands)
	{
		const CRPCCommand *pcmd = command.second;
		string strMethod = pcmd->name;

		if (strMethod.find("label") != string::npos)
			continue;
		if ((strCommand != "" || pcmd->category == "hidden") && strMethod != strCommand)
			continue;
#ifdef ENABLE_WALLET
		if (pcmd->reqWallet && !pwalletMain)
			continue;
#endif

		try
		{
			Array params;
			rpcfn_type pfn = pcmd->actor;
			if (setDone.insert(pfn).second)
				(*pfn)(params, true);
		}
		catch (std::exception& e)
		{
			string strHelp = string(e.what());
			if (strCommand == "")
			{
				if (strHelp.find('\n') != string::npos)
					strHelp = strHelp.substr(0, strHelp.find('\n'));

				if (category != pcmd->category)
				{
					if (!category.empty())
						strRet += "\n";
					category = pcmd->category;
					string firstLetter = category.substr(0,1);
					boost::to_upper(firstLetter);
					strRet += "== " + firstLetter + category.substr(1) + " ==\n";
				}
			}
			strRet += strHelp + "\n";
		}
	}
	if (strRet == "")
		strRet = strprintf("help: unknown command: %s\n", strCommand);
	strRet = strRet.substr(0,strRet.size()-1);
	return strRet;
}

CRPCTable::CRPCTable()
{
	unsigned int vcidx;
	for (vcidx = 0; vcidx < (sizeof(vRPCCommands) / sizeof(vRPCCommands[0])); vcidx++)
	{
		const CRPCCommand *pcmd;

		pcmd = &vRPCCommands[vcidx];
		mapCommands[pcmd->name] = pcmd;
	}
}

const CRPCCommand *CRPCTable::operator[](string name) const
{
	map<string, const CRPCCommand*>::const_iterator it = mapCommands.find(name);
	if (it == mapCommands.end())
		return NULL;
	return (*it).second;
}

bool HTTPAuthorized(map<string, string>& mapHeaders)
{
	string strAuth = mapHeaders["authorization"];
	if (strAuth.substr(0,6) != "Basic ")
		return false;
	string strUserPass64 = strAuth.substr(6); boost::trim(strUserPass64);
	string strUserPass = DecodeBase64(strUserPass64);
	return TimingResistantEqual(strUserPass, strRPCUserColonPass);
}

void ErrorReply(std::ostream& stream, const Object& objError, const Value& id)
{
	int nStatus = HTTP_INTERNAL_SERVER_ERROR;
	int code = find_value(objError, "code").get_int();
	if (code == RPC_INVALID_REQUEST) nStatus = HTTP_BAD_REQUEST;
	else if (code == RPC_METHOD_NOT_FOUND) nStatus = HTTP_NOT_FOUND;
	string strReply = JSONRPCReply(Value::null, objError, id);
	stream << HTTPReply(nStatus, strReply, false) << std::flush;
}

CNetAddr BoostAsioToCNetAddr(boost::asio::ip::address address)
{
	CNetAddr netaddr;
	if(address.is_v4())
	{
		boost::asio::ip::address_v4::bytes_type bytes = address.to_v4().to_bytes();
		netaddr.SetRaw(NET_IPV4, &bytes[0]);
	}
	else if (address.is_v6()) // Ensure it's explicitly v6 if not v4
	{
		boost::asio::ip::address_v6::bytes_type bytes = address.to_v6().to_bytes();
		netaddr.SetRaw(NET_IPV6, &bytes[0]);
	}
	// else: An unknown address type, should probably log or assert if unexpected.
	return netaddr;
}

bool ClientAllowed(const boost::asio::ip::address& address)
{
	CNetAddr netaddr = BoostAsioToCNetAddr(address);
	BOOST_FOREACH(const CSubNet &subnet, rpc_allow_subnets)
		if (subnet.Match(netaddr))
			return true;
	return false;
}

// Forward declaration for RPCListen
// This tells the compiler that RPCListen exists and what its signature is,
// before its full definition.
template <typename Protocol, typename SocketAcceptorService>
static void RPCListen(boost::shared_ptr< basic_socket_acceptor<Protocol, SocketAcceptorService> > acceptor,
                      std::shared_ptr<ssl::context> context_ptr,
                      const bool fUseSSL);

// Corrected AcceptedConnectionImpl class
template <typename Protocol>
class AcceptedConnectionImpl : public AcceptedConnection
{
public:
		AcceptedConnectionImpl(
				boost::asio::io_context& io_context,
				boost::asio::ssl::context& context,
				bool fUseSSL) :
				sslStream(io_context, context),
				_d(io_context, sslStream, fUseSSL),
				_stream(_d)
		{
		}

		virtual std::iostream& stream()
		{
				return _stream;
		}

		virtual std::string peer_address_to_string() const
		{
				return peer.address().to_string();
		}

		virtual void close()
		{
				_stream.close();
		}

		typename Protocol::endpoint peer;
		boost::asio::ssl::stream<typename Protocol::socket> sslStream;

private:
		SSLIOStreamDevice<Protocol> _d;
		boost::iostreams::stream<SSLIOStreamDevice<Protocol>> _stream;
};

void ServiceConnection(AcceptedConnection *conn);

template <typename Protocol, typename SocketAcceptorService>
static void RPCAcceptHandler(boost::shared_ptr< basic_socket_acceptor<Protocol, SocketAcceptorService> > acceptor,
														 std::shared_ptr<ssl::context> context_ptr, // Use shared_ptr consistently
														 const bool fUseSSL,
														 boost::shared_ptr< AcceptedConnection > conn,
														 const boost::system::error_code& error)
{
		if (error != asio::error::operation_aborted && acceptor->is_open())
				RPCListen(acceptor, context_ptr, fUseSSL); // Pass context_ptr

		AcceptedConnectionImpl<ip::tcp>* tcp_conn = dynamic_cast< AcceptedConnectionImpl<ip::tcp>* >(conn.get());

		if (error)
		{
				LogPrintf("%s: Error: %s\n", __func__, error.message());
		}
		else if (tcp_conn && !ClientAllowed(tcp_conn->peer.address()))
		{
				if (!fUseSSL)
						conn->stream() << HTTPError(HTTP_FORBIDDEN, false) << std::flush;
				conn->close();
		}
		else {
				ServiceConnection(conn.get());
				conn->close();
		}
}

// Corrected RPCListen function
template <typename Protocol, typename SocketAcceptorService>
static void RPCListen(boost::shared_ptr< basic_socket_acceptor<Protocol, SocketAcceptorService> > acceptor,
											std::shared_ptr<ssl::context> context_ptr,
											const bool fUseSSL)
{
		// Create the connection - make sure to dereference the shared_ptr correctly
		boost::shared_ptr<AcceptedConnectionImpl<Protocol>> conn(
				new AcceptedConnectionImpl<Protocol>(
						// Change this line:
						*rpc_io_service, // Use the global rpc_io_service directly, which is a io_context
						*context_ptr, // Dereference the shared_ptr to get ssl::context&
						fUseSSL
				)
		);

		acceptor->async_accept(
				conn->sslStream.lowest_layer(),
				conn->peer,
				[acceptor, context_ptr, fUseSSL, conn](const boost::system::error_code& error)
				{
						RPCAcceptHandler(acceptor, context_ptr, fUseSSL, conn, error);
				});
}

static ip::tcp::endpoint ParseEndpoint(const std::string &strEndpoint, int defaultPort)
{
	std::string addr;
	int port = defaultPort;
	SplitHostPort(strEndpoint, port, addr);
	// Updated from_string to make_address
	return ip::tcp::endpoint(asio::ip::make_address(addr), port);
}

void StartRPCThreads()
{
	rpc_allow_subnets.clear();
	rpc_allow_subnets.push_back(CSubNet("127.0.0.0/8"));
	rpc_allow_subnets.push_back(CSubNet("::1"));
	if (mapMultiArgs.count("-rpcallowip"))
	{
		const vector<string>& vAllow = mapMultiArgs["-rpcallowip"];
		BOOST_FOREACH(string strAllow, vAllow)
		{
			CSubNet subnet(strAllow);
			if(!subnet.IsValid())
			{
				uiInterface.ThreadSafeMessageBox(
					strprintf("Invalid -rpcallowip subnet specification: %s. Valid are a single IP (e.g. 1.2.3.4), a network/netmask (e.g. 1.2.3.4/255.255.255.0) or a network/CIDR (e.g. 1.2.3.4/24).", strAllow),
					"", CClientUIInterface::MSG_ERROR);
				StartShutdown();
				return;
			}
			rpc_allow_subnets.push_back(subnet);
		}
	}
	std::string strAllowed;
	BOOST_FOREACH(const CSubNet &subnet, rpc_allow_subnets)
		strAllowed += subnet.ToString() + " ";
	LogPrint("rpc", "Allowing RPC connections from: %s\n", strAllowed);

	strRPCUserColonPass = mapArgs["-rpcuser"] + ":" + mapArgs["-rpcpassword"];
	if (((mapArgs["-rpcpassword"] == "") ||
		 (mapArgs["-rpcuser"] == mapArgs["-rpcpassword"])) && Params().RequireRPCPassword())
	{
		unsigned char rand_pwd[32];
		GetRandBytes(rand_pwd, 32);
		uiInterface.ThreadSafeMessageBox(strprintf(
			_("To use worldcoind, or the -server option to worldcoin-qt, you must set an rpcpassword in the configuration file:\n"
				"%s\n"
				"It is recommended you use the following random password:\n"
				"rpcuser=worldcoinrpc\n"
				"rpcpassword=%s\n"
				"(you do not need to remember this password)\n"
				"The username and password MUST NOT be the same.\n"
				"If the file does not exist, create it with owner-readable-only file permissions.\n"
				"It is also recommended to set alertnotify so you are notified of problems;\n"
				"for example: alertnotify=echo %%s | mail -s \"Worldcoin Alert\" admin@foo.com\n"),
				GetConfigFile().string(),
				EncodeBase58(&rand_pwd[0],&rand_pwd[0]+32)),
				"", CClientUIInterface::MSG_ERROR | CClientUIInterface::SECURE);
		StartShutdown();
		return;
	}

	assert(rpc_io_service == NULL);
	// Updated to io_context
	rpc_io_service = new asio::io_context();
	// Updated ssl::context constructor - use shared_ptr
	rpc_ssl_context = std::make_shared<ssl::context>(ssl::context::sslv23);

	const bool fUseSSL = GetBoolArg("-rpcssl", false);

	if (fUseSSL)
	{
		rpc_ssl_context->set_options(ssl::context::no_sslv2 | ssl::context::no_sslv3);

		boost::filesystem::path pathCertFile(GetArg("-rpcsslcertificatechainfile", "server.cert"));
		if (!pathCertFile.is_absolute())
			pathCertFile = boost::filesystem::path(GetDataDir()) / pathCertFile;
		if (boost::filesystem::exists(pathCertFile))
			rpc_ssl_context->use_certificate_chain_file(pathCertFile.string());
		else
			LogPrintf("ThreadRPCServer ERROR: missing server certificate file %s\n", pathCertFile.string());

		boost::filesystem::path pathPKFile(GetArg("-rpcsslprivatekeyfile", "server.pem"));
		if (!pathPKFile.is_absolute())
			pathPKFile = boost::filesystem::path(GetDataDir()) / pathPKFile;
		if (boost::filesystem::exists(pathPKFile))
			rpc_ssl_context->use_private_key_file(pathPKFile.string(), ssl::context::pem);
		else
			LogPrintf("ThreadRPCServer ERROR: missing server private key file %s\n", pathPKFile.string());

		std::string strCiphers = GetArg("-rpcsslciphers", "TLSv1.2+HIGH:TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH");
		SSL_CTX_set_cipher_list(rpc_ssl_context->native_handle(), strCiphers.c_str());
	}

	std::vector<ip::tcp::endpoint> vEndpoints;
	bool bBindAny = false;
	int defaultPort = GetArg("-rpcport", BaseParams().RPCPort());
	if (!mapArgs.count("-rpcallowip"))
	{
		vEndpoints.push_back(ip::tcp::endpoint(asio::ip::address_v6::loopback(), defaultPort));
		vEndpoints.push_back(ip::tcp::endpoint(asio::ip::address_v4::loopback(), defaultPort));
		if (mapArgs.count("-rpcbind"))
		{
			LogPrintf("WARNING: option -rpcbind was ignored because -rpcallowip was not specified, refusing to allow everyone to connect\n");
		}
	} else if (mapArgs.count("-rpcbind"))
	{
		BOOST_FOREACH(const std::string &addr, mapMultiArgs["-rpcbind"])
		{
			try {
				vEndpoints.push_back(ParseEndpoint(addr, defaultPort));
			}
			catch(const boost::system::system_error &)
			{
				uiInterface.ThreadSafeMessageBox(
					strprintf(_("Could not parse -rpcbind value %s as network address"), addr),
					"", CClientUIInterface::MSG_ERROR);
				StartShutdown();
				return;
			}
		}
	} else {
		vEndpoints.push_back(ip::tcp::endpoint(asio::ip::address_v6::any(), defaultPort));
		vEndpoints.push_back(ip::tcp::endpoint(asio::ip::address_v4::any(), defaultPort));
		bBindAny = true;
	}

	bool fListening = false;
	std::string strerr;
	std::string straddress;
	BOOST_FOREACH(const ip::tcp::endpoint &endpoint, vEndpoints)
	{
		try {
			asio::ip::address bindAddress = endpoint.address();
			straddress = bindAddress.to_string();
			LogPrintf("Binding RPC on address %s port %i (IPv4+IPv6 bind any: %i)\n", straddress, endpoint.port(), bBindAny);
			boost::system::error_code v6_only_error;
			boost::shared_ptr<ip::tcp::acceptor> acceptor(new ip::tcp::acceptor(*rpc_io_service));

			acceptor->open(endpoint.protocol());
			acceptor->set_option(boost::asio::ip::tcp::acceptor::reuse_address(true));
			acceptor->set_option(boost::asio::ip::v6_only(!bBindAny || bindAddress != asio::ip::address_v6::any()), v6_only_error);

			acceptor->bind(endpoint);
			acceptor->listen(boost::asio::socket_base::max_listen_connections);

			// Pass the shared_ptr to RPCListen
			RPCListen(acceptor, rpc_ssl_context, fUseSSL);

			fListening = true;
			rpc_acceptors.push_back(acceptor);

			if(bBindAny && bindAddress == asio::ip::address_v6::any() && !v6_only_error)
				break;
		}
		catch(boost::system::system_error &e)
		{
			LogPrintf("ERROR: Binding RPC on address %s port %i failed: %s\n", straddress, endpoint.port(), e.what());
			strerr = strprintf(_("An error occurred while setting up the RPC address %s port %u for listening: %s"), straddress, endpoint.port(), e.what());
		}
	}

	if (!fListening) {
		uiInterface.ThreadSafeMessageBox(strerr, "", CClientUIInterface::MSG_ERROR);
		StartShutdown();
		return;
	}

	rpc_worker_group = new boost::thread_group();
	for (int i = 0; i < GetArg("-rpcthreads", 4); i++)
		// Updated to io_context::run
		rpc_worker_group->create_thread(boost::bind(&asio::io_context::run, rpc_io_service));
	fRPCRunning = true;
}

void StartDummyRPCThread()
{
	if(rpc_io_service == NULL)
	{
		// Updated to io_context
		rpc_io_service = new asio::io_context();
		// Updated to use make_unique and make_work_guard
		rpc_dummy_work = std::make_unique<boost::asio::executor_work_guard<boost::asio::io_context::executor_type>>(
			boost::asio::make_work_guard(*rpc_io_service)
		);
		rpc_worker_group = new boost::thread_group();
		// Updated to io_context::run
		rpc_worker_group->create_thread(boost::bind(&asio::io_context::run, rpc_io_service));
		fRPCRunning = true;
	}
}

void StopRPCThreads()
{
		if (rpc_io_service == NULL) return;

		fRPCRunning = false;

		boost::system::error_code ec;
		BOOST_FOREACH(const boost::shared_ptr<ip::tcp::acceptor> &acceptor, rpc_acceptors)
		{
				acceptor->cancel(ec);
				if (ec)
						LogPrintf("%s: Warning: %s when cancelling acceptor", __func__, ec.message());
		}
		rpc_acceptors.clear();
		BOOST_FOREACH(const PAIRTYPE(std::string, boost::shared_ptr<deadline_timer>) &timer, deadlineTimers)
		{
				timer.second->cancel(ec);
				if (ec)
						LogPrintf("%s: Warning: %s when cancelling timer", __func__, ec.message());
		}
		deadlineTimers.clear();

		rpc_io_service->stop();
		cvBlockChange.notify_all();
		if (rpc_worker_group != NULL)
				rpc_worker_group->join_all();

		// Use reset() for unique_ptr (already correct for rpc_dummy_work)
		rpc_dummy_work.reset();

		if (rpc_ssl_context) // Check if it's holding an object
				rpc_ssl_context.reset(); // Release the managed object

		delete rpc_worker_group; rpc_worker_group = NULL;
		delete rpc_io_service; rpc_io_service = NULL; // These are still raw pointers, so 'delete' is correct for them.
}

bool IsRPCRunning()
{
	return fRPCRunning;
}

void SetRPCWarmupStatus(const std::string& newStatus)
{
	LOCK(cs_rpcWarmup);
	rpcWarmupStatus = newStatus;
}

void SetRPCWarmupFinished()
{
	LOCK(cs_rpcWarmup);
	assert(fRPCInWarmup);
	fRPCInWarmup = false;
}

bool RPCIsInWarmup(std::string *outStatus)
{
	LOCK(cs_rpcWarmup);
	if (outStatus)
		*outStatus = rpcWarmupStatus;
	return fRPCInWarmup;
}

void RPCRunHandler(const boost::system::error_code& err, boost::function<void(void)> func)
{
	if (!err)
		func();
}

void RPCRunLater(const std::string& name, boost::function<void(void)> func, int64_t nSeconds)
{
	assert(rpc_io_service != NULL);

	if (deadlineTimers.count(name) == 0)
	{
		deadlineTimers.insert(make_pair(name,
										boost::shared_ptr<deadline_timer>(new deadline_timer(*rpc_io_service))));
	}
	deadlineTimers[name]->expires_from_now(posix_time::seconds(nSeconds));
	// Replaced boost::bind with a C++11 lambda
	deadlineTimers[name]->async_wait([func](const boost::system::error_code& err){ RPCRunHandler(err, func); });
}

class JSONRequest
{
public:
	Value id;
	string strMethod;
	Array params;

	JSONRequest() { id = Value::null; }
	void parse(const Value& valRequest);
};

void JSONRequest::parse(const Value& valRequest)
{
	if (valRequest.type() != obj_type)
		throw JSONRPCError(RPC_INVALID_REQUEST, "Invalid Request object");
	const Object& request = valRequest.get_obj();

	id = find_value(request, "id");

	Value valMethod = find_value(request, "method");
	if (valMethod.type() == null_type)
		throw JSONRPCError(RPC_INVALID_REQUEST, "Missing method");
	if (valMethod.type() != str_type)
		throw JSONRPCError(RPC_INVALID_REQUEST, "Method must be a string");
	strMethod = valMethod.get_str();
	if (strMethod != "getblocktemplate")
		LogPrint("rpc", "ThreadRPCServer method=%s\n", SanitizeString(strMethod));

	Value valParams = find_value(request, "params");
	if (valParams.type() == array_type)
		params = valParams.get_array();
	else if (valParams.type() == null_type)
		params = Array();
	else
		throw JSONRPCError(RPC_INVALID_REQUEST, "Params must be an array");
}

static Object JSONRPCExecOne(const Value& req)
{
	Object rpc_result;

	JSONRequest jreq;
	try {
		jreq.parse(req);

		Value result = tableRPC.execute(jreq.strMethod, jreq.params);
		rpc_result = JSONRPCReplyObj(result, Value::null, jreq.id);
	}
	catch (Object& objError)
	{
		rpc_result = JSONRPCReplyObj(Value::null, objError, jreq.id);
	}
	catch (std::exception& e)
	{
		rpc_result = JSONRPCReplyObj(Value::null,
									 JSONRPCError(RPC_PARSE_ERROR, e.what()), jreq.id);
	}

	return rpc_result;
}

static string JSONRPCExecBatch(const Array& vReq)
{
	Array ret;
	for (unsigned int reqIdx = 0; reqIdx < vReq.size(); reqIdx++)
		ret.push_back(JSONRPCExecOne(vReq[reqIdx]));

	return write_string(Value(ret), false) + "\n";
}

static bool HTTPReq_JSONRPC(AcceptedConnection *conn,
							string& strRequest,
							map<string, string>& mapHeaders,
							bool fRun)
{
	if (mapHeaders.count("authorization") == 0)
	{
		conn->stream() << HTTPError(HTTP_UNAUTHORIZED, false) << std::flush;
		return false;
	}

	if (!HTTPAuthorized(mapHeaders))
	{
		LogPrintf("ThreadRPCServer incorrect password attempt from %s\n", conn->peer_address_to_string());
		MilliSleep(250);
		conn->stream() << HTTPError(HTTP_UNAUTHORIZED, false) << std::flush;
		return false;
	}

	JSONRequest jreq;
	try
	{
		Value valRequest;
		if (!read_string(strRequest, valRequest))
			throw JSONRPCError(RPC_PARSE_ERROR, "Parse error");

		{
			LOCK(cs_rpcWarmup);
			if (fRPCInWarmup)
				throw JSONRPCError(RPC_IN_WARMUP, rpcWarmupStatus);
		}

		string strReply;

		if (valRequest.type() == obj_type) {
			jreq.parse(valRequest);
			Value result = tableRPC.execute(jreq.strMethod, jreq.params);
			strReply = JSONRPCReply(result, Value::null, jreq.id);
		} else if (valRequest.type() == array_type)
			strReply = JSONRPCExecBatch(valRequest.get_array());
		else
			throw JSONRPCError(RPC_PARSE_ERROR, "Top-level object parse error");

		conn->stream() << HTTPReplyHeader(HTTP_OK, fRun, strReply.size()) << strReply << std::flush;
	}
	catch (Object& objError)
	{
		ErrorReply(conn->stream(), objError, jreq.id);
		return false;
	}
	catch (std::exception& e)
	{
		ErrorReply(conn->stream(), JSONRPCError(RPC_PARSE_ERROR, e.what()), jreq.id);
		return false;
	}
	return true;
}

void ServiceConnection(AcceptedConnection *conn)
{
	bool fRun = true;
	while (fRun && !ShutdownRequested())
	{
		int nProto = 0;
		map<string, string> mapHeaders;
		string strRequest, strMethod, strURI;

		if (!ReadHTTPRequestLine(conn->stream(), nProto, strMethod, strURI))
			break;

		ReadHTTPMessage(conn->stream(), mapHeaders, strRequest, nProto, MAX_SIZE);

		if ((mapHeaders["connection"] == "close") || (!GetBoolArg("-rpckeepalive", true)))
			fRun = false;

		if (strURI == "/") {
			if (!HTTPReq_JSONRPC(conn, strRequest, mapHeaders, fRun))
				break;
		} else if (strURI.substr(0, 6) == "/rest/" && GetBoolArg("-rest", false)) {
			if (!HTTPReq_REST(conn, strURI, mapHeaders, fRun))
				break;
		} else {
			conn->stream() << HTTPError(HTTP_NOT_FOUND, false) << std::flush;
			break;
		}
	}
}

json_spirit::Value CRPCTable::execute(const std::string &strMethod, const json_spirit::Array &params) const
{
	const CRPCCommand *pcmd = tableRPC[strMethod];
	if (!pcmd)
		throw JSONRPCError(RPC_METHOD_NOT_FOUND, "Method not found");
#ifdef ENABLE_WALLET
	if (pcmd->reqWallet && !pwalletMain)
		throw JSONRPCError(RPC_METHOD_NOT_FOUND, "Method not found (disabled)");
#endif

	string strWarning = GetWarnings("rpc");
	if (strWarning != "" && !GetBoolArg("-disablesafemode", false) &&
		!pcmd->okSafeMode)
		throw JSONRPCError(RPC_FORBIDDEN_BY_SAFE_MODE, string("Safe mode: ") + strWarning);

	try
	{
		Value result;
		{
			if (pcmd->threadSafe)
				result = pcmd->actor(params, false);
#ifdef ENABLE_WALLET
			else if (!pwalletMain) {
				LOCK(cs_main);
				result = pcmd->actor(params, false);
			} else {
				LOCK2(cs_main, pwalletMain->cs_wallet);
				result = pcmd->actor(params, false);
			}
#else
			else {
				LOCK(cs_main);
				result = pcmd->actor(params, false);
			}
#endif
		}
		return result;
	}
	catch (std::exception& e)
	{
		throw JSONRPCError(RPC_MISC_ERROR, e.what());
	}
}

std::string HelpExampleCli(string methodname, string args){
	return "> worldcoin-cli " + methodname + " " + args + "\n";
}

std::string HelpExampleRpc(string methodname, string args){
	return "> curl --user myusername --data-binary '{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", "
		"\"method\": \"" + methodname + "\", \"params\": [" + args + "] }' -H 'content-type: text/plain;' http:\n";
}

const CRPCTable tableRPC;