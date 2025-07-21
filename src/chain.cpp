// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2025 The Bitcoin developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "chain.h"
#include "util.h" // For LogPrintf if available
#include "primitives/transaction.h"
#include "consensus/consensus.h"
#include "script/script.h"
#include "hash.h"
#include <algorithm>

#include "chainparams.h"
#include "coins.h"
#include "main.h"
#include "utilmoneystr.h"
#include "utiltime.h"
#include "timedata.h"


using namespace std;

/**
 * CChain implementation
 */
void CChain::SetTip(CBlockIndex *pindex) {
    if (pindex == NULL) {
        vChain.clear();
        return;
    }
    vChain.resize(pindex->nHeight + 1);
    while (pindex && vChain[pindex->nHeight] != pindex) {
        vChain[pindex->nHeight] = pindex;
        pindex = pindex->pprev;
    }
}

CBlockLocator CChain::GetLocator(const CBlockIndex *pindex) const {
    int nStep = 1;
    std::vector<uint256> vHave;
    vHave.reserve(32);

    if (!pindex)
        pindex = Tip();
    while (pindex) {
        vHave.push_back(pindex->GetBlockHash());

        if (pindex->nHeight == 0)
            break;

        int nHeight = std::max(pindex->nHeight - nStep, 0);
        if (Contains(pindex)) {
            pindex = (*this)[nHeight];
        } else {
            pindex = pindex->GetAncestor(nHeight);
        }
        if (vHave.size() > 10)
            nStep *= 2;
    }

    return CBlockLocator(vHave);
}

const CBlockIndex *CChain::FindFork(const CBlockIndex *pindex) const {
    if (pindex->nHeight > Height())
        pindex = pindex->GetAncestor(Height());
    while (pindex && !Contains(pindex))
        pindex = pindex->pprev;
    return pindex;
}

bool CChain::ValidateChain(CValidationState& state, int nCheckLevel, int nCheckDepth) const {
    if (vChain.empty()) {
        return state.Error("chain-empty");
    }

    CBlockIndex* pindex = Tip();
    CBlockIndex* pindexFailure = NULL;
    int nGoodTransactions = 0;

    // Limit check depth
    int nCheckStart = std::max(0, Height() - nCheckDepth);

    for (int i = Height(); i >= nCheckStart; i--) {
        pindex = vChain[i];

        if (!pindex) {
            pindexFailure = pindex;
            state.Invalid(false, 0, "chain-null-index",
                         strprintf("Null block index at height %d", i));
            state.SetBlockResult(BlockValidationResult::BLOCK_CONSENSUS);
            return false;
        }

        // Check height consistency
        if (pindex->nHeight != i) {
            pindexFailure = pindex;
            state.Invalid(false, 0, "chain-height-mismatch",
                         strprintf("Block height mismatch: expected %d, got %d", i, pindex->nHeight));
            state.SetBlockResult(BlockValidationResult::BLOCK_CONSENSUS);
            return false;
        }

        // Check parent-child relationship
        if (i > 0 && pindex->pprev != vChain[i-1]) {
            pindexFailure = pindex;
            state.Invalid(false, 0, "chain-parent-mismatch",
                         strprintf("Block parent mismatch at height %d", i));
            state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_PREV);
            return false;
        }

        // Basic validation level checks
        if (nCheckLevel >= 1) {
            if (!pindex->IsValid(BLOCK_VALID_TREE)) {
                pindexFailure = pindex;
                state.Invalid(false, 0, "chain-invalid-tree",
                             strprintf("Block at height %d failed tree validation", i));
                state.SetBlockResult(BlockValidationResult::BLOCK_CONSENSUS);
                return false;
            }
        }

        // Transaction validation level checks
        if (nCheckLevel >= 2) {
            if (!pindex->IsValid(BLOCK_VALID_TRANSACTIONS)) {
                pindexFailure = pindex;
                state.Invalid(false, 0, "chain-invalid-transactions",
                             strprintf("Block at height %d failed transaction validation", i));
                state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_TX);
                return false;
            }
            nGoodTransactions += pindex->nTx;
        }

        // Script validation level checks
        if (nCheckLevel >= 3) {
            if (!pindex->IsValid(BLOCK_VALID_SCRIPTS)) {
                pindexFailure = pindex;
                state.Invalid(false, 0, "chain-invalid-scripts",
                             strprintf("Block at height %d failed script validation", i));
                state.SetBlockResult(BlockValidationResult::BLOCK_CONSENSUS);
                return false;
            }
        }

        // Chain work progression check
        if (nCheckLevel >= 4 && i > 0) {
            if (pindex->nChainWork <= pindex->pprev->nChainWork) {
                pindexFailure = pindex;
                state.Invalid(false, 0, "chain-work-regression",
                             strprintf("Chain work regression at height %d", i));
                state.SetBlockResult(BlockValidationResult::BLOCK_HEADER_LOW_WORK);
                return false;
            }
        }
    }

    return true;
}

