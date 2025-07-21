// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2025 The Bitcoin developers
// Copyright (c) 2025 The Worldcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef BITCOIN_CHAIN_H
#define BITCOIN_CHAIN_H

#include "primitives/block.h"
#include "pow.h"
#include "tinyformat.h"
#include "uint256.h"

#include <vector>

#include <boost/foreach.hpp>

/** A "reason" why a transaction was invalid, suitable for determining whether the
  * provider of the transaction should be banned/ignored/disconnected/etc.
  */
enum class TxValidationResult {
	TX_RESULT_UNSET = 0,
	TX_CONSENSUS,
	TX_INPUTS_NOT_STANDARD,
	TX_NOT_STANDARD,
	TX_MISSING_INPUTS,
	TX_PREMATURE_SPEND,
	TX_WITNESS_MUTATED,
	TX_WITNESS_STRIPPED,
	TX_CONFLICT,
	TX_MEMPOOL_POLICY,
	TX_NO_MEMPOOL,
	TX_RECONSIDERABLE,
	TX_UNKNOWN,
    // Legacy compatibility values
	TX_INVALID_FORMAT,
	TX_DUPLICATE_INPUTS,
	TX_NEGATIVE_OUTPUT,
	TX_OUTPUT_SUM_OVERFLOW,
	TX_INVALID_SIGNATURE
};

/** A "reason" why a block was invalid, suitable for determining whether the
  * provider of the block should be banned/ignored/disconnected/etc.
  */
enum class BlockValidationResult {
	BLOCK_RESULT_UNSET = 0,
	BLOCK_CONSENSUS,
	BLOCK_CACHED_INVALID,
	BLOCK_INVALID_HEADER,
	BLOCK_MUTATED,
	BLOCK_MISSING_PREV,
	BLOCK_INVALID_PREV,
	BLOCK_TIME_FUTURE,
	BLOCK_HEADER_LOW_WORK,
    // Legacy compatibility and additional checks
	BLOCK_INVALID_MERKLE,
	BLOCK_TOO_BIG,
	BLOCK_INVALID_COINBASE,
	BLOCK_DUPLICATE_TX,
	BLOCK_INVALID_TX
};

/** Validation state for tracking validation results and error information */
class CValidationState {
private:
	enum mode_state {
		MODE_VALID,
		MODE_INVALID,
		MODE_ERROR,
	} mode;
	int nDoS;
	std::string strRejectReason;
	unsigned char chRejectCode;
	bool corruptionPossible;
	std::string strDebugMessage;
	TxValidationResult tx_result;
	BlockValidationResult block_result;

public:
	CValidationState() : mode(MODE_VALID), nDoS(0), chRejectCode(0),
						corruptionPossible(false),
						tx_result(TxValidationResult::TX_RESULT_UNSET),
						block_result(BlockValidationResult::BLOCK_RESULT_UNSET) {}

	bool DoS(int level, bool ret = false,
			 unsigned char chRejectCodeIn=0, const std::string &strRejectReasonIn="",
			 bool corruptionIn=false,
			 const std::string &strDebugMessageIn="") {
		chRejectCode = chRejectCodeIn;
		strRejectReason = strRejectReasonIn;
		corruptionPossible = corruptionIn;
		strDebugMessage = strDebugMessageIn;
		if (mode == MODE_ERROR)
			return ret;
		nDoS += level;
		mode = MODE_INVALID;
		return ret;
	}

	bool Invalid(bool ret = false,
				 unsigned char _chRejectCode=0, const std::string &_strRejectReason="",
				 const std::string &_strDebugMessage="") {
		return DoS(0, ret, _chRejectCode, _strRejectReason, false, _strDebugMessage);
	}

	bool Error(const std::string& strRejectReasonIn) {
		if (mode == MODE_VALID)
			strRejectReason = strRejectReasonIn;
		mode = MODE_ERROR;
		return false;
	}

	bool IsValid() const { return mode == MODE_VALID; }
	bool IsInvalid() const { return mode == MODE_INVALID; }
	bool IsError() const { return mode == MODE_ERROR; }

	bool IsInvalid(int &nDoSOut) const {
		if (IsInvalid()) {
			nDoSOut = nDoS;
			return true;
		}
		return false;
	}

	bool CorruptionPossible() const { return corruptionPossible; }

