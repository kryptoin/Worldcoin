// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2025 The Bitcoin developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef BITCOIN_SCRIPT_SCRIPT_ERROR_H
#define BITCOIN_SCRIPT_SCRIPT_ERROR_H

typedef enum ScriptError_t
{
    SCRIPT_ERR_OK = 0,
    SCRIPT_ERR_UNKNOWN_ERROR,
    SCRIPT_ERR_EVAL_FALSE,
    SCRIPT_ERR_OP_RETURN,

    /* Max sizes */
    SCRIPT_ERR_SCRIPT_SIZE,
    SCRIPT_ERR_PUSH_SIZE,
    SCRIPT_ERR_OP_COUNT,
    SCRIPT_ERR_STACK_SIZE,
    SCRIPT_ERR_SIG_COUNT,
    SCRIPT_ERR_PUBKEY_COUNT,

    /* Failed verify operations */
    SCRIPT_ERR_VERIFY,
    SCRIPT_ERR_EQUALVERIFY,
    SCRIPT_ERR_CHECKMULTISIGVERIFY,
    SCRIPT_ERR_CHECKSIGVERIFY,
    SCRIPT_ERR_NUMEQUALVERIFY,

    /* Logical/Format/Canonical errors */
    SCRIPT_ERR_BAD_OPCODE,
    SCRIPT_ERR_DISABLED_OPCODE,
    SCRIPT_ERR_INVALID_STACK_OPERATION,
    SCRIPT_ERR_INVALID_ALTSTACK_OPERATION,
    SCRIPT_ERR_UNBALANCED_CONDITIONAL,

    /* OP_CHECKLOCKTIMEVERIFY */
    SCRIPT_ERR_NEGATIVE_LOCKTIME,
    SCRIPT_ERR_UNSATISFIED_LOCKTIME,

    /* BIP62 */
    SCRIPT_ERR_SIG_HASHTYPE,
    SCRIPT_ERR_SIG_DER,
    SCRIPT_ERR_MINIMALDATA,
    SCRIPT_ERR_SIG_PUSHONLY,
    SCRIPT_ERR_SIG_HIGH_S,
    SCRIPT_ERR_SIG_NULLDUMMY,
    SCRIPT_ERR_PUBKEYTYPE,

    /* softfork safeness */
    SCRIPT_ERR_DISCOURAGE_UPGRADABLE_NOPS,

    SCRIPT_ERR_ERROR_COUNT
} ScriptError;

#define SCRIPT_ERR_LAST SCRIPT_ERR_ERROR_COUNT

const char* ScriptErrorString(const ScriptError error);

#endif // BITCOIN_SCRIPT_SCRIPT_ERROR_H
