// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2025 The Bitcoin developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "amount.h"

#include "tinyformat.h"

CFeeRate::CFeeRate(const CAmount& nFeePaid, size_t nSize)
{
    if (nSize > 0)
        nSatoshisPerK = nFeePaid*1000/nSize;
    else
        nSatoshisPerK = 0;
}

CAmount CFeeRate::GetFee(size_t nSize) const
{
    // Round up nSize to the nearest 1000
    CAmount mod = nSize % 1000;
    if (mod > 0)
        nSize = nSize - mod + 1000;
    CAmount nFee = nSatoshisPerK*nSize / 1000;

    if (nFee == 0 && nSatoshisPerK > 0)
        nFee = nSatoshisPerK;

    return nFee;
}

std::string CFeeRate::ToString() const
{
    return strprintf("%d.%08d WDC/kB", nSatoshisPerK / COIN, nSatoshisPerK % COIN);
}