	void SetCorruptionPossible() { corruptionPossible = true; }

	unsigned char GetRejectCode() const { return chRejectCode; }
	std::string GetRejectReason() const { return strRejectReason; }
	std::string GetDebugMessage() const { return strDebugMessage; }

	void SetTxResult(TxValidationResult result) { tx_result = result; }
	void SetBlockResult(BlockValidationResult result) { block_result = result; }

	TxValidationResult GetTxResult() const { return tx_result; }
	BlockValidationResult GetBlockResult() const { return block_result; }
};

struct CDiskBlockPos
{
	int nFile;
	unsigned int nPos;

	ADD_SERIALIZE_METHODS;

	template <typename Stream, typename Operation>
	inline void SerializationOp(Stream& s, Operation ser_action, int nType, int nVersion) {
		READWRITE(VARINT(nFile));
		READWRITE(VARINT(nPos));
	}

	CDiskBlockPos() {
		SetNull();
	}

	CDiskBlockPos(int nFileIn, unsigned int nPosIn) {
		nFile = nFileIn;
		nPos = nPosIn;
	}

	friend bool operator==(const CDiskBlockPos &a, const CDiskBlockPos &b) {
		return (a.nFile == b.nFile && a.nPos == b.nPos);
	}

	friend bool operator!=(const CDiskBlockPos &a, const CDiskBlockPos &b) {
		return !(a == b);
	}

	void SetNull() { nFile = -1; nPos = 0; }
	bool IsNull() const { return (nFile == -1); }
};

enum BlockStatus {
	BLOCK_VALID_UNKNOWN      =    0,
	BLOCK_VALID_HEADER       =    1,
	BLOCK_VALID_TREE         =    2,

	/**
	 * Only first tx is coinbase, 2 <= coinbase input script length <= 100, transactions valid, no duplicate txids,
	 * sigops, size, merkle root. Implies all parents are at least TREE but not necessarily TRANSACTIONS. When all
	 * parent blocks also have TRANSACTIONS, CBlockIndex::nChainTx will be set.
	 */
	BLOCK_VALID_TRANSACTIONS =    3,
	BLOCK_VALID_CHAIN        =    4,
	BLOCK_VALID_SCRIPTS      =    5,

	BLOCK_VALID_MASK         =   BLOCK_VALID_HEADER | BLOCK_VALID_TREE | BLOCK_VALID_TRANSACTIONS |
								 BLOCK_VALID_CHAIN | BLOCK_VALID_SCRIPTS,

	BLOCK_HAVE_DATA          =    8,
	BLOCK_HAVE_UNDO          =   16,
	BLOCK_HAVE_MASK          =   BLOCK_HAVE_DATA | BLOCK_HAVE_UNDO,

	BLOCK_FAILED_VALID       =   32,
	BLOCK_FAILED_CHILD       =   64,
	BLOCK_FAILED_MASK        =   BLOCK_FAILED_VALID | BLOCK_FAILED_CHILD,
};

/** The block chain is a tree shaped structure starting with the
 * genesis block at the root, with each block potentially having multiple
 * candidates to be the next block. A blockindex may have multiple pprev pointing
 * to it, but at most one of them can be part of the currently active branch.
 */
class CBlockIndex
{
public:
	const uint256* phashBlock;
	CBlockIndex* pprev;
	CBlockIndex* pskip;
	int nHeight;
	int nFile;
	unsigned int nDataPos;
	unsigned int nUndoPos;
	uint256 nChainWork;
	unsigned int nTx;
	unsigned int nChainTx;
	unsigned int nStatus;
	int nVersion;
	uint256 hashMerkleRoot;
	unsigned int nTime;
	unsigned int nBits;
	unsigned int nNonce;
	uint32_t nSequenceId;

	void SetNull()
	{
		phashBlock = NULL;
		pprev = NULL;
		pskip = NULL;
		nHeight = 0;
		nFile = 0;
		nDataPos = 0;
		nUndoPos = 0;
		nChainWork = 0;
		nTx = 0;
		nChainTx = 0;
		nStatus = 0;
		nSequenceId = 0;

		nVersion       = 0;
		hashMerkleRoot = 0;
		nTime          = 0;
		nBits          = 0;
		nNonce         = 0;
	}

	CBlockIndex()
	{
		SetNull();
	}