/**
 * CBlockIndex implementation
 */
namespace {
    // Helper function for skip height calculation
    int InvertLowestOne(int n) {
        return n & (n - 1);
    }

    int GetSkipHeight(int height) {
        if (height < 2)
            return 0;

        // Determine which height to jump back to. Any number strictly lower than height is acceptable,
        // but the following expression seems to perform well in simulations (max 110 steps to go back up to 2**18 blocks).
        return (height & 1) ? InvertLowestOne(InvertLowestOne(height - 1)) + 1 : InvertLowestOne(height);
    }

} // namespace

bool CBlockIndex::IsSuperMajority(int minVersion, const CBlockIndex* pstart,
                                unsigned int nRequired) {
    unsigned int nFound = 0;
    for (unsigned int i = 0; i < Params().ToCheckBlockUpgradeMajority() && nFound < nRequired && pstart != NULL; i++) {
        if (pstart->nVersion >= minVersion)
            ++nFound;
        pstart = pstart->pprev;
    }
    return (nFound >= nRequired);
}

void CBlockIndex::BuildSkip() {
    if (pprev)
        pskip = pprev->GetAncestor(GetSkipHeight(nHeight));
}

CBlockIndex* CBlockIndex::GetAncestor(int height) {
    if (height > nHeight || height < 0)
        return NULL;

    CBlockIndex* pindexWalk = this;
    int heightWalk = nHeight;
    while (heightWalk > height) {
        int heightSkip = GetSkipHeight(heightWalk);
        int heightSkipPrev = GetSkipHeight(heightWalk - 1);
        if (pindexWalk->pskip != NULL &&
            (heightSkip == height ||
             (heightSkip > height && !(heightSkipPrev < heightSkip - 2 &&
                                     heightSkipPrev >= height)))) {
            // Only follow pskip if pprev->pskip isn't better than pskip->pprev.
            pindexWalk = pindexWalk->pskip;
            heightWalk = heightSkip;
        } else {
            assert(pindexWalk->pprev);
            pindexWalk = pindexWalk->pprev;
            heightWalk--;
        }
    }
    return pindexWalk;
}

const CBlockIndex* CBlockIndex::GetAncestor(int height) const {
    return const_cast<CBlockIndex*>(this)->GetAncestor(height);
}

// Helper function implementations
std::string TxValidationResultToString(TxValidationResult result) {
    switch (result) {
        case TxValidationResult::TX_RESULT_UNSET: return "unset";
        case TxValidationResult::TX_CONSENSUS: return "consensus";
        case TxValidationResult::TX_INPUTS_NOT_STANDARD: return "inputs-not-standard";
        case TxValidationResult::TX_NOT_STANDARD: return "not-standard";
        case TxValidationResult::TX_MISSING_INPUTS: return "missing-inputs";
        case TxValidationResult::TX_PREMATURE_SPEND: return "premature-spend";
        case TxValidationResult::TX_WITNESS_MUTATED: return "witness-mutated";
        case TxValidationResult::TX_WITNESS_STRIPPED: return "witness-stripped";
        case TxValidationResult::TX_CONFLICT: return "conflict";
        case TxValidationResult::TX_MEMPOOL_POLICY: return "mempool-policy";
        case TxValidationResult::TX_NO_MEMPOOL: return "no-mempool";
        case TxValidationResult::TX_RECONSIDERABLE: return "reconsiderable";
        case TxValidationResult::TX_UNKNOWN: return "unknown";
        case TxValidationResult::TX_INVALID_FORMAT: return "invalid-format";
        case TxValidationResult::TX_DUPLICATE_INPUTS: return "duplicate-inputs";
        case TxValidationResult::TX_NEGATIVE_OUTPUT: return "negative-output";
        case TxValidationResult::TX_OUTPUT_SUM_OVERFLOW: return "output-sum-overflow";
        case TxValidationResult::TX_INVALID_SIGNATURE: return "invalid-signature";
        default: return "unknown-error";
    }
}

