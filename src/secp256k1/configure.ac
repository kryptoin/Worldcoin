AC_PREREQ([2.60])
AC_INIT([libsecp256k1],[0.1])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIRS([build-aux/m4])

AC_CANONICAL_HOST
AH_TOP([#ifndef LIBSECP256K1_CONFIG_H])
AH_TOP([#define LIBSECP256K1_CONFIG_H])
AH_BOTTOM([#endif //LIBSECP256K1_CONFIG_H])
AM_INIT_AUTOMAKE([foreign])
LT_INIT


dnl make the compilation flags quiet unless V=1 is used
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

PKG_PROG_PKG_CONFIG

AC_PATH_TOOL(AR, ar)
AC_PATH_TOOL(RANLIB, ranlib)
AC_PATH_TOOL(STRIP, strip)

AC_PROG_CC_C99
if test x"$ac_cv_prog_cc_c99" == x"no"; then
  AC_MSG_ERROR([c99 compiler support required])
fi

case $host in
  *mingw*)
     use_pkgconfig=no
     ;;
   *)
     use_pkgconfig=yes
     ;;
esac

case $host_os in
  *darwin*)
     if  test x$cross_compiling != xyes; then
       AC_PATH_PROG([BREW],brew,)
       if test x$BREW != x; then
         dnl These Homebrew packages may be keg-only, meaning that they won't be found
         dnl in expected paths because they may conflict with system files. Ask
         dnl Homebrew where each one is located, then adjust paths accordingly.

         openssl_prefix=`$BREW --prefix openssl 2>/dev/null`
         gmp_prefix=`$BREW --prefix gmp 2>/dev/null`
         if test x$openssl_prefix != x; then
           PKG_CONFIG_PATH="$openssl_prefix/lib/pkgconfig:$PKG_CONFIG_PATH"
           export PKG_CONFIG_PATH
         fi
         if test x$gmp_prefix != x; then
           GMP_CPPFLAGS="-I$gmp_prefix/include"
           GMP_LIBS="-L$gmp_prefix/lib"
         fi
       else
         AC_PATH_PROG([PORT],port,)
         dnl if homebrew isn't installed and macports is, add the macports default paths
         dnl as a last resort.
         if test x$PORT != x; then
           CPPFLAGS="$CPPFLAGS -isystem /opt/local/include"
           LDFLAGS="$LDFLAGS -L/opt/local/lib"
         fi
       fi
     fi
   ;;
esac

CFLAGS="$CFLAGS -W"

warn_CFLAGS="-Wall -Wextra -Wcast-align -Wnested-externs -Wshadow -Wstrict-prototypes -Wno-unused-function"
saved_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS $warn_CFLAGS"
AC_MSG_CHECKING([if ${CC} supports ${warn_CFLAGS}])
AC_COMPILE_IFELSE([AC_LANG_SOURCE([[char foo;]])],
    [ AC_MSG_RESULT([yes]) ],
    [ AC_MSG_RESULT([no])
      CFLAGS="$saved_CFLAGS"
    ])


AC_ARG_ENABLE(benchmark,
    AS_HELP_STRING([--enable-benchmark],[compile benchmark (default is yes)]),
    [use_benchmark=$enableval],
    [use_benchmark=yes])

AC_ARG_ENABLE(tests,
    AS_HELP_STRING([--enable-tests],[compile tests (default is yes)]),
    [use_tests=$enableval],
    [use_tests=yes])

AC_ARG_ENABLE(endomorphism,
    AS_HELP_STRING([--enable-endomorphism],[enable endomorphism (default is no)]),
    [use_endomorphism=$enableval],
    [use_endomorphism=no])

AC_ARG_WITH([field], [AS_HELP_STRING([--with-field=gmp|64bit|64bit_asm|32bit|auto],
[Specify Field Implementation. Default is auto])],[req_field=$withval], [req_field=auto])

AC_ARG_WITH([bignum], [AS_HELP_STRING([--with-bignum=gmp|none|auto],
[Specify Bignum Implementation. Default is auto])],[req_bignum=$withval], [req_bignum=auto])

AC_ARG_WITH([scalar], [AS_HELP_STRING([--with-scalar=64bit|32bit|auto],
[Specify scalar implementation. Default is auto])],[req_scalar=$withval], [req_scalar=auto])

AC_CHECK_TYPES([__int128])

AC_CHECK_DECL(__builtin_expect,AC_DEFINE(HAVE_BUILTIN_EXPECT,1,[Define this symbol if __builtin_expect is available]),,)

set_field=64bit
set_scalar=64bit
set_bignum=none

# select field implementation
case $set_field in
64bit_asm)
  AC_DEFINE(USE_FIELD_5X52_ASM, 1, [Define this symbol to use the assembly version for the 5x52 field implementation])
  AC_DEFINE(USE_FIELD_5X52, 1, [Define this symbol to use the FIELD_5X52 implementation])
  ;;
64bit)
  AC_DEFINE(USE_FIELD_5X52_INT128, 1, [Define this symbol to use the __int128 version for the 5x52 field implementation])
  AC_DEFINE(USE_FIELD_5X52, 1, [Define this symbol to use the FIELD_5X52 implementation])
  ;;
gmp)
  AC_DEFINE(HAVE_LIBGMP,1,[Define this symbol if libgmp is installed])
  AC_DEFINE(USE_FIELD_GMP, 1, [Define this symbol to use the FIELD_GMP implementation])
  ;;