	CBlockIndex(const CBlockHeader& block)
	{
		SetNull();

		nVersion       = block.nVersion;
		hashMerkleRoot = block.hashMerkleRoot;
		nTime          = block.nTime;
		nBits          = block.nBits;
		nNonce         = block.nNonce;
	}

	CDiskBlockPos GetBlockPos() const {
		CDiskBlockPos ret;
		if (nStatus & BLOCK_HAVE_DATA) {
			ret.nFile = nFile;
			ret.nPos  = nDataPos;
		}
		return ret;
	}

	CDiskBlockPos GetUndoPos() const {
		CDiskBlockPos ret;
		if (nStatus & BLOCK_HAVE_UNDO) {
			ret.nFile = nFile;
			ret.nPos  = nUndoPos;
		}
		return ret;
	}

	CBlockHeader GetBlockHeader() const
	{
		CBlockHeader block;
		block.nVersion       = nVersion;
		if (pprev)
			block.hashPrevBlock = pprev->GetBlockHash();
		block.hashMerkleRoot = hashMerkleRoot;
		block.nTime          = nTime;
		block.nBits          = nBits;
		block.nNonce         = nNonce;
		return block;
	}

	uint256 GetBlockHash() const
	{
		return *phashBlock;
	}

	uint256 GetBlockPoWHash() const
	{
		return GetBlockHeader().GetPoWHash();
	}

	int64_t GetBlockTime() const
	{
		return (int64_t)nTime;
	}

	enum { nMedianTimeSpan=11 };

	int64_t GetMedianTimePast() const
	{
		int64_t pmedian[nMedianTimeSpan];
		int64_t* pbegin = &pmedian[nMedianTimeSpan];
		int64_t* pend = &pmedian[nMedianTimeSpan];

		const CBlockIndex* pindex = this;
		for (int i = 0; i < nMedianTimeSpan && pindex; i++, pindex = pindex->pprev)
			*(--pbegin) = pindex->GetBlockTime();

		std::sort(pbegin, pend);
		return pbegin[(pend - pbegin)/2];
	}

	/**
	 * Returns true if there are nRequired or more blocks of minVersion or above
	 * in the last Params().ToCheckBlockUpgradeMajority() blocks, starting at pstart
	 * and going backwards.
	 */
	static bool IsSuperMajority(int minVersion, const CBlockIndex* pstart,
								unsigned int nRequired);

	std::string ToString() const
	{
		return strprintf("CBlockIndex(pprev=%p, nHeight=%d, merkle=%s, hashBlock=%s)",
			pprev, nHeight,
			hashMerkleRoot.ToString(),
			GetBlockHash().ToString());
	}

	bool IsValid(enum BlockStatus nUpTo = BLOCK_VALID_TRANSACTIONS) const
	{
		assert(!(nUpTo & ~BLOCK_VALID_MASK));
		if (nStatus & BLOCK_FAILED_MASK)
			return false;
		return ((nStatus & BLOCK_VALID_MASK) >= nUpTo);
	}

	bool RaiseValidity(enum BlockStatus nUpTo)
	{
		assert(!(nUpTo & ~BLOCK_VALID_MASK));
		if (nStatus & BLOCK_FAILED_MASK)
			return false;
		if ((nStatus & BLOCK_VALID_MASK) < nUpTo) {
			nStatus = (nStatus & ~BLOCK_VALID_MASK) | nUpTo;
			return true;
		}
		return false;
	}

	bool IsValidExtended(enum BlockStatus nUpTo, CValidationState& state) const
	{
		if (!IsValid(nUpTo)) {
			if (nStatus & BLOCK_FAILED_VALID) {
				state.Invalid(false, 0, "block-validation-failed", "Block failed validation");
				state.SetBlockResult(BlockValidationResult::BLOCK_CONSENSUS);
			} else if (nStatus & BLOCK_FAILED_CHILD) {
				state.Invalid(false, 0, "block-child-failed", "Block has invalid child");
				state.SetBlockResult(BlockValidationResult::BLOCK_INVALID_PREV);
			}
			return false;
		}
		return true;
	}

	void BuildSkip();

	CBlockIndex* GetAncestor(int height);
	const CBlockIndex* GetAncestor(int height) const;
};

/** Used to marshal pointers into hashes for db storage. */
class CDiskBlockIndex : public CBlockIndex
{
public:
	uint256 hashPrev;

