/* src/config/bitcoin-config.h.  Generated from bitcoin-config.h.in by configure.  */
/* src/config/bitcoin-config.h.in.  Generated from configure.ac by autoheader.  */

#ifndef BITCOIN_CONFIG_H

#define BITCOIN_CONFIG_H

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* Version Build */
#define CLIENT_VERSION_BUILD 0

/* Version is release */
#define CLIENT_VERSION_IS_RELEASE true

/* Major version */
#define CLIENT_VERSION_MAJOR 1

/* Minor version */
#define CLIENT_VERSION_MINOR 0

/* Build revision */
#define CLIENT_VERSION_REVISION 0

/* Version is release */
#define COPYRIGHT_YEAR 2025

/* Define to 1 to enable wallet functions */
#define ENABLE_WALLET 1

/* parameter and return value type for __fdelt_chk */
/* #undef FDELT_TYPE */

/* define if the Boost library is available */
#define HAVE_BOOST /**/

/* define if the Boost::Chrono library is available */
#define HAVE_BOOST_CHRONO /**/

/* define if the Boost::Filesystem library is available */
#define HAVE_BOOST_FILESYSTEM /**/

/* define if the Boost::PROGRAM_OPTIONS library is available */
#define HAVE_BOOST_PROGRAM_OPTIONS /**/

/* define if the Boost::System library is available */
#define HAVE_BOOST_SYSTEM /**/

/* define if the Boost::Thread library is available */
#define HAVE_BOOST_THREAD /**/

/* define if the Boost::Unit_Test_Framework library is available */
/* #undef HAVE_BOOST_UNIT_TEST_FRAMEWORK */

/* Define this symbol if the consensus lib has been built */
#define HAVE_CONSENSUS_LIB 1

/* Define to 1 if you have the declaration of 'be32toh', and to 0 if you
   don't. */
#define HAVE_DECL_BE32TOH 0

/* Define to 1 if you have the declaration of 'be64toh', and to 0 if you
   don't. */
#define HAVE_DECL_BE64TOH 0

/* Define to 1 if you have the declaration of 'htobe32', and to 0 if you
   don't. */
#define HAVE_DECL_HTOBE32 0

/* Define to 1 if you have the declaration of 'htobe64', and to 0 if you
   don't. */
#define HAVE_DECL_HTOBE64 0

/* Define to 1 if you have the declaration of 'htole32', and to 0 if you
   don't. */
#define HAVE_DECL_HTOLE32 0

/* Define to 1 if you have the declaration of 'htole64', and to 0 if you
   don't. */
#define HAVE_DECL_HTOLE64 0

/* Define to 1 if you have the declaration of 'le32toh', and to 0 if you
   don't. */
#define HAVE_DECL_LE32TOH 0

/* Define to 1 if you have the declaration of 'le64toh', and to 0 if you
   don't. */
#define HAVE_DECL_LE64TOH 0

/* Define to 1 if you have the declaration of 'strerror_r', and to 0 if you
   don't. */
#define HAVE_DECL_STRERROR_R 1

/* Define to 1 if you have the declaration of 'strnlen', and to 0 if you
   don't. */
#define HAVE_DECL_STRNLEN 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you have the <endian.h> header file. */
/* #undef HAVE_ENDIAN_H */

/* Define to 1 if the system has the `dllexport' function attribute */
#define HAVE_FUNC_ATTRIBUTE_DLLEXPORT 1

/* Define to 1 if the system has the `dllimport' function attribute */
#define HAVE_FUNC_ATTRIBUTE_DLLIMPORT 1

/* Define to 1 if the system has the `visibility' function attribute */
#define HAVE_FUNC_ATTRIBUTE_VISIBILITY 1

/* Define this symbol if you have getaddrinfo_a */
/* #undef HAVE_GETADDRINFO_A */

/* Define this symbol if you have inet_pton */
#define HAVE_INET_PTON 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the 'advapi32' library (-ladvapi32). */
/* #undef HAVE_LIBADVAPI32 */

/* Define to 1 if you have the 'comctl32' library (-lcomctl32). */
/* #undef HAVE_LIBCOMCTL32 */

/* Define to 1 if you have the 'comdlg32' library (-lcomdlg32). */
/* #undef HAVE_LIBCOMDLG32 */

/* Define to 1 if you have the 'crypt32' library (-lcrypt32). */
/* #undef HAVE_LIBCRYPT32 */

/* Define to 1 if you have the 'gdi32' library (-lgdi32). */
/* #undef HAVE_LIBGDI32 */

/* Define to 1 if you have the 'imm32' library (-limm32). */
/* #undef HAVE_LIBIMM32 */

/* Define to 1 if you have the 'iphlpapi' library (-liphlpapi). */
/* #undef HAVE_LIBIPHLPAPI */

/* Define to 1 if you have the 'jpeg ' library (-ljpeg ). */
/* #undef HAVE_LIBJPEG_ */

/* Define to 1 if you have the 'kernel32' library (-lkernel32). */
/* #undef HAVE_LIBKERNEL32 */

/* Define to 1 if you have the 'mingwthrd' library (-lmingwthrd). */
/* #undef HAVE_LIBMINGWTHRD */

/* Define to 1 if you have the 'mswsock' library (-lmswsock). */
/* #undef HAVE_LIBMSWSOCK */

/* Define to 1 if you have the 'ole32' library (-lole32). */
/* #undef HAVE_LIBOLE32 */

/* Define to 1 if you have the 'oleaut32' library (-loleaut32). */
/* #undef HAVE_LIBOLEAUT32 */

/* Define to 1 if you have the 'pcre16 ' library (-lpcre16 ). */
/* #undef HAVE_LIBPCRE16_ */

/* Define to 1 if you have the 'png ' library (-lpng ). */
/* #undef HAVE_LIBPNG_ */

/* Define to 1 if you have the 'rpcrt4' library (-lrpcrt4). */
/* #undef HAVE_LIBRPCRT4 */

/* Define to 1 if you have the 'shell32' library (-lshell32). */
/* #undef HAVE_LIBSHELL32 */

/* Define to 1 if you have the 'shlwapi' library (-lshlwapi). */
/* #undef HAVE_LIBSHLWAPI */

/* Define to 1 if you have the 'ssp' library (-lssp). */
/* #undef HAVE_LIBSSP */

/* Define to 1 if you have the 'user32' library (-luser32). */
/* #undef HAVE_LIBUSER32 */

/* Define to 1 if you have the 'uuid' library (-luuid). */
/* #undef HAVE_LIBUUID */

/* Define to 1 if you have the 'winmm' library (-lwinmm). */
/* #undef HAVE_LIBWINMM */

/* Define to 1 if you have the 'winspool' library (-lwinspool). */
/* #undef HAVE_LIBWINSPOOL */

/* Define to 1 if you have the 'ws2_32' library (-lws2_32). */
/* #undef HAVE_LIBWS2_32 */

/* Define to 1 if you have the 'z ' library (-lz ). */
/* #undef HAVE_LIBZ_ */

/* Define to 1 if you have the <miniupnpc/miniupnpc.h> header file. */
/* #undef HAVE_MINIUPNPC_MINIUPNPC_H */

/* Define to 1 if you have the <miniupnpc/miniwget.h> header file. */
/* #undef HAVE_MINIUPNPC_MINIWGET_H */

/* Define to 1 if you have the <miniupnpc/upnpcommands.h> header file. */
/* #undef HAVE_MINIUPNPC_UPNPCOMMANDS_H */

/* Define to 1 if you have the <miniupnpc/upnperrors.h> header file. */
/* #undef HAVE_MINIUPNPC_UPNPERRORS_H */

/* Define this symbol if you have MSG_NOSIGNAL */
#define HAVE_MSG_NOSIGNAL 1

/* Define if you have POSIX threads libraries and header files. */
#define HAVE_PTHREAD 1

/* Have PTHREAD_PRIO_INHERIT. */
#define HAVE_PTHREAD_PRIO_INHERIT 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdio.h> header file. */
#define HAVE_STDIO_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define if you have 'strerror_r'. */
#define HAVE_STRERROR_R 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/prctl.h> header file. */
/* #undef HAVE_SYS_PRCTL_H */

/* Define to 1 if you have the <sys/select.h> header file. */
#define HAVE_SYS_SELECT_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define if the visibility attribute is supported. */
#define HAVE_VISIBILITY_ATTRIBUTE 1

/* Define this symbol if boost sleep works */
/* #undef HAVE_WORKING_BOOST_SLEEP */

/* Define this symbol if boost sleep_for works */
#define HAVE_WORKING_BOOST_SLEEP_FOR 1

/* Define to the sub-directory where libtool stores uninstalled libraries. */
#define LT_OBJDIR ".libs/"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "info@worldcoin.tools"

/* Define to the full name of this package. */
#define PACKAGE_NAME "Worldcoin Core"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "Worldcoin Core 1.0.0.0"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "worldcoin"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "1.0.0.0"

/* Define to necessary symbol if this constant uses a non-standard name on
   your system. */
/* #undef PTHREAD_CREATE_JOINABLE */

/* Define this symbol if the qt platform is cocoa */
/* #undef QT_QPA_PLATFORM_COCOA */

/* Define this symbol if the qt platform is windows */
/* #undef QT_QPA_PLATFORM_WINDOWS */

/* Define this symbol if the qt platform is xcb */
/* #undef QT_QPA_PLATFORM_XCB */

/* Define this symbol if qt plugins are static */
/* #undef QT_STATICPLUGIN */

/* Define to 1 if all of the C89 standard headers exist (not just the ones
   required in a freestanding environment). This macro is provided for
   backward compatibility; new code need not use it. */
#define STDC_HEADERS 1

/* Define to 1 if strerror_r returns char *. */
/* #undef STRERROR_R_CHAR_P */

/* Define if dbus support should be compiled in */
/* #undef USE_DBUS */

/* Define if QR support should be compiled in */
/* #undef USE_QRCODE */

/* UPnP support not compiled if undefined, otherwise value (0 or 1) determines
   default state */
/* #undef USE_UPNP */

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#else
# ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
# endif
#endif

/* Number of bits in a file offset, on hosts where this is settable. */
/* #undef _FILE_OFFSET_BITS */

/* Define to 1 on platforms where this makes off_t a 64-bit type. */
/* #undef _LARGE_FILES */

/* Number of bits in time_t, on hosts where this is settable. */
/* #undef _TIME_BITS */

/* Define to 1 on platforms where this makes time_t a 64-bit type. */
/* #undef __MINGW_USE_VC2005_COMPAT */

#endif //BITCOIN_CONFIG_H
