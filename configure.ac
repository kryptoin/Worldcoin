AC_INIT([Worldcoin],[1.0],[info@worldcoin.tools])
AM_INIT_AUTOMAKE([foreign subdir-objects])
AC_CONFIG_SRCDIR([src/main.cpp])
AC_CONFIG_HEADERS([config.h])
AC_CANONICAL_HOST

AC_PROG_CC
AC_PROG_CXX
AC_PROG_RANLIB
AC_PROG_OBJCXX  # Needed for Objective-C++
LT_INIT         # Needed for libtool

# Set up OS flags
BUILD_DARWIN=no
TARGET_DARWIN=no
TARGET_LINUX=no

case $host_os in
  darwin*)
    BUILD_DARWIN=yes
    TARGET_DARWIN=yes
    ;;
  linux*)
    TARGET_LINUX=yes
    ;;
esac

AM_CONDITIONAL([BUILD_DARWIN], [test "x$BUILD_DARWIN" = xyes])
AM_CONDITIONAL([TARGET_DARWIN], [test "x$TARGET_DARWIN" = xyes])
AM_CONDITIONAL([TARGET_LINUX], [test "x$TARGET_LINUX" = xyes])

# Your options
AC_ARG_ENABLE([wallet], [AS_HELP_STRING([--enable-wallet], [enable wallet support])], [ENABLE_WALLET=$enableval], [ENABLE_WALLET=yes])
AM_CONDITIONAL([ENABLE_WALLET], [test "x$ENABLE_WALLET" = xyes])

AC_ARG_ENABLE([tests], [AS_HELP_STRING([--enable-tests], [build unit tests])], [ENABLE_TESTS=$enableval], [ENABLE_TESTS=no])
AM_CONDITIONAL([ENABLE_TESTS], [test "x$ENABLE_TESTS" = xyes])

AC_ARG_ENABLE([qt], [AS_HELP_STRING([--enable-qt], [enable Qt GUI])], [ENABLE_QT=$enableval], [ENABLE_QT=no])
AM_CONDITIONAL([ENABLE_QT], [test "x$ENABLE_QT" = xyes])

AC_ARG_ENABLE([qt-tests], [AS_HELP_STRING([--enable-qt-tests], [enable Qt tests])], [ENABLE_QT_TESTS=$enableval], [ENABLE_QT_TESTS=no])
AM_CONDITIONAL([ENABLE_QT_TESTS], [test "x$ENABLE_QT_TESTS" = xyes])

AM_CONDITIONAL([TARGET_WINDOWS], [false]) # Windows disabled

AM_CONDITIONAL([BUILD_BITCOIN_LIBS], [true])
AM_CONDITIONAL([BUILD_BITCOIND], [true])
AM_CONDITIONAL([BUILD_BITCOIN_UTILS], [true])

AM_CONDITIONAL([GLIBC_BACK_COMPAT], [false])
AM_CONDITIONAL([USE_LCOV], [false])
AM_CONDITIONAL([USE_COMPARISON_TOOL], [false])
AM_CONDITIONAL([USE_LIBSECP256K1], [true])

# Boost and OpenSSL
AC_CHECK_LIB([ssl], [SSL_library_init], [LIBS="$LIBS -lssl"])
AC_CHECK_LIB([crypto], [CRYPTO_malloc], [LIBS="$LIBS -lcrypto"])
AC_CHECK_LIB([db_cxx], [db_create], [LIBS="$LIBS -ldb_cxx"])

AC_CHECK_LIB([boost_system], [boost::system::error_category::message], [LIBS="$LIBS -lboost_system"])
AC_CHECK_LIB([boost_filesystem], [boost::filesystem::path::operator/=(boost::filesystem::path const&)], [LIBS="$LIBS -lboost_filesystem"])
AC_CHECK_LIB([boost_program_options], [boost::program_options::options_description::options_description], [LIBS="$LIBS -lboost_program_options"])
AC_CHECK_LIB([boost_thread], [boost::thread::hardware_concurrency], [LIBS="$LIBS -lboost_thread"])
AC_CHECK_LIB([boost_chrono], [boost::chrono::steady_clock::now], [LIBS="$LIBS -lboost_chrono"])
AC_CHECK_LIB([boost_unit_test_framework], [boost::unit_test::unit_test_main], [LIBS="$LIBS -lboost_unit_test_framework"])


# Standard compliance
# AX_CXX_COMPILE_STDCXX([14]) # Removed as it was causing syntax errors and likely not properly included.

# Warnings
CXXFLAGS="$CXXFLAGS -Wall"

AC_CONFIG_FILES([
  Makefile
  src/Makefile
])
AC_OUTPUT