std::string BlockValidationResultToString(BlockValidationResult result) {
    switch (result) {
        case BlockValidationResult::BLOCK_RESULT_UNSET: return "unset";
        case BlockValidationResult::BLOCK_CONSENSUS: return "consensus";
        case BlockValidationResult::BLOCK_CACHED_INVALID: return "cached-invalid";
        case BlockValidationResult::BLOCK_INVALID_HEADER: return "invalid-header";
        case BlockValidationResult::BLOCK_MUTATED: return "mutated";
        case BlockValidationResult::BLOCK_MISSING_PREV: return "missing-prev";
        case BlockValidationResult::BLOCK_INVALID_PREV: return "invalid-prev";
        case BlockValidationResult::BLOCK_TIME_FUTURE: return "time-future";
        case BlockValidationResult::BLOCK_HEADER_LOW_WORK: return "header-low-work";
        case BlockValidationResult::BLOCK_INVALID_MERKLE: return "invalid-merkle";
        case BlockValidationResult::BLOCK_TOO_BIG: return "too-big";
        case BlockValidationResult::BLOCK_INVALID_COINBASE: return "invalid-coinbase";
        case BlockValidationResult::BLOCK_DUPLICATE_TX: return "duplicate-tx";
        case BlockValidationResult::BLOCK_INVALID_TX: return "invalid-tx";
        default: return "unknown-error";
    }
}

// Enhanced validation helper functions for transaction checking
namespace ValidationHelpers {

    bool CheckTransactionBasic(const CTransaction& tx, CValidationState& state) {
        // Check for empty inputs/outputs
        if (tx.vin.empty()) {
            state.SetTxResult(TxValidationResult::TX_INVALID_FORMAT);
            return state.DoS(10, false, 0, "bad-txns-vin-empty");
        }
        if (tx.vout.empty()) {
            state.SetTxResult(TxValidationResult::TX_INVALID_FORMAT);
            return state.DoS(10, false, 0, "bad-txns-vout-empty");
        }

        // Size limits (legacy from Bitcoin 0.10.4 era, but modernized)
        if (tx.GetSerializeSize(SER_NETWORK, PROTOCOL_VERSION) > MAX_BLOCK_SIZE) {
            state.SetTxResult(TxValidationResult::TX_CONSENSUS);
            return state.DoS(100, false, 0, "bad-txns-oversize");
        }

        // Check for negative or overflow output values
        CAmount nValueOut = 0;
        for (const auto& txout : tx.vout) {
            if (txout.nValue < 0) {
                state.SetTxResult(TxValidationResult::TX_NEGATIVE_OUTPUT);
                return state.DoS(100, false, 0, "bad-txns-vout-negative");
            }
            if (txout.nValue > MAX_MONEY) {
                state.SetTxResult(TxValidationResult::TX_OUTPUT_SUM_OVERFLOW);
                return state.DoS(100, false, 0, "bad-txns-vout-toolarge");
            }
            nValueOut += txout.nValue;
            if (!MoneyRange(nValueOut)) {
                state.SetTxResult(TxValidationResult::TX_OUTPUT_SUM_OVERFLOW);
                return state.DoS(100, false, 0, "bad-txns-txouttotal-toolarge");
            }
        }

        // Check for duplicate inputs
        set<COutPoint> vInOutPoints;
        for (const auto& txin : tx.vin) {
            if (vInOutPoints.count(txin.prevout)) {
                state.SetTxResult(TxValidationResult::TX_DUPLICATE_INPUTS);
                return state.DoS(100, false, 0, "bad-txns-inputs-duplicate");
            }
            vInOutPoints.insert(txin.prevout);
        }

        if (tx.IsCoinBase()) {
            if (tx.vin[0].scriptSig.size() < 2 || tx.vin[0].scriptSig.size() > 100) {
                state.SetTxResult(TxValidationResult::TX_CONSENSUS);
                return state.DoS(100, false, 0, "bad-cb-length");
            }
        } else {
            for (const auto& txin : tx.vin) {
                if (txin.prevout.IsNull()) {
                    state.SetTxResult(TxValidationResult::TX_CONSENSUS);
                    return state.DoS(10, false, 0, "bad-txns-prevout-null");
                }
            }
        }

        return true;
    }