	CDiskBlockIndex() {
		hashPrev = 0;
	}

	explicit CDiskBlockIndex(CBlockIndex* pindex) : CBlockIndex(*pindex) {
		hashPrev = (pprev ? pprev->GetBlockHash() : 0);
	}

	ADD_SERIALIZE_METHODS;

	template <typename Stream, typename Operation>
	inline void SerializationOp(Stream& s, Operation ser_action, int nType, int nVersion) {
		if (!(nType & SER_GETHASH))
			READWRITE(VARINT(nVersion));

		READWRITE(VARINT(nHeight));
		READWRITE(VARINT(nStatus));
		READWRITE(VARINT(nTx));
		if (nStatus & (BLOCK_HAVE_DATA | BLOCK_HAVE_UNDO))
			READWRITE(VARINT(nFile));
		if (nStatus & BLOCK_HAVE_DATA)
			READWRITE(VARINT(nDataPos));
		if (nStatus & BLOCK_HAVE_UNDO)
			READWRITE(VARINT(nUndoPos));

		READWRITE(this->nVersion);
		READWRITE(hashPrev);
		READWRITE(hashMerkleRoot);
		READWRITE(nTime);
		READWRITE(nBits);
		READWRITE(nNonce);
	}

	uint256 GetBlockHash() const
	{
		CBlockHeader block;
		block.nVersion        = nVersion;
		block.hashPrevBlock   = hashPrev;
		block.hashMerkleRoot  = hashMerkleRoot;
		block.nTime           = nTime;
		block.nBits           = nBits;
		block.nNonce          = nNonce;
		return block.GetHash();
	}

	std::string ToString() const
	{
		std::string str = "CDiskBlockIndex(";
		str += CBlockIndex::ToString();
		str += strprintf("\n                hashBlock=%s, hashPrev=%s)",
			GetBlockHash().ToString(),
			hashPrev.ToString());
		return str;
	}
};

/** An in-memory indexed chain of blocks. */
class CChain {
private:
	std::vector<CBlockIndex*> vChain;

public:
	/** Returns the index entry for the genesis block of this chain, or NULL if none. */
	CBlockIndex *Genesis() const {
		return vChain.size() > 0 ? vChain[0] : NULL;
	}

	/** Returns the index entry for the tip of this chain, or NULL if none. */
	CBlockIndex *Tip() const {
		return vChain.size() > 0 ? vChain[vChain.size() - 1] : NULL;
	}

	/** Returns the index entry at a particular height in this chain, or NULL if no such height exists. */
	CBlockIndex *operator[](int nHeight) const {
		if (nHeight < 0 || nHeight >= (int)vChain.size())
			return NULL;
		return vChain[nHeight];
	}

	/** Compare two chains efficiently. */
	friend bool operator==(const CChain &a, const CChain &b) {
		return a.vChain.size() == b.vChain.size() &&
			   a.vChain[a.vChain.size() - 1] == b.vChain[b.vChain.size() - 1];
	}

	/** Efficiently check whether a block is present in this chain. */
	bool Contains(const CBlockIndex *pindex) const {
		return (*this)[pindex->nHeight] == pindex;
	}

	/** Find the successor of a block in this chain, or NULL if the given index is not found or is the tip. */
	CBlockIndex *Next(const CBlockIndex *pindex) const {
		if (Contains(pindex))
			return (*this)[pindex->nHeight + 1];
		else
			return NULL;
	}

	/** Return the maximal height in the chain. Is equal to chain.Tip() ? chain.Tip()->nHeight : -1. */
	int Height() const {
		return vChain.size() - 1;
	}

	/** Set/initialize a chain with a given tip. */
	void SetTip(CBlockIndex *pindex);

	/** Return a CBlockLocator that refers to a block in this chain (by default the tip). */
	CBlockLocator GetLocator(const CBlockIndex *pindex = NULL) const;

	/** Find the last common block between this chain and a block index entry. */
	const CBlockIndex *FindFork(const CBlockIndex *pindex) const;

	/** Enhanced validation method for chain consistency */
	bool ValidateChain(CValidationState& state, int nCheckLevel = 3, int nCheckDepth = 1000) const;
};

// Helper functions for validation result strings
std::string TxValidationResultToString(TxValidationResult result);
std::string BlockValidationResultToString(BlockValidationResult result);

#endif