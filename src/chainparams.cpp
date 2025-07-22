#include "chainparams.h"

#include "random.h"
#include "util.h"
#include "utilstrencodings.h"
#include "streams.h"
#include "pow.h"

#include <assert.h>
#include <boost/assign/list_of.hpp>

using namespace std;
using namespace boost::assign;

struct SeedSpec6 {
  uint8_t addr[16];
  uint16_t port;
};

#include "chainparamsseeds.h"

static void convertSeed6(std::vector<CAddress> &vSeedsOut, const SeedSpec6 *data, unsigned int count)
{
  const int64_t nOneWeek = 7*24*60*60;
  for (unsigned int i = 0; i < count; i++)
  {
    struct in6_addr ip;
    memcpy(&ip, data[i].addr, sizeof(ip));
    CAddress addr(CService(ip, data[i].port));
    addr.nTime = GetTime() - GetRand(nOneWeek) - nOneWeek;
    vSeedsOut.push_back(addr);
  }
}

static Checkpoints::MapCheckpoints mapCheckpoints = {};
static const Checkpoints::CCheckpointData data = {
    &mapCheckpoints, 0, 0, 0
};

static Checkpoints::MapCheckpoints mapCheckpointsTestnet = {};
static const Checkpoints::CCheckpointData dataTestnet = {
    &mapCheckpointsTestnet, 0, 0, 0
};

static Checkpoints::MapCheckpoints mapCheckpointsRegtest = {};
static const Checkpoints::CCheckpointData dataRegtest = {
    &mapCheckpointsRegtest, 0, 0, 0
};

class CMainParams : public CChainParams {
public:
  CMainParams() {
    networkID = CBaseChainParams::MAIN;
    strNetworkID = "main";
    
    pchMessageStart[0] = 0xfc;
    pchMessageStart[1] = 0xc1;
    pchMessageStart[2] = 0xb7;
    pchMessageStart[3] = 0xdc;
    
    vAlertPubKey = ParseHex("040840f1b1f09d6fd78576b6fa58265b6441f3ff5923830e46d7f81c292bffa5aa080fcfd99ddd2ea20ab8552cb51996ac45f405f2a164777e04bcf3582932a599");
    nDefaultPort = 11085;
    
    bnProofOfWorkLimit = ~uint256(0) >> 20;
    nSubsidyHalvingInterval = 1000000;
    nEnforceBlockUpgradeMajority = 750;
    nRejectBlockOutdatedMajority = 950;
    nToCheckBlockUpgradeMajority = 1000;
    nMinerThreads = 1;
    nTargetTimespan = 0.35 * 24 * 60 * 60;
    nTargetSpacing = 300;
    nTargetTimespan2 = 60 * 60;
    nTargetSpacing2 = 30;
    nMaxTipAge = 0x7fffffff;

    // Genesis block mining
    const char* pszTimestamp = "17/Jul/2025 Worldcoin Relaunched To Create A Global Economy For All";
    CMutableTransaction txNew;
    txNew.vin.resize(1);
    txNew.vout.resize(1);
    txNew.vin[0].scriptSig = CScript() << 486604799 << CScriptNum(4) << vector<unsigned char>((const unsigned char*)pszTimestamp, (const unsigned char*)pszTimestamp + strlen(pszTimestamp));
    txNew.vout[0].nValue = 50 * COIN;
    txNew.vout[0].scriptPubKey = CScript() << ParseHex("040184710fa689ad5023690c80f3a49c8f13f8d45b8c857fbcbc8bc4a8e4d3eb4b10f4d4604fa08dce601aaf0f470216fe1b51850b4acf21b179c45070ac7b03a9") << OP_CHECKSIG;
    genesis.vtx.push_back(txNew);
    genesis.hashPrevBlock = 0;
    genesis.hashMerkleRoot = genesis.BuildMerkleTree();
    genesis.nVersion = 1;
    genesis.nTime = 1752791040;
    genesis.nBits = 0x1e0ffff0;  // Standard difficulty for mainnet
    genesis.nNonce = 576060;  // Found nonce

    hashGenesisBlock = genesis.GetHash();
    // Remove the mining loop - it's no longer needed

    base58Prefixes[PUBKEY_ADDRESS] = list_of(73);
    base58Prefixes[SCRIPT_ADDRESS] = list_of(5);
    base58Prefixes[SECRET_KEY] = list_of(14);
    base58Prefixes[EXT_PUBLIC_KEY] = list_of(0x04)(0x88)(0xB2)(0x1E);
    base58Prefixes[EXT_SECRET_KEY] = list_of(0x04)(0x88)(0xAD)(0xE4);

    convertSeed6(vFixedSeeds, pnSeed6_main, ARRAYLEN(pnSeed6_main));

    fRequireRPCPassword = true;
    fMiningRequiresPeers = false;
    fAllowMinDifficultyBlocks = false;
    fDefaultConsistencyChecks = false;
    fRequireStandard = true;
    fMineBlocksOnDemand = false;
    fSkipProofOfWorkCheck = false;
    fTestnetToBeDeprecatedFieldRPC = false;
    nEnforceV2AfterHeight = 0;
  }

  const Checkpoints::CCheckpointData& Checkpoints() const { return data; }
};
static CMainParams mainParams;

// Keep testnet and regtest simple too...
class CTestNetParams : public CMainParams {
public:
  CTestNetParams() {
    networkID = CBaseChainParams::TESTNET;
    strNetworkID = "test";
    nDefaultPort = 19334;
    fAllowMinDifficultyBlocks = true;
    fRequireStandard = false;
  }
  const Checkpoints::CCheckpointData& Checkpoints() const { return dataTestnet; }
};
static CTestNetParams testNetParams;

class CRegTestParams : public CTestNetParams {
public:
  CRegTestParams() {
    networkID = CBaseChainParams::REGTEST;
    strNetworkID = "regtest";
    nDefaultPort = 12989;
    bnProofOfWorkLimit = ~uint256(0) >> 1;
    fMiningRequiresPeers = false;
    fDefaultConsistencyChecks = true;
    fMineBlocksOnDemand = true;
  }
  const Checkpoints::CCheckpointData& Checkpoints() const { return dataRegtest; }
};
static CRegTestParams regTestParams;

static CChainParams *pCurrentParams = 0;

const CChainParams &Params() {
  assert(pCurrentParams);
  return *pCurrentParams;
}

CChainParams &Params(CBaseChainParams::Network network) {
  switch (network) {
    case CBaseChainParams::MAIN: return mainParams;
    case CBaseChainParams::TESTNET: return testNetParams;
    case CBaseChainParams::REGTEST: return regTestParams;
    default: assert(false && "Unimplemented network"); return mainParams;
  }
}

void SelectParams(CBaseChainParams::Network network) {
  SelectBaseParams(network);
  pCurrentParams = &Params(network);
}

bool SelectParamsFromCommandLine() {
  CBaseChainParams::Network network = NetworkIdFromCommandLine();
  if (network == CBaseChainParams::MAX_NETWORK_TYPES)
    return false;
  SelectParams(network);
  return true;
}