    bool CheckTransactionInputs(const CTransaction& tx, CValidationState& state,
                              const CCoinsViewCache& inputs, int nSpendHeight) {
        // This will be called from main validation code
        if (!tx.IsCoinBase()) {
            if (!inputs.HaveInputs(tx)) {
                state.SetTxResult(TxValidationResult::TX_MISSING_INPUTS);
                return state.Invalid(false, 0, "bad-txns-inputs-missingorspent",
                                   strprintf("%s: inputs missing/spent", tx.GetHash().ToString()));
            }

            CAmount nValueIn = 0;
            CAmount nFees = 0;
            for (unsigned int i = 0; i < tx.vin.size(); i++) {
                const COutPoint &prevout = tx.vin[i].prevout;
                const CCoins *coins = inputs.AccessCoins(prevout.hash);
                assert(coins);

                // If prev is coinbase, check that it's matured
                if (coins->IsCoinBase()) {
                    if (nSpendHeight - coins->nHeight < COINBASE_MATURITY) {
                        state.SetTxResult(TxValidationResult::TX_PREMATURE_SPEND);
                        return state.Invalid(false, 0, "bad-txns-premature-spend-of-coinbase",
                                           strprintf("tried to spend coinbase at depth %d", nSpendHeight - coins->nHeight));
                    }
                }

                // Check for negative or overflow input values
                nValueIn += coins->vout[prevout.n].nValue;
                if (!MoneyRange(coins->vout[prevout.n].nValue) || !MoneyRange(nValueIn)) {
                    state.SetTxResult(TxValidationResult::TX_CONSENSUS);
                    return state.DoS(100, false, 0, "bad-txns-inputvalues-outofrange");
                }
            }

            CAmount nValueOut = tx.GetValueOut();
            if (nValueIn < nValueOut) {
                state.SetTxResult(TxValidationResult::TX_CONSENSUS);
                return state.DoS(100, false, 0, "bad-txns-in-belowout");
            }

            // Tally transaction fees
            CAmount nTxFee = nValueIn - nValueOut;
            if (nTxFee < 0) {
                state.SetTxResult(TxValidationResult::TX_CONSENSUS);
                return state.DoS(100, false, 0, "bad-txns-fee-negative");
            }
            nFees += nTxFee;
            if (!MoneyRange(nFees)) {
                state.SetTxResult(TxValidationResult::TX_CONSENSUS);
                return state.DoS(100, false, 0, "bad-txns-fee-outofrange");
            }
        }
        return true;
    }

    bool CheckBlockBasic(const CBlock& block, CValidationState& state, bool fCheckPOW) {
        // These are checks that are independent of context
        // that can be verified before saving an orphan block.

        // Check the header
        if (fCheckPOW && !CheckProofOfWork(block.GetPoWHash(), block.nBits)) {
            state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_HEADER);
            return state.DoS(50, false, 0, "high-hash", false, "proof of work failed");
        }

        // Check the merkle root.
        {
            uint256 hashMerkleRoot2 = block.BuildMerkleTree();
            if (block.hashMerkleRoot != hashMerkleRoot2) {
                state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_MERKLE);
                return state.DoS(100, false, 0, "bad-merkleroot", false, "hashMerkleRoot mismatch");
            }
        }

        // Check for duplicate txids
        set<uint256> uniqueTx;
        for (const auto& tx : block.vtx) {
            uniqueTx.insert(tx.GetHash());
        }
        if (uniqueTx.size() != block.vtx.size()) {
            state.SetBlockResult(BlockValidationResult::BLOCK_DUPLICATE_TX);
            return state.DoS(100, false, 0, "bad-txns-duplicate", false, "duplicate transaction");
        }

        // First transaction must be coinbase, the rest must not be
        if (block.vtx.empty() || !block.vtx[0].IsCoinBase()) {
            state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_COINBASE);
            return state.DoS(100, false, 0, "bad-cb-missing", false, "first tx is not coinbase");
        }
        for (unsigned int i = 1; i < block.vtx.size(); i++) {
            if (block.vtx[i].IsCoinBase()) {
                state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_COINBASE);
                return state.DoS(100, false, 0, "bad-cb-multiple", false, "more than one coinbase");
            }
        }

        // Check transactions
        for (const auto& tx : block.vtx) {
            if (!CheckTransactionBasic(tx, state)) {
                state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_TX);
                return false; // state set by CheckTransactionBasic
            }
        }

        unsigned int nSigOps = 0;
        for (const auto& tx : block.vtx) {
            nSigOps += GetLegacySigOpCount(tx);
        }
        if (nSigOps > MAX_BLOCK_SIGOPS) {
            state.SetBlockResult(BlockValidationResult::BLOCK_CONSENSUS);
            return state.DoS(100, false, 0, "bad-blk-sigops", false, "too many checksigs");
        }

        // Size limits
        if (block.vtx.empty() || block.vtx.size() > MAX_BLOCK_SIZE ||
            ::GetSerializeSize(block, SER_NETWORK, PROTOCOL_VERSION) > MAX_BLOCK_SIZE) {
            state.SetBlockResult(BlockValidationResult::BLOCK_TOO_BIG);
            return state.DoS(100, false, 0, "bad-blk-length", false, "size limits failed");
        }

        return true;
    }

    bool CheckBlockHeader(const CBlockHeader& block, CValidationState& state, bool fCheckPOW) {
        // Check proof of work matches claimed amount
        if (fCheckPOW && !CheckProofOfWork(block.GetPoWHash(), block.nBits)) {
            state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_HEADER);
            return state.DoS(50, false, 0, "high-hash", false, "proof of work failed");
        }

        // Check timestamp
        if (block.GetBlockTime() > GetAdjustedTime() + 2 * 60 * 60) { // 2 hours
            state.SetBlockResult(BlockValidationResult::BLOCK_TIME_FUTURE);
            return state.Invalid(false, 0, "time-too-new", "block timestamp too far in the future");
        }

        return true;
    }

} // namespace ValidationHelpers