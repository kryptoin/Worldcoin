#include "chainparams.h"

#include "random.h"
#include "util.h"
#include "utilstrencodings.h"
#include "streams.h"

#include <assert.h>

#include <boost/assign/list_of.hpp>

using namespace std;
using namespace boost::assign;

struct SeedSpec6 {
  uint8_t addr[16];
  uint16_t port;
};

#include "chainparamsseeds.h"

/**
 * Main network
 */

//! Convert the pnSeeds6 array into usable address objects.
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
    &mapCheckpoints,
    0,
    0,
    0
};

static Checkpoints::MapCheckpoints mapCheckpointsTestnet = {};
static const Checkpoints::CCheckpointData dataTestnet = {
    &mapCheckpointsTestnet,
    0,
    0,
    0
};

static Checkpoints::MapCheckpoints mapCheckpointsRegtest = {};
static const Checkpoints::CCheckpointData dataRegtest = {
    &mapCheckpointsRegtest,
    0,
    0,
    0
};

class CMainParams : public CChainParams {
public:
  CMainParams() {
    printf("[DEBUG] ENTERED CMainParams CONSTRUCTOR\n");
    fflush(stdout);
    networkID = CBaseChainParams::MAIN;
    strNetworkID = "main";
    /**
     * The message start string is designed to be unlikely to occur in normal data.
     * The characters are rarely used upper ASCII, not valid as UTF-8, and produce
     * a large 4-byte int at any alignment. { 0xfd, 0xe4, 0xd9, 0x42 }
     */
    pchMessageStart[0] = 0xdd;
    pchMessageStart[1] = 0xb2;
    pchMessageStart[2] = 0xc3;
    pchMessageStart[3] = 0x30;
    // bech32_hrp = "world"; // Bech32/SegWit
    vAlertPubKey = ParseHex("040840f1b1f09d6fd78576b6fa58265b6441f3ff5923830e46d7f81c292bffa5aa080fcfd99ddd2ea20ab8552cb51996ac45f405f2a164777e04bcf3582932a599");
    nDefaultPort = 11083;

    bnProofOfWorkLimit = ~uint256(0) >> 1;  // Very low difficulty for testing

    nSubsidyHalvingInterval = 1000000; // Halve every 1,000,000 blocks
    nEnforceBlockUpgradeMajority = 750;
    nRejectBlockOutdatedMajority = 950;
    nToCheckBlockUpgradeMajority = 1000;
    nMinerThreads = 1;
    nTargetTimespan =  0.35 *24 * 60 * 60; // 3.5 days
    nTargetSpacing = 300; // 5 minutes
    nTargetTimespan2 = 60 * 60;
    nTargetSpacing2 = 30;
    nMaxTipAge = 0x7fffffff;

    /**
     * Build the genesis block. Note that the output of the genesis coinbase cannot
     * be spent as it did not originally exist in the database.
     */
    const char* pszTimestamp = "17/Jul/2025 Worldcoin Relaunched To Create A Global Economy For All";
    CMutableTransaction txNew;
    txNew.nVersion = 1;
    txNew.nLockTime = 0;
    txNew.vin.resize(1);
    txNew.vout.resize(1);

    std::vector<unsigned char> scriptSig = ParseHex("04ffff001d0104");
    scriptSig.push_back((unsigned char)strlen(pszTimestamp));
    scriptSig.insert(scriptSig.end(), pszTimestamp, pszTimestamp + strlen(pszTimestamp));
    txNew.vin[0].scriptSig = CScript(scriptSig.begin(), scriptSig.end());

    txNew.vout[0].nValue = 50 * COIN; // Standard initial block reward
    txNew.vout[0].scriptPubKey = CScript() << ParseHex("040840f1b1f09d6fd78576b6fa58265b6441f3ff5923830e46d7f81c292bffa5aa080fcfd99ddd2ea20ab8552cb51996ac45f405f2a164777e04bcf3582932a599") << OP_CHECKSIG;
    genesis.vtx.clear();
    genesis.vtx.push_back(txNew);
    genesis.hashPrevBlock = 0;
    genesis.hashMerkleRoot = genesis.BuildMerkleTree();
    genesis.nVersion = 1;
    genesis.nTime    = 1752791040;

    genesis.nBits = 0x207fffff;
    genesis.nNonce   = 359;

    hashGenesisBlock = genesis.GetHash();

    // DEBUG: Print actual values for comparison
    printf("[DEBUG] Genesis PoW Hash: %s\n", genesis.GetPoWHash().ToString().c_str());
    printf("[DEBUG] Expected PoW Hash: 00706f03fd93ecea357396a230c82318313933b1953c2fd53f48af8f70a0892e\n");
    printf("[DEBUG] Genesis Merkle Root: %s\n", genesis.hashMerkleRoot.ToString().c_str());
    printf("[DEBUG] Expected Merkle Root: 134addbce23624f6b57d645ab6123d444f9767e4426d209c6e1a98921b888242\n");
    printf("[DEBUG] Genesis nTime: %u\n", genesis.nTime);
    printf("[DEBUG] Genesis nNonce: %u\n", genesis.nNonce);
    printf("[DEBUG] Genesis nBits: 0x%08x\n", genesis.nBits);
    fflush(stdout);

    assert(genesis.GetPoWHash() == uint256("0x3928e1aa604194f1a129c22bdafa94273fbd351d757816c6712c307acec547a6"));
    assert(genesis.hashMerkleRoot == uint256("0x2aeca25999208826a8b454f33daf0dea28c33935f6fb7eb2e94b5e92b80f9fb3"));

    // UPDATED: P2PKH addresses start with 'W', P2SH addresses start with '3'
    base58Prefixes[PUBKEY_ADDRESS] = list_of(73);
    base58Prefixes[SCRIPT_ADDRESS] = list_of(5);
    base58Prefixes[SECRET_KEY] =     list_of(14);
    base58Prefixes[EXT_PUBLIC_KEY] = list_of(0x04)(0x88)(0xB2)(0x1E);
    base58Prefixes[EXT_SECRET_KEY] = list_of(0x04)(0x88)(0xAD)(0xE4);

    convertSeed6(vFixedSeeds, pnSeed6_main, ARRAYLEN(pnSeed6_main));

    fRequireRPCPassword = true;
    fMiningRequiresPeers = true;
    fAllowMinDifficultyBlocks = false;
    fDefaultConsistencyChecks = false;
    fRequireStandard = true;
    fMineBlocksOnDemand = false;
    fSkipProofOfWorkCheck = false;
    fTestnetToBeDeprecatedFieldRPC = false;

    nEnforceV2AfterHeight = 0;
  }

