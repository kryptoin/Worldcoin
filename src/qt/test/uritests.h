// Copyright (c) 2009-2025 The Bitcoin developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef BITCOIN_QT_TEST_URITESTS_H
#define BITCOIN_QT_TEST_URITESTS_H

#include <QObject>
#include <QTest>

class URITests : public QObject
{
    Q_OBJECT

private slots:
    void uriTests();
};

#endif // BITCOIN_QT_TEST_URITESTS_H
