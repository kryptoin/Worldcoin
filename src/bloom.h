// Copyright (c) 2012-2025 The Bitcoin developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef BITCOIN_BLOOM_H
#define BITCOIN_BLOOM_H

#include "serialize.h"

#include <vector>

class COutPoint;
class CTransaction;
class uint256;

//! 20,000 items with fp rate < 0.1% or 10,000 items and <0.0001%
static const unsigned int MAX_BLOOM_FILTER_SIZE = 36000; // bytes
static const unsigned int MAX_HASH_FUNCS = 50;

/**
 * First two bits of nFlags control how much IsRelevantAndUpdate actually updates
 * The remaining bits are reserved
 */
enum bloomflags
{
    BLOOM_UPDATE_NONE = 0,
    BLOOM_UPDATE_ALL = 1,
    // Only adds outpoints to the filter if the output is a pay-to-pubkey/pay-to-multisig script
    BLOOM_UPDATE_P2PUBKEY_ONLY = 2,
    BLOOM_UPDATE_MASK = 3,
};

/**
 * BloomFilter is a probabilistic filter which SPV clients provide
 * so that we can filter the transactions we sends them.
 * 
 * This allows for significantly more efficient transaction and block downloads.
 * 
 * Because bloom filters are probabilistic, an SPV node can increase the false-
 * positive rate, making us send them transactions which aren't actually theirs, 
 * allowing clients to trade more bandwidth for more privacy by obfuscating which
 * keys are owned by them.
 */
class CBloomFilter
{
private:
    std::vector<unsigned char> vData;
    bool isFull;
    bool isEmpty;
    unsigned int nHashFuncs;
    unsigned int nTweak;
    unsigned char nFlags;

    unsigned int Hash(unsigned int nHashNum, const std::vector<unsigned char>& vDataToHash) const;

public:
    /**
     * Creates a new bloom filter which will provide the given fp rate when filled with the given number of elements
     * Note that if the given parameters will result in a filter outside the bounds of the protocol limits,
     * the filter created will be as close to the given parameters as possible within the protocol limits.
     * This will apply if nFPRate is very low or nElements is unreasonably high.
     * nTweak is a constant which is added to the seed value passed to the hash function
     * It should generally always be a random value (and is largely only exposed for unit testing)
     * nFlags should be one of the BLOOM_UPDATE_* enums (not _MASK)
     */
    CBloomFilter(unsigned int nElements, double nFPRate, unsigned int nTweak, unsigned char nFlagsIn);
    CBloomFilter() : isFull(true), isEmpty(false), nHashFuncs(0), nTweak(0), nFlags(0) {}

    ADD_SERIALIZE_METHODS;

    template <typename Stream, typename Operation>
    inline void SerializationOp(Stream& s, Operation ser_action, int nType, int nVersion) {
        READWRITE(vData);
        READWRITE(nHashFuncs);
        READWRITE(nTweak);
        READWRITE(nFlags);
    }

    void insert(const std::vector<unsigned char>& vKey);
    void insert(const COutPoint& outpoint);
    void insert(const uint256& hash);

    bool contains(const std::vector<unsigned char>& vKey) const;
    bool contains(const COutPoint& outpoint) const;
    bool contains(const uint256& hash) const;

    void clear();

    //! True if the size is <= MAX_BLOOM_FILTER_SIZE and the number of hash functions is <= MAX_HASH_FUNCS
    //! (catch a filter which was just deserialized which was too big)
    bool IsWithinSizeConstraints() const;

    //! Also adds any outputs which match the filter to the filter (to match their spending txes)
    bool IsRelevantAndUpdate(const CTransaction& tx);

    //! Checks for empty and full filters to avoid wasting cpu
    void UpdateEmptyFull();
};

#endif // BITCOIN_BLOOM_H