  const Checkpoints::CCheckpointData& Checkpoints() const
  {
    return data;
  }
};
static CMainParams mainParams;

/**
 * Testnet (v1)
 */
class CTestNetParams : public CMainParams {
public:
  CTestNetParams() {
    networkID = CBaseChainParams::TESTNET;
    strNetworkID = "test";
    pchMessageStart[0] = 0xd9;
    pchMessageStart[1] = 0x8e;
    pchMessageStart[2] = 0x27;
    pchMessageStart[3] = 0xad;
    vAlertPubKey = ParseHex("0495f28eebbcc9133a2fc530bc9b435cc682c874cf1e43d0b698c9cd55d4d79e03ff");
    nDefaultPort = 19334;
    nEnforceBlockUpgradeMajority = 51;
    nRejectBlockOutdatedMajority = 75;
    nToCheckBlockUpgradeMajority = 100;
    nMinerThreads = 0;
    nTargetTimespan = 3.5 * 24 * 60 * 60; // 3.5 days
    nTargetSpacing = 300; // 5 minutes
    nMaxTipAge = 0x7fffffff;

    //! Testnet uses the same genesis block as mainnet
    hashGenesisBlock = genesis.GetHash();

    assert(genesis.GetPoWHash() == uint256("0x3928e1aa604194f1a129c22bdafa94273fbd351d757816c6712c307acec547a6"));

    vFixedSeeds.clear();
    vSeeds.clear();
    vSeeds.push_back(CDNSSeedData("worldcoin.tools", "testnet-seed.worldcoin.tools"));

    base58Prefixes[PUBKEY_ADDRESS] = list_of(25);
    base58Prefixes[SCRIPT_ADDRESS] = list_of(176);
    base58Prefixes[SECRET_KEY] =     list_of(239);
    base58Prefixes[EXT_PUBLIC_KEY] = list_of(0x04)(0x35)(0x87)(0xCF);
    base58Prefixes[EXT_SECRET_KEY] = list_of(0x04)(0x35)(0x83)(0x94);

    convertSeed6(vFixedSeeds, pnSeed6_test, ARRAYLEN(pnSeed6_test));

    fRequireRPCPassword = true;
    fMiningRequiresPeers = true;
    fAllowMinDifficultyBlocks = true;
    fDefaultConsistencyChecks = false;
    fRequireStandard = false;
    fMineBlocksOnDemand = false;
    fTestnetToBeDeprecatedFieldRPC = true;

    nEnforceV2AfterHeight = 0;
  }
  const Checkpoints::CCheckpointData& Checkpoints() const
  {
    return dataTestnet;
  }
};
static CTestNetParams testNetParams;

/**
 * Regression test
 */