32bit)
  AC_DEFINE(USE_FIELD_10X26, 1, [Define this symbol to use the FIELD_10X26 implementation])
  ;;
*)
  AC_MSG_ERROR([invalid field implementation])
  ;;
esac

# select bignum implementation
case $set_bignum in
gmp)
  AC_DEFINE(HAVE_LIBGMP, 1, [Define this symbol if libgmp is installed])
  AC_DEFINE(USE_NUM_GMP, 1, [Define this symbol to use the gmp implementation for num])
  AC_DEFINE(USE_FIELD_INV_NUM, 1, [Define this symbol to use the num-based field inverse implementation])
  AC_DEFINE(USE_SCALAR_INV_NUM, 1, [Define this symbol to use the num-based scalar inverse implementation])
  ;;
none)
  AC_DEFINE(USE_NUM_NONE, 1, [Define this symbol to use no num implementation])
  AC_DEFINE(USE_FIELD_INV_BUILTIN, 1, [Define this symbol to use the native field inverse implementation])
  AC_DEFINE(USE_SCALAR_INV_BUILTIN, 1, [Define this symbol to use the native scalar inverse implementation])
  ;;
*)
  AC_MSG_ERROR([invalid bignum implementation])
  ;;
esac

#select scalar implementation
case $set_scalar in
64bit)
  AC_DEFINE(USE_SCALAR_4X64, 1, [Define this symbol to use the 4x64 scalar implementation])
  ;;
32bit)
  AC_DEFINE(USE_SCALAR_8X32, 1, [Define this symbol to use the 8x32 scalar implementation])
  ;;
*)
  AC_MSG_ERROR([invalid scalar implementation])
  ;;
esac

if test x"$use_tests" = x"yes"; then
  SECP_OPENSSL_CHECK
  if test x"$has_openssl_ec" == x"yes"; then
    AC_DEFINE(ENABLE_OPENSSL_TESTS, 1, [Define this symbol if OpenSSL EC functions are available])
    SECP_TEST_INCLUDES="$SSL_CFLAGS $CRYPTO_CFLAGS"
    SECP_TEST_LIBS="$CRYPTO_LIBS"

    case $host in
    *mingw*)
      SECP_TEST_LIBS="$SECP_TEST_LIBS -lgdi32"
      ;;
    esac

  fi
fi

if test x"$set_field" = x"gmp" || test x"$set_bignum" = x"gmp"; then
  SECP_LIBS="$SECP_LIBS $GMP_LIBS"
  SECP_INCLUDES="$SECP_INCLUDES $GMP_CPPFLAGS"
fi

if test x"$use_endomorphism" = x"yes"; then
  AC_DEFINE(USE_ENDOMORPHISM, 1, [Define this symbol to use endomorphism optimization])
fi

AC_MSG_NOTICE([Using field implementation: $set_field])
AC_MSG_NOTICE([Using bignum implementation: $set_bignum])
AC_MSG_NOTICE([Using scalar implementation: $set_scalar])

AC_CONFIG_HEADERS([src/libsecp256k1-config.h])
AC_CONFIG_FILES([Makefile libsecp256k1.pc])
AC_SUBST(SECP_INCLUDES)
AC_SUBST(SECP_LIBS)
AC_SUBST(SECP_TEST_LIBS)
AC_SUBST(SECP_TEST_INCLUDES)
AC_SUBST(YASM_BINFMT)
AM_CONDITIONAL([USE_ASM], [test x"$set_field" == x"64bit_asm"])
AM_CONDITIONAL([USE_TESTS], [test x"$use_tests" != x"no"])
AM_CONDITIONAL([USE_BENCHMARK], [test x"$use_benchmark" != x"no"])

dnl make sure nothing new is exported so that we don't break the cache
PKGCONFIG_PATH_TEMP="$PKG_CONFIG_PATH"
unset PKG_CONFIG_PATH
PKG_CONFIG_PATH="$PKGCONFIG_PATH_TEMP"

AC_OUTPUT