class CRegTestParams : public CTestNetParams {
public:
  CRegTestParams() {
    networkID = CBaseChainParams::REGTEST;
    strNetworkID = "regtest";
    pchMessageStart[0] = 0x43;
    pchMessageStart[1] = 0xbf;
    pchMessageStart[2] = 0xe4;
    pchMessageStart[3] = 0x58;
    nSubsidyHalvingInterval = 150;
    nEnforceBlockUpgradeMajority = 750;
    nRejectBlockOutdatedMajority = 950;
    nToCheckBlockUpgradeMajority = 1000;
    nMinerThreads = 1;
    nTargetTimespan = 3.5 * 24 * 60 * 60; // 3.5 days
    nTargetSpacing = 300; // 5 minutes
    bnProofOfWorkLimit = ~uint256(0) >> 1;
    nMaxTipAge = 24 * 60 * 60;
    nDefaultPort = 12989;

    //! Regtest uses the same genesis block as mainnet
    hashGenesisBlock = genesis.GetHash();

    // In CRegTestParams:
    assert(genesis.GetPoWHash() == uint256("0x3928e1aa604194f1a129c22bdafa94273fbd351d757816c6712c307acec547a6"));

    vFixedSeeds.clear(); //! Regtest mode doesn't have any fixed seeds.
    vSeeds.clear();  //! Regtest mode doesn't have any DNS seeds.

    fRequireRPCPassword = false;
    fMiningRequiresPeers = false;
    fAllowMinDifficultyBlocks = true;
    fDefaultConsistencyChecks = true;
    fRequireStandard = false;
    fMineBlocksOnDemand = true;
    fTestnetToBeDeprecatedFieldRPC = false;

    // Worldcoin: v2 enforced using Bitcoin's supermajority rule
    nEnforceV2AfterHeight = 0;
  }
  const Checkpoints::CCheckpointData& Checkpoints() const
  {
    return dataRegtest;
  }
};
static CRegTestParams regTestParams;

/**
 * Unit test
 */
class CUnitTestParams : public CMainParams, public CModifiableParams {
public:
  CUnitTestParams() {
    networkID = CBaseChainParams::UNITTEST;
    strNetworkID = "unittest";
    nDefaultPort = 18445;
    vFixedSeeds.clear();
    vSeeds.clear();

    fRequireRPCPassword = false;
    fMiningRequiresPeers = false;
    fDefaultConsistencyChecks = true;
    fAllowMinDifficultyBlocks = false;
    fMineBlocksOnDemand = true;

    nEnforceV2AfterHeight = -1;
  }

  const Checkpoints::CCheckpointData& Checkpoints() const
  {
    // UnitTest share the same checkpoints as MAIN
    return data;
  }

  //! Published setters to allow changing values in unit test cases
  virtual void setSubsidyHalvingInterval(int anSubsidyHalvingInterval)  { nSubsidyHalvingInterval=anSubsidyHalvingInterval; }
  virtual void setEnforceBlockUpgradeMajority(int anEnforceBlockUpgradeMajority)  { nEnforceBlockUpgradeMajority=anEnforceBlockUpgradeMajority; }
  virtual void setRejectBlockOutdatedMajority(int anRejectBlockOutdatedMajority)  { nRejectBlockOutdatedMajority=anRejectBlockOutdatedMajority; }
  virtual void setToCheckBlockUpgradeMajority(int anToCheckBlockUpgradeMajority)  { nToCheckBlockUpgradeMajority=anToCheckBlockUpgradeMajority; }
  virtual void setDefaultConsistencyChecks(bool afDefaultConsistencyChecks)  { fDefaultConsistencyChecks=afDefaultConsistencyChecks; }
  virtual void setAllowMinDifficultyBlocks(bool afAllowMinDifficultyBlocks) {  fAllowMinDifficultyBlocks=afAllowMinDifficultyBlocks; }
  virtual void setSkipProofOfWorkCheck(bool afSkipProofOfWorkCheck) { fSkipProofOfWorkCheck = afSkipProofOfWorkCheck; }
};
static CUnitTestParams unitTestParams;

static CChainParams *pCurrentParams = 0;

CModifiableParams *ModifiableParams()
{
    assert(pCurrentParams);
    assert(pCurrentParams==&unitTestParams);
    return (CModifiableParams*)&unitTestParams;
}

const CChainParams &Params() {
  assert(pCurrentParams);
  return *pCurrentParams;
}

CChainParams &Params(CBaseChainParams::Network network) {
  switch (network) {
    case CBaseChainParams::MAIN:
      return mainParams;
    case CBaseChainParams::TESTNET:
      return testNetParams;
    case CBaseChainParams::REGTEST:
      return regTestParams;
    case CBaseChainParams::UNITTEST:
      return unitTestParams;
    default:
      assert(false && "Unimplemented network");
      return mainParams;
  }
}

void SelectParams(CBaseChainParams::Network network) {
  SelectBaseParams(network);
  pCurrentParams = &Params(network);
}

bool SelectParamsFromCommandLine()
{
  CBaseChainParams::Network network = NetworkIdFromCommandLine();
  if (network == CBaseChainParams::MAX_NETWORK_TYPES)
    return false;

  SelectParams(network);
  return true;
}