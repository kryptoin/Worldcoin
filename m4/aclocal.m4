# generated automatically by aclocal 1.18 -*- Autoconf -*-

# Copyright (C) 1996-2025 Free Software Foundation, Inc.

# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun([AC_CONFIG_MACRO_DIRS], [_AM_CONFIG_MACRO_DIRS($@)])])
m4_ifndef([AC_AUTOCONF_VERSION],
  [m4_copy([m4_PACKAGE_VERSION], [AC_AUTOCONF_VERSION])])dnl
m4_if(m4_defn([AC_AUTOCONF_VERSION]), [2.72],,
[m4_warning([this file was generated for autoconf 2.72.
You have another version of autoconf.  It may work, but is not guaranteed to.
If you have problems, you may need to regenerate the build system entirely.
To do so, use the procedure documented by the package, typically 'autoreconf'.])])

# ===========================================================================
#      https://www.gnu.org/software/autoconf-archive/ax_boost_base.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_BASE([MINIMUM-VERSION], [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#
#   Test for the Boost C++ libraries of a particular version (or newer)
#
#   If no path to the installed boost library is given the macro searches
#   under /usr, /usr/local, /opt, /opt/local and /opt/homebrew and evaluates
#   the $BOOST_ROOT environment variable. Further documentation is available
#   at <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_CPPFLAGS) / AC_SUBST(BOOST_LDFLAGS)
#
#   And sets:
#
#     HAVE_BOOST
#
# LICENSE
#
#   Copyright (c) 2008 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2009 Peter Adolphs
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 55

# example boost program (need to pass version)
m4_define([_AX_BOOST_BASE_PROGRAM],
          [AC_LANG_PROGRAM([[
#include <boost/version.hpp>
]],[[
(void) ((void)sizeof(char[1 - 2*!!((BOOST_VERSION) < ($1))]));
]])])

AC_DEFUN([AX_BOOST_BASE],
[
AC_ARG_WITH([boost],
  [AS_HELP_STRING([--with-boost@<:@=ARG@:>@],
    [use Boost library from a standard location (ARG=yes),
     from the specified location (ARG=<path>),
     or disable it (ARG=no)
     @<:@ARG=yes@:>@ ])],
    [
     AS_CASE([$withval],
       [no],[want_boost="no";_AX_BOOST_BASE_boost_path=""],
       [yes],[want_boost="yes";_AX_BOOST_BASE_boost_path=""],
       [want_boost="yes";_AX_BOOST_BASE_boost_path="$withval"])
    ],
    [want_boost="yes"])


AC_ARG_WITH([boost-libdir],
  [AS_HELP_STRING([--with-boost-libdir=LIB_DIR],
    [Force given directory for boost libraries.
     Note that this will override library path detection,
     so use this parameter only if default library detection fails
     and you know exactly where your boost libraries are located.])],
  [
   AS_IF([test -d "$withval"],
         [_AX_BOOST_BASE_boost_lib_path="$withval"],
    [AC_MSG_ERROR([--with-boost-libdir expected directory name])])
  ],
  [_AX_BOOST_BASE_boost_lib_path=""])

BOOST_LDFLAGS=""
BOOST_CPPFLAGS=""
AS_IF([test "x$want_boost" = "xyes"],
      [_AX_BOOST_BASE_RUNDETECT([$1],[$2],[$3])])
AC_SUBST(BOOST_CPPFLAGS)
AC_SUBST(BOOST_LDFLAGS)
])


# convert a version string in $2 to numeric and affect to polymorphic var $1
AC_DEFUN([_AX_BOOST_BASE_TONUMERICVERSION],[
  AS_IF([test "x$2" = "x"],[_AX_BOOST_BASE_TONUMERICVERSION_req="1.20.0"],[_AX_BOOST_BASE_TONUMERICVERSION_req="$2"])
  _AX_BOOST_BASE_TONUMERICVERSION_req_shorten=`expr $_AX_BOOST_BASE_TONUMERICVERSION_req : '\([[0-9]]*\.[[0-9]]*\)'`
  _AX_BOOST_BASE_TONUMERICVERSION_req_major=`expr $_AX_BOOST_BASE_TONUMERICVERSION_req : '\([[0-9]]*\)'`
  AS_IF([test "x$_AX_BOOST_BASE_TONUMERICVERSION_req_major" = "x"],
        [AC_MSG_ERROR([You should at least specify libboost major version])])
  _AX_BOOST_BASE_TONUMERICVERSION_req_minor=`expr $_AX_BOOST_BASE_TONUMERICVERSION_req : '[[0-9]]*\.\([[0-9]]*\)'`
  AS_IF([test "x$_AX_BOOST_BASE_TONUMERICVERSION_req_minor" = "x"],
        [_AX_BOOST_BASE_TONUMERICVERSION_req_minor="0"])
  _AX_BOOST_BASE_TONUMERICVERSION_req_sub_minor=`expr $_AX_BOOST_BASE_TONUMERICVERSION_req : '[[0-9]]*\.[[0-9]]*\.\([[0-9]]*\)'`
  AS_IF([test "X$_AX_BOOST_BASE_TONUMERICVERSION_req_sub_minor" = "X"],
        [_AX_BOOST_BASE_TONUMERICVERSION_req_sub_minor="0"])
  _AX_BOOST_BASE_TONUMERICVERSION_RET=`expr $_AX_BOOST_BASE_TONUMERICVERSION_req_major \* 100000 \+  $_AX_BOOST_BASE_TONUMERICVERSION_req_minor \* 100 \+ $_AX_BOOST_BASE_TONUMERICVERSION_req_sub_minor`
  AS_VAR_SET($1,$_AX_BOOST_BASE_TONUMERICVERSION_RET)
])

dnl Run the detection of boost should be run only if $want_boost
AC_DEFUN([_AX_BOOST_BASE_RUNDETECT],[
    _AX_BOOST_BASE_TONUMERICVERSION(WANT_BOOST_VERSION,[$1])
    succeeded=no


    AC_REQUIRE([AC_CANONICAL_HOST])
    dnl On 64-bit systems check for system libraries in both lib64 and lib.
    dnl The former is specified by FHS, but e.g. Debian does not adhere to
    dnl this (as it rises problems for generic multi-arch support).
    dnl The last entry in the list is chosen by default when no libraries
    dnl are found, e.g. when only header-only libraries are installed!
    AS_CASE([${host_cpu}],
      [x86_64],[libsubdirs="lib64 libx32 lib lib64"],
      [mips*64*],[libsubdirs="lib64 lib32 lib lib64"],
      [ppc64|powerpc64|s390x|sparc64|aarch64|ppc64le|powerpc64le|riscv64|e2k|loongarch64],[libsubdirs="lib64 lib lib64"],
      [libsubdirs="lib"]
    )

    dnl allow for real multi-arch paths e.g. /usr/lib/x86_64-linux-gnu. Give
    dnl them priority over the other paths since, if libs are found there, they
    dnl are almost assuredly the ones desired.
    AS_CASE([${host_cpu}],
      [i?86],[multiarch_libsubdir="lib/i386-${host_os}"],
      [armv7l],[multiarch_libsubdir="lib/arm-${host_os}"],
      [multiarch_libsubdir="lib/${host_cpu}-${host_os}"]
    )

    dnl first we check the system location for boost libraries
    dnl this location is chosen if boost libraries are installed with the --layout=system option
    dnl or if you install boost with RPM
    AS_IF([test "x$_AX_BOOST_BASE_boost_path" != "x"],[
        AC_MSG_CHECKING([for boostlib >= $1 ($WANT_BOOST_VERSION) includes in "$_AX_BOOST_BASE_boost_path/include"])
         AS_IF([test -d "$_AX_BOOST_BASE_boost_path/include" && test -r "$_AX_BOOST_BASE_boost_path/include"],[
           AC_MSG_RESULT([yes])
           BOOST_CPPFLAGS="-I$_AX_BOOST_BASE_boost_path/include"
           for _AX_BOOST_BASE_boost_path_tmp in $multiarch_libsubdir $libsubdirs; do
                AC_MSG_CHECKING([for boostlib >= $1 ($WANT_BOOST_VERSION) lib path in "$_AX_BOOST_BASE_boost_path/$_AX_BOOST_BASE_boost_path_tmp"])
                AS_IF([test -d "$_AX_BOOST_BASE_boost_path/$_AX_BOOST_BASE_boost_path_tmp" && test -r "$_AX_BOOST_BASE_boost_path/$_AX_BOOST_BASE_boost_path_tmp" ],[
                        AC_MSG_RESULT([yes])
                        BOOST_LDFLAGS="-L$_AX_BOOST_BASE_boost_path/$_AX_BOOST_BASE_boost_path_tmp";
                        break;
                ],
      [AC_MSG_RESULT([no])])
           done],[
      AC_MSG_RESULT([no])])
    ],[
        if test X"$cross_compiling" = Xyes; then
            search_libsubdirs=$multiarch_libsubdir
        else
            search_libsubdirs="$multiarch_libsubdir $libsubdirs"
        fi
        for _AX_BOOST_BASE_boost_path_tmp in /usr /usr/local /opt /opt/local /opt/homebrew ; do
            if test -d "$_AX_BOOST_BASE_boost_path_tmp/include/boost" && test -r "$_AX_BOOST_BASE_boost_path_tmp/include/boost" ; then
                for libsubdir in $search_libsubdirs ; do
                    if ls "$_AX_BOOST_BASE_boost_path_tmp/$libsubdir/libboost_"* >/dev/null 2>&1 ; then break; fi
                done
                BOOST_LDFLAGS="-L$_AX_BOOST_BASE_boost_path_tmp/$libsubdir"
                BOOST_CPPFLAGS="-I$_AX_BOOST_BASE_boost_path_tmp/include"
                break;
            fi
        done
    ])

    dnl overwrite ld flags if we have required special directory with
    dnl --with-boost-libdir parameter
    AS_IF([test "x$_AX_BOOST_BASE_boost_lib_path" != "x"],
          [BOOST_LDFLAGS="-L$_AX_BOOST_BASE_boost_lib_path"])

    AC_MSG_CHECKING([for boostlib >= $1 ($WANT_BOOST_VERSION)])
    CPPFLAGS_SAVED="$CPPFLAGS"
    CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
    export CPPFLAGS

    LDFLAGS_SAVED="$LDFLAGS"
    LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
    export LDFLAGS

    AC_REQUIRE([AC_PROG_CXX])
    AC_LANG_PUSH(C++)
        AC_COMPILE_IFELSE([_AX_BOOST_BASE_PROGRAM($WANT_BOOST_VERSION)],[
        AC_MSG_RESULT(yes)
    succeeded=yes
    found_system=yes
        ],[
        ])
    AC_LANG_POP([C++])



    dnl if we found no boost with system layout we search for boost libraries
    dnl built and installed without the --layout=system option or for a staged(not installed) version
    if test "x$succeeded" != "xyes" ; then
        CPPFLAGS="$CPPFLAGS_SAVED"
        LDFLAGS="$LDFLAGS_SAVED"
        BOOST_CPPFLAGS=
        if test -z "$_AX_BOOST_BASE_boost_lib_path" ; then
            BOOST_LDFLAGS=
        fi
        _version=0
        if test -n "$_AX_BOOST_BASE_boost_path" ; then
            if test -d "$_AX_BOOST_BASE_boost_path" && test -r "$_AX_BOOST_BASE_boost_path"; then
                for i in `ls -d $_AX_BOOST_BASE_boost_path/include/boost-* 2>/dev/null`; do
                    _version_tmp=`echo $i | sed "s#$_AX_BOOST_BASE_boost_path##" | sed 's/\/include\/boost-//' | sed 's/_/./'`
                    V_CHECK=`expr $_version_tmp \> $_version`
                    if test "x$V_CHECK" = "x1" ; then
                        _version=$_version_tmp
                    fi
                    VERSION_UNDERSCORE=`echo $_version | sed 's/\./_/'`
                    BOOST_CPPFLAGS="-I$_AX_BOOST_BASE_boost_path/include/boost-$VERSION_UNDERSCORE"
                done
                dnl if nothing found search for layout used in Windows distributions
                if test -z "$BOOST_CPPFLAGS"; then
                    if test -d "$_AX_BOOST_BASE_boost_path/boost" && test -r "$_AX_BOOST_BASE_boost_path/boost"; then
                        BOOST_CPPFLAGS="-I$_AX_BOOST_BASE_boost_path"
                    fi
                fi
                dnl if we found something and BOOST_LDFLAGS was unset before
                dnl (because "$_AX_BOOST_BASE_boost_lib_path" = ""), set it here.
                if test -n "$BOOST_CPPFLAGS" && test -z "$BOOST_LDFLAGS"; then
                    for libsubdir in $libsubdirs ; do
                        if ls "$_AX_BOOST_BASE_boost_path/$libsubdir/libboost_"* >/dev/null 2>&1 ; then break; fi
                    done
                    BOOST_LDFLAGS="-L$_AX_BOOST_BASE_boost_path/$libsubdir"
                fi
            fi
        else
            if test "x$cross_compiling" != "xyes" ; then
                for _AX_BOOST_BASE_boost_path in /usr /usr/local /opt /opt/local /opt/homebrew ; do
                    if test -d "$_AX_BOOST_BASE_boost_path" && test -r "$_AX_BOOST_BASE_boost_path" ; then
                        for i in `ls -d $_AX_BOOST_BASE_boost_path/include/boost-* 2>/dev/null`; do
                            _version_tmp=`echo $i | sed "s#$_AX_BOOST_BASE_boost_path##" | sed 's/\/include\/boost-//' | sed 's/_/./'`
                            V_CHECK=`expr $_version_tmp \> $_version`
                            if test "x$V_CHECK" = "x1" ; then
                                _version=$_version_tmp
                                best_path=$_AX_BOOST_BASE_boost_path
                            fi
                        done
                    fi
                done

                VERSION_UNDERSCORE=`echo $_version | sed 's/\./_/'`
                BOOST_CPPFLAGS="-I$best_path/include/boost-$VERSION_UNDERSCORE"
                if test -z "$_AX_BOOST_BASE_boost_lib_path" ; then
                    for libsubdir in $libsubdirs ; do
                        if ls "$best_path/$libsubdir/libboost_"* >/dev/null 2>&1 ; then break; fi
                    done
                    BOOST_LDFLAGS="-L$best_path/$libsubdir"
                fi
            fi

            if test -n "$BOOST_ROOT" ; then
                for libsubdir in $libsubdirs ; do
                    if ls "$BOOST_ROOT/stage/$libsubdir/libboost_"* >/dev/null 2>&1 ; then break; fi
                done
                if test -d "$BOOST_ROOT" && test -r "$BOOST_ROOT" && test -d "$BOOST_ROOT/stage/$libsubdir" && test -r "$BOOST_ROOT/stage/$libsubdir"; then
                    version_dir=`expr //$BOOST_ROOT : '.*/\(.*\)'`
                    stage_version=`echo $version_dir | sed 's/boost_//' | sed 's/_/./g'`
                        stage_version_shorten=`expr $stage_version : '\([[0-9]]*\.[[0-9]]*\)'`
                    V_CHECK=`expr $stage_version_shorten \>\= $_version`
                    if test "x$V_CHECK" = "x1" && test -z "$_AX_BOOST_BASE_boost_lib_path" ; then
                        AC_MSG_NOTICE(We will use a staged boost library from $BOOST_ROOT)
                        BOOST_CPPFLAGS="-I$BOOST_ROOT"
                        BOOST_LDFLAGS="-L$BOOST_ROOT/stage/$libsubdir"
                    fi
                fi
            fi
        fi

        CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
        export CPPFLAGS
        LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
        export LDFLAGS

        AC_LANG_PUSH(C++)
            AC_COMPILE_IFELSE([_AX_BOOST_BASE_PROGRAM($WANT_BOOST_VERSION)],[
            AC_MSG_RESULT(yes)
        succeeded=yes
        found_system=yes
            ],[
            ])
        AC_LANG_POP([C++])
    fi

    if test "x$succeeded" != "xyes" ; then
        if test "x$_version" = "x0" ; then
            AC_MSG_NOTICE([[We could not detect the boost libraries (version $1 or higher). If you have a staged boost library (still not installed) please specify \$BOOST_ROOT in your environment and do not give a PATH to --with-boost option.  If you are sure you have boost installed, then check your version number looking in <boost/version.hpp>. See http://randspringer.de/boost for more documentation.]])
        else
            AC_MSG_NOTICE([Your boost libraries seems to old (version $_version).])
        fi
        BOOST_LDFLAGS=""
        BOOST_CPPFLAGS=""
        # execute ACTION-IF-NOT-FOUND (if present):
        ifelse([$3], , :, [$3])
    else
        AC_DEFINE(HAVE_BOOST,,[define if the Boost library is available])
        # execute ACTION-IF-FOUND (if present):
        ifelse([$2], , :, [$2])
    fi

    CPPFLAGS="$CPPFLAGS_SAVED"
    LDFLAGS="$LDFLAGS_SAVED"

])

# ===========================================================================
#     https://www.gnu.org/software/autoconf-archive/ax_boost_chrono.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_CHRONO
#
# DESCRIPTION
#
#   Test for Chrono library from the Boost C++ libraries. The macro requires
#   a preceding call to AX_BOOST_BASE. Further documentation is available at
#   <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_CHRONO_LIB)
#
#   And sets:
#
#     HAVE_BOOST_CHRONO
#
# LICENSE
#
#   Copyright (c) 2012 Xiyue Deng <manphiz@gmail.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 5

AC_DEFUN([AX_BOOST_CHRONO],
[
	AC_ARG_WITH([boost-chrono],
	AS_HELP_STRING([--with-boost-chrono@<:@=special-lib@:>@],
                   [use the Chrono library from boost - it is possible to specify a certain library for the linker
                        e.g. --with-boost-chrono=boost_chrono-gcc-mt ]),
        [
        if test "$withval" = "no"; then
			want_boost="no"
        elif test "$withval" = "yes"; then
            want_boost="yes"
            ax_boost_user_chrono_lib=""
        else
		    want_boost="yes"
		ax_boost_user_chrono_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_boost" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
        AC_REQUIRE([AC_CANONICAL_BUILD])
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
		export CPPFLAGS

		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
		export LDFLAGS

        AC_CACHE_CHECK(whether the Boost::Chrono library is available,
					   ax_cv_boost_chrono,
        [AC_LANG_PUSH([C++])
			 CXXFLAGS_SAVE=$CXXFLAGS

			 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <boost/chrono.hpp>]],
                                   [[boost::chrono::system_clock::time_point* time = new boost::chrono::system_clock::time_point; delete time;]])],
                   ax_cv_boost_chrono=yes, ax_cv_boost_chrono=no)
			 CXXFLAGS=$CXXFLAGS_SAVE
             AC_LANG_POP([C++])
		])
		if test "x$ax_cv_boost_chrono" = "xyes"; then
			AC_SUBST(BOOST_CPPFLAGS)

			AC_DEFINE(HAVE_BOOST_CHRONO,,[define if the Boost::Chrono library is available])
            BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`

			LDFLAGS_SAVE=$LDFLAGS
            if test "x$ax_boost_user_chrono_lib" = "x"; then
                for libextension in `ls $BOOSTLIBDIR/libboost_chrono*.so* $BOOSTLIBDIR/libboost_chrono*.dylib* $BOOSTLIBDIR/libboost_chrono*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(boost_chrono.*\)\.so.*$;\1;' -e 's;^lib\(boost_chrono.*\)\.dylib.*$;\1;' -e 's;^lib\(boost_chrono.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_CHRONO_LIB="-l$ax_lib"; AC_SUBST(BOOST_CHRONO_LIB) link_chrono="yes"; break],
                                 [link_chrono="no"])
				done
                if test "x$link_chrono" != "xyes"; then
                for libextension in `ls $BOOSTLIBDIR/boost_chrono*.dll* $BOOSTLIBDIR/boost_chrono*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(boost_chrono.*\)\.dll.*$;\1;' -e 's;^\(boost_chrono.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_CHRONO_LIB="-l$ax_lib"; AC_SUBST(BOOST_CHRONO_LIB) link_chrono="yes"; break],
                                 [link_chrono="no"])
				done
                fi

            else
               for ax_lib in $ax_boost_user_chrono_lib boost_chrono-$ax_boost_user_chrono_lib; do
				      AC_CHECK_LIB($ax_lib, exit,
                                   [BOOST_CHRONO_LIB="-l$ax_lib"; AC_SUBST(BOOST_CHRONO_LIB) link_chrono="yes"; break],
                                   [link_chrono="no"])
                  done

            fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the Boost::Chrono library!)
            fi
			if test "x$link_chrono" = "xno"; then
				AC_MSG_ERROR(Could not link against $ax_lib !)
			fi
		fi

		CPPFLAGS="$CPPFLAGS_SAVED"
	LDFLAGS="$LDFLAGS_SAVED"
	fi
])

# ===========================================================================
#   https://www.gnu.org/software/autoconf-archive/ax_boost_filesystem.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_FILESYSTEM
#
# DESCRIPTION
#
#   Test for Filesystem library from the Boost C++ libraries. The macro
#   requires a preceding call to AX_BOOST_BASE. Further documentation is
#   available at <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_FILESYSTEM_LIB)
#
#   And sets:
#
#     HAVE_BOOST_FILESYSTEM
#
# LICENSE
#
#   Copyright (c) 2009 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2009 Michael Tindal
#   Copyright (c) 2009 Roman Rybalko <libtorrent@romanr.info>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 28

AC_DEFUN([AX_BOOST_FILESYSTEM],
[
	AC_ARG_WITH([boost-filesystem],
	AS_HELP_STRING([--with-boost-filesystem@<:@=special-lib@:>@],
                   [use the Filesystem library from boost - it is possible to specify a certain library for the linker
                        e.g. --with-boost-filesystem=boost_filesystem-gcc-mt ]),
        [
        if test "$withval" = "no"; then
			want_boost="no"
        elif test "$withval" = "yes"; then
            want_boost="yes"
            ax_boost_user_filesystem_lib=""
        else
		    want_boost="yes"
		ax_boost_user_filesystem_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_boost" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
		export CPPFLAGS

		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
		export LDFLAGS

		LIBS_SAVED=$LIBS
		LIBS="$LIBS $BOOST_SYSTEM_LIB"
		export LIBS

        AC_CACHE_CHECK(whether the Boost::Filesystem library is available,
					   ax_cv_boost_filesystem,
        [AC_LANG_PUSH([C++])
         AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <boost/filesystem/path.hpp>]],
                                   [[using namespace boost::filesystem;
                                   path my_path( "foo/bar/data.txt" );
                                   return 0;]])],
					       ax_cv_boost_filesystem=yes, ax_cv_boost_filesystem=no)
         AC_LANG_POP([C++])
		])
		if test "x$ax_cv_boost_filesystem" = "xyes"; then
			AC_DEFINE(HAVE_BOOST_FILESYSTEM,,[define if the Boost::Filesystem library is available])
            BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`
            if test "x$ax_boost_user_filesystem_lib" = "x"; then
                for libextension in `ls -r $BOOSTLIBDIR/libboost_filesystem* 2>/dev/null | sed 's,.*/lib,,' | sed 's,\..*,,'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_FILESYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_FILESYSTEM_LIB) link_filesystem="yes"; break],
                                 [link_filesystem="no"])
				done
                if test "x$link_filesystem" != "xyes"; then
                for libextension in `ls -r $BOOSTLIBDIR/boost_filesystem* 2>/dev/null | sed 's,.*/,,' | sed -e 's,\..*,,'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_FILESYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_FILESYSTEM_LIB) link_filesystem="yes"; break],
                                 [link_filesystem="no"])
				done
		    fi
            else
               for ax_lib in $ax_boost_user_filesystem_lib boost_filesystem-$ax_boost_user_filesystem_lib; do
				      AC_CHECK_LIB($ax_lib, exit,
                                   [BOOST_FILESYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_FILESYSTEM_LIB) link_filesystem="yes"; break],
                                   [link_filesystem="no"])
                  done

            fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the Boost::Filesystem library!)
            fi
			if test "x$link_filesystem" != "xyes"; then
				AC_MSG_ERROR(Could not link against $ax_lib !)
			fi
		fi

		CPPFLAGS="$CPPFLAGS_SAVED"
		LDFLAGS="$LDFLAGS_SAVED"
		LIBS="$LIBS_SAVED"
	fi
])

# =============================================================================
#  https://www.gnu.org/software/autoconf-archive/ax_boost_program_options.html
# =============================================================================
#
# SYNOPSIS
#
#   AX_BOOST_PROGRAM_OPTIONS
#
# DESCRIPTION
#
#   Test for program options library from the Boost C++ libraries. The macro
#   requires a preceding call to AX_BOOST_BASE. Further documentation is
#   available at <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_PROGRAM_OPTIONS_LIB)
#
#   And sets:
#
#     HAVE_BOOST_PROGRAM_OPTIONS
#
# LICENSE
#
#   Copyright (c) 2009 Thomas Porschberg <thomas@randspringer.de>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 26

AC_DEFUN([AX_BOOST_PROGRAM_OPTIONS],
[
	AC_ARG_WITH([boost-program-options],
		AS_HELP_STRING([--with-boost-program-options@<:@=special-lib@:>@],
                       [use the program options library from boost - it is possible to specify a certain library for the linker
                        e.g. --with-boost-program-options=boost_program_options-gcc-mt-1_33_1 ]),
        [
        if test "$withval" = "no"; then
			want_boost="no"
        elif test "$withval" = "yes"; then
            want_boost="yes"
            ax_boost_user_program_options_lib=""
        else
		    want_boost="yes"
		ax_boost_user_program_options_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_boost" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
	    export want_boost
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
		export CPPFLAGS
		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
		export LDFLAGS
		AC_CACHE_CHECK([whether the Boost::Program_Options library is available],
					   ax_cv_boost_program_options,
					   [AC_LANG_PUSH(C++)
				AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <boost/program_options/errors.hpp>
                                                          ]],
                                  [[boost::program_options::error err("Error message");
                                   return 0;]])],
                           ax_cv_boost_program_options=yes, ax_cv_boost_program_options=no)
					AC_LANG_POP([C++])
		])
		if test "$ax_cv_boost_program_options" = yes; then
				AC_DEFINE(HAVE_BOOST_PROGRAM_OPTIONS,,[define if the Boost::PROGRAM_OPTIONS library is available])
                  BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`
                if test "x$ax_boost_user_program_options_lib" = "x"; then
                for libextension in `ls $BOOSTLIBDIR/libboost_program_options*.so* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(boost_program_options.*\)\.so.*$;\1;'` `ls $BOOSTLIBDIR/libboost_program_options*.dylib* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(boost_program_options.*\)\.dylib.*$;\1;'` `ls $BOOSTLIBDIR/libboost_program_options*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(boost_program_options.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_PROGRAM_OPTIONS_LIB="-l$ax_lib"; AC_SUBST(BOOST_PROGRAM_OPTIONS_LIB) link_program_options="yes"; break],
                                 [link_program_options="no"])
				done
                if test "x$link_program_options" != "xyes"; then
                for libextension in `ls $BOOSTLIBDIR/boost_program_options*.dll* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(boost_program_options.*\)\.dll.*$;\1;'` `ls $BOOSTLIBDIR/boost_program_options*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(boost_program_options.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_PROGRAM_OPTIONS_LIB="-l$ax_lib"; AC_SUBST(BOOST_PROGRAM_OPTIONS_LIB) link_program_options="yes"; break],
                                 [link_program_options="no"])
				done
                fi
                else
                  for ax_lib in $ax_boost_user_program_options_lib boost_program_options-$ax_boost_user_program_options_lib; do
				      AC_CHECK_LIB($ax_lib, main,
                                   [BOOST_PROGRAM_OPTIONS_LIB="-l$ax_lib"; AC_SUBST(BOOST_PROGRAM_OPTIONS_LIB) link_program_options="yes"; break],
                                   [link_program_options="no"])
                  done
                fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the Boost::Program_Options library!)
            fi
				if test "x$link_program_options" != "xyes"; then
					AC_MSG_ERROR([Could not link against [$ax_lib] !])
				fi
		fi
		CPPFLAGS="$CPPFLAGS_SAVED"
	LDFLAGS="$LDFLAGS_SAVED"
	fi
])

# ===========================================================================
#     https://www.gnu.org/software/autoconf-archive/ax_boost_system.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_SYSTEM
#
# DESCRIPTION
#
#   Test for System library from the Boost C++ libraries. The macro requires
#   a preceding call to AX_BOOST_BASE. Further documentation is available at
#   <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_SYSTEM_LIB)
#
#   And sets:
#
#     HAVE_BOOST_SYSTEM
#
# LICENSE
#
#   Copyright (c) 2008 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2008 Michael Tindal
#   Copyright (c) 2008 Daniel Casimiro <dan.casimiro@gmail.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 20

AC_DEFUN([AX_BOOST_SYSTEM],
[
	AC_ARG_WITH([boost-system],
	AS_HELP_STRING([--with-boost-system@<:@=special-lib@:>@],
                   [use the System library from boost - it is possible to specify a certain library for the linker
                        e.g. --with-boost-system=boost_system-gcc-mt ]),
        [
        if test "$withval" = "no"; then
			want_boost="no"
        elif test "$withval" = "yes"; then
            want_boost="yes"
            ax_boost_user_system_lib=""
        else
		    want_boost="yes"
		ax_boost_user_system_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_boost" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
        AC_REQUIRE([AC_CANONICAL_BUILD])
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
		export CPPFLAGS

		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
		export LDFLAGS

        AC_CACHE_CHECK(whether the Boost::System library is available,
					   ax_cv_boost_system,
        [AC_LANG_PUSH([C++])
			 CXXFLAGS_SAVE=$CXXFLAGS
			 CXXFLAGS=

			 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <boost/system/error_code.hpp>]],
				    [[boost::system::error_category *a = 0;]])],
                   ax_cv_boost_system=yes, ax_cv_boost_system=no)
			 CXXFLAGS=$CXXFLAGS_SAVE
             AC_LANG_POP([C++])
		])
		if test "x$ax_cv_boost_system" = "xyes"; then
			AC_SUBST(BOOST_CPPFLAGS)

			AC_DEFINE(HAVE_BOOST_SYSTEM,,[define if the Boost::System library is available])
            BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`

			LDFLAGS_SAVE=$LDFLAGS
            if test "x$ax_boost_user_system_lib" = "x"; then
                for libextension in `ls -r $BOOSTLIBDIR/libboost_system* 2>/dev/null | sed 's,.*/lib,,' | sed 's,\..*,,'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_SYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_SYSTEM_LIB) link_system="yes"; break],
                                 [link_system="no"])
				done
                if test "x$link_system" != "xyes"; then
                for libextension in `ls -r $BOOSTLIBDIR/boost_system* 2>/dev/null | sed 's,.*/,,' | sed -e 's,\..*,,'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_SYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_SYSTEM_LIB) link_system="yes"; break],
                                 [link_system="no"])
				done
                fi

            else
               for ax_lib in $ax_boost_user_system_lib boost_system-$ax_boost_user_system_lib; do
				      AC_CHECK_LIB($ax_lib, exit,
                                   [BOOST_SYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_SYSTEM_LIB) link_system="yes"; break],
                                   [link_system="no"])
                  done

            fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the Boost::System library!)
            fi
			if test "x$link_system" = "xno"; then
				AC_MSG_ERROR(Could not link against $ax_lib !)
			fi
		fi

		CPPFLAGS="$CPPFLAGS_SAVED"
	LDFLAGS="$LDFLAGS_SAVED"
	fi
])

# ===========================================================================
#     https://www.gnu.org/software/autoconf-archive/ax_boost_thread.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_THREAD
#
# DESCRIPTION
#
#   Test for Thread library from the Boost C++ libraries. The macro requires
#   a preceding call to AX_BOOST_BASE. Further documentation is available at
#   <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_THREAD_LIB)
#
#   And sets:
#
#     HAVE_BOOST_THREAD
#
# LICENSE
#
#   Copyright (c) 2009 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2009 Michael Tindal
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 33

AC_DEFUN([AX_BOOST_THREAD],
[
    AC_ARG_WITH([boost-thread],
    AS_HELP_STRING([--with-boost-thread@<:@=special-lib@:>@],
                   [use the Thread library from boost -
                    it is possible to specify a certain library for the linker
                    e.g. --with-boost-thread=boost_thread-gcc-mt ]),
        [
        if test "$withval" = "yes"; then
            want_boost="yes"
            ax_boost_user_thread_lib=""
        else
            want_boost="yes"
            ax_boost_user_thread_lib="$withval"
        fi
        ],
        [want_boost="yes"]
    )

    if test "x$want_boost" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
        AC_REQUIRE([AC_CANONICAL_BUILD])
        CPPFLAGS_SAVED="$CPPFLAGS"
        CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
        export CPPFLAGS

        LDFLAGS_SAVED="$LDFLAGS"
        LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
        export LDFLAGS

        AC_CACHE_CHECK(whether the Boost::Thread library is available,
                       ax_cv_boost_thread,
        [AC_LANG_PUSH([C++])
             CXXFLAGS_SAVE=$CXXFLAGS

             case "x$host_os" in
                 xsolaris )
                     CXXFLAGS="-pthreads $CXXFLAGS"
                     break;
                     ;;
                 xmingw32 )
                     CXXFLAGS="-mthreads $CXXFLAGS"
                     break;
                     ;;
                 *android* )
                     break;
                     ;;
                 * )
                     CXXFLAGS="-pthread $CXXFLAGS"
                     break;
                     ;;
             esac

             AC_COMPILE_IFELSE([
                 AC_LANG_PROGRAM(
                     [[@%:@include <boost/thread/thread.hpp>]],
                     [[boost::thread_group thrds;
                       return 0;]])],
                 ax_cv_boost_thread=yes, ax_cv_boost_thread=no)
             CXXFLAGS=$CXXFLAGS_SAVE
             AC_LANG_POP([C++])
        ])
        if test "x$ax_cv_boost_thread" = "xyes"; then
            case "x$host_os" in
                xsolaris )
                    BOOST_CPPFLAGS="-pthreads $BOOST_CPPFLAGS"
                    break;
                    ;;
                xmingw32 )
                    BOOST_CPPFLAGS="-mthreads $BOOST_CPPFLAGS"
                    break;
                    ;;
                *android* )
                    break;
                    ;;
                * )
                    BOOST_CPPFLAGS="-pthread $BOOST_CPPFLAGS"
                    break;
                    ;;
            esac

            AC_SUBST(BOOST_CPPFLAGS)

            AC_DEFINE(HAVE_BOOST_THREAD,,
                      [define if the Boost::Thread library is available])
            BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`

            LDFLAGS_SAVE=$LDFLAGS
                        case "x$host_os" in
                          *bsd* )
                               LDFLAGS="-pthread $LDFLAGS"
                          break;
                          ;;
                        esac
            if test "x$ax_boost_user_thread_lib" = "x"; then
                for libextension in `ls -r $BOOSTLIBDIR/libboost_thread* 2>/dev/null | sed 's,.*/lib,,' | sed 's,\..*,,'`; do
                     ax_lib=${libextension}
                    AC_CHECK_LIB($ax_lib, exit,
                                 [link_thread="yes"; break],
                                 [link_thread="no"])
                done
                if test "x$link_thread" != "xyes"; then
                for libextension in `ls -r $BOOSTLIBDIR/boost_thread* 2>/dev/null | sed 's,.*/,,' | sed 's,\..*,,'`; do
                     ax_lib=${libextension}
                    AC_CHECK_LIB($ax_lib, exit,
                                 [link_thread="yes"; break],
                                 [link_thread="no"])
                done
                fi

            else
               for ax_lib in $ax_boost_user_thread_lib boost_thread-$ax_boost_user_thread_lib; do
                      AC_CHECK_LIB($ax_lib, exit,
                                   [link_thread="yes"; break],
                                   [link_thread="no"])
                  done

            fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the Boost::Thread library!)
            fi
            if test "x$link_thread" = "xno"; then
                AC_MSG_ERROR(Could not link against $ax_lib !)
            else
                BOOST_THREAD_LIB="-l$ax_lib"
                case "x$host_os" in
                    *bsd* )
                        BOOST_LDFLAGS="-pthread $BOOST_LDFLAGS"
                        break;
                        ;;
                    xsolaris )
                        BOOST_THREAD_LIB="$BOOST_THREAD_LIB -lpthread"
                        break;
                        ;;
                    xmingw32 )
                        break;
                        ;;
                    *android* )
                        break;
                        ;;
                    * )
                        BOOST_THREAD_LIB="$BOOST_THREAD_LIB -lpthread"
                        break;
                        ;;
                esac
                AC_SUBST(BOOST_THREAD_LIB)
            fi
        fi

        CPPFLAGS="$CPPFLAGS_SAVED"
        LDFLAGS="$LDFLAGS_SAVED"
    fi
])

# =================================================================================
#  https://www.gnu.org/software/autoconf-archive/ax_boost_unit_test_framework.html
# =================================================================================
#
# SYNOPSIS
#
#   AX_BOOST_UNIT_TEST_FRAMEWORK
#
# DESCRIPTION
#
#   Test for Unit_Test_Framework library from the Boost C++ libraries. The
#   macro requires a preceding call to AX_BOOST_BASE. Further documentation
#   is available at <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_UNIT_TEST_FRAMEWORK_LIB)
#
#   And sets:
#
#     HAVE_BOOST_UNIT_TEST_FRAMEWORK
#
# LICENSE
#
#   Copyright (c) 2008 Thomas Porschberg <thomas@randspringer.de>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 22

AC_DEFUN([AX_BOOST_UNIT_TEST_FRAMEWORK],
[
	AC_ARG_WITH([boost-unit-test-framework],
	AS_HELP_STRING([--with-boost-unit-test-framework@<:@=special-lib@:>@],
                   [use the Unit_Test_Framework library from boost - it is possible to specify a certain library for the linker
                        e.g. --with-boost-unit-test-framework=boost_unit_test_framework-gcc ]),
        [
        if test "$withval" = "no"; then
			want_boost="no"
        elif test "$withval" = "yes"; then
            want_boost="yes"
            ax_boost_user_unit_test_framework_lib=""
        else
		    want_boost="yes"
		ax_boost_user_unit_test_framework_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_boost" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
		export CPPFLAGS

		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
		export LDFLAGS

        AC_CACHE_CHECK(whether the Boost::Unit_Test_Framework library is available,
					   ax_cv_boost_unit_test_framework,
        [AC_LANG_PUSH([C++])
			 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <boost/test/unit_test.hpp>]],
                                    [[using boost::unit_test::test_suite;
							 test_suite* test= BOOST_TEST_SUITE( "Unit test example 1" ); if (test == NULL) { return 1; } else { return 0; }]])],
                   ax_cv_boost_unit_test_framework=yes, ax_cv_boost_unit_test_framework=no)
         AC_LANG_POP([C++])
		])
		if test "x$ax_cv_boost_unit_test_framework" = "xyes"; then
			AC_DEFINE(HAVE_BOOST_UNIT_TEST_FRAMEWORK,,[define if the Boost::Unit_Test_Framework library is available])
            BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`

            if test "x$ax_boost_user_unit_test_framework_lib" = "x"; then
			saved_ldflags="${LDFLAGS}"
                for monitor_library in `ls $BOOSTLIBDIR/libboost_unit_test_framework*.so* $BOOSTLIBDIR/libboost_unit_test_framework*.dylib* $BOOSTLIBDIR/libboost_unit_test_framework*.a* 2>/dev/null` ; do
                    if test -r $monitor_library ; then
                       libextension=`echo $monitor_library | sed 's,.*/,,' | sed -e 's;^lib\(boost_unit_test_framework.*\)\.so.*$;\1;' -e 's;^lib\(boost_unit_test_framework.*\)\.dylib.*$;\1;' -e 's;^lib\(boost_unit_test_framework.*\)\.a.*$;\1;'`
                       ax_lib=${libextension}
                       link_unit_test_framework="yes"
                    else
                       link_unit_test_framework="no"
                    fi

			    if test "x$link_unit_test_framework" = "xyes"; then
                      BOOST_UNIT_TEST_FRAMEWORK_LIB="-l$ax_lib"
                      AC_SUBST(BOOST_UNIT_TEST_FRAMEWORK_LIB)
					  break
				    fi
                done
                if test "x$link_unit_test_framework" != "xyes"; then
                for libextension in `ls $BOOSTLIBDIR/boost_unit_test_framework*.dll* $BOOSTLIBDIR/boost_unit_test_framework*.a* 2>/dev/null  | sed 's,.*/,,' | sed -e 's;^\(boost_unit_test_framework.*\)\.dll.*$;\1;' -e 's;^\(boost_unit_test_framework.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [BOOST_UNIT_TEST_FRAMEWORK_LIB="-l$ax_lib"; AC_SUBST(BOOST_UNIT_TEST_FRAMEWORK_LIB) link_unit_test_framework="yes"; break],
                                 [link_unit_test_framework="no"])
				done
                fi
            else
                link_unit_test_framework="no"
			saved_ldflags="${LDFLAGS}"
                for ax_lib in boost_unit_test_framework-$ax_boost_user_unit_test_framework_lib $ax_boost_user_unit_test_framework_lib ; do
                   if test "x$link_unit_test_framework" = "xyes"; then
                      break;
                   fi
                   for unittest_library in `ls $BOOSTLIBDIR/lib${ax_lib}.so* $BOOSTLIBDIR/lib${ax_lib}.a* 2>/dev/null` ; do
                   if test -r $unittest_library ; then
                       libextension=`echo $unittest_library | sed 's,.*/,,' | sed -e 's;^lib\(boost_unit_test_framework.*\)\.so.*$;\1;' -e 's;^lib\(boost_unit_test_framework.*\)\.a*$;\1;'`
                       ax_lib=${libextension}
                       link_unit_test_framework="yes"
                    else
                       link_unit_test_framework="no"
                    fi

				if test "x$link_unit_test_framework" = "xyes"; then
                        BOOST_UNIT_TEST_FRAMEWORK_LIB="-l$ax_lib"
                        AC_SUBST(BOOST_UNIT_TEST_FRAMEWORK_LIB)
					    break
				    fi
                  done
               done
            fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the Boost::Unit_Test_Framework library!)
            fi
			if test "x$link_unit_test_framework" != "xyes"; then
				AC_MSG_ERROR(Could not link against $ax_lib !)
			fi
		fi

		CPPFLAGS="$CPPFLAGS_SAVED"
	LDFLAGS="$LDFLAGS_SAVED"
	fi
])

# ===========================================================================
#  https://www.gnu.org/software/autoconf-archive/ax_check_compile_flag.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_CHECK_COMPILE_FLAG(FLAG, [ACTION-SUCCESS], [ACTION-FAILURE], [EXTRA-FLAGS], [INPUT])
#
# DESCRIPTION
#
#   Check whether the given FLAG works with the current language's compiler
#   or gives an error.  (Warnings, however, are ignored)
#
#   ACTION-SUCCESS/ACTION-FAILURE are shell commands to execute on
#   success/failure.
#
#   If EXTRA-FLAGS is defined, it is added to the current language's default
#   flags (e.g. CFLAGS) when the check is done.  The check is thus made with
#   the flags: "CFLAGS EXTRA-FLAGS FLAG".  This can for example be used to
#   force the compiler to issue an error when a bad flag is given.
#
#   INPUT gives an alternative input source to AC_COMPILE_IFELSE.
#
#   NOTE: Implementation based on AX_CFLAGS_GCC_OPTION. Please keep this
#   macro in sync with AX_CHECK_{PREPROC,LINK}_FLAG.
#
# LICENSE
#
#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
#   Copyright (c) 2011 Maarten Bosmans <mkbosmans@gmail.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.  This file is offered as-is, without any
#   warranty.

#serial 11

AC_DEFUN([AX_CHECK_COMPILE_FLAG],
[AC_PREREQ(2.64)dnl for _AC_LANG_PREFIX and AS_VAR_IF
AS_VAR_PUSHDEF([CACHEVAR],[ax_cv_check_[]_AC_LANG_ABBREV[]flags_$4_$1])dnl
AC_CACHE_CHECK([whether the _AC_LANG compiler accepts $1], CACHEVAR, [
  ax_check_save_flags=$[]_AC_LANG_PREFIX[]FLAGS
  if test x"m4_case(_AC_LANG,
                     [C], [$GCC],
                     [C++], [$GXX],
                     [Fortran], [$GFC],
                     [Fortran 77], [$G77],
                     [Objective C], [$GOBJC],
                     [Objective C++], [$GOBJCXX],
                     [no])" = xyes ; then
    add_gnu_werror="-Werror"
  fi
  _AC_LANG_PREFIX[]FLAGS="$[]_AC_LANG_PREFIX[]FLAGS $4 $1 $add_gnu_werror"
  AC_COMPILE_IFELSE([m4_default([$5],[AC_LANG_PROGRAM()])],
    [AS_VAR_SET(CACHEVAR,[yes])],
    [AS_VAR_SET(CACHEVAR,[no])])
  _AC_LANG_PREFIX[]FLAGS=$ax_check_save_flags])
AS_VAR_IF(CACHEVAR,yes,
  [m4_default([$2], :)],
  [m4_default([$3], :)])
AS_VAR_POPDEF([CACHEVAR])dnl
])dnl AX_CHECK_COMPILE_FLAGS

# ===========================================================================
#    https://www.gnu.org/software/autoconf-archive/ax_check_link_flag.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_CHECK_LINK_FLAG(FLAG, [ACTION-SUCCESS], [ACTION-FAILURE], [EXTRA-FLAGS], [INPUT])
#
# DESCRIPTION
#
#   Check whether the given FLAG works with the linker or gives an error.
#   (Warnings, however, are ignored)
#
#   ACTION-SUCCESS/ACTION-FAILURE are shell commands to execute on
#   success/failure.
#
#   If EXTRA-FLAGS is defined, it is added to the linker's default flags
#   when the check is done.  The check is thus made with the flags: "LDFLAGS
#   EXTRA-FLAGS FLAG".  This can for example be used to force the linker to
#   issue an error when a bad flag is given.
#
#   INPUT gives an alternative input source to AC_LINK_IFELSE.
#
#   NOTE: Implementation based on AX_CFLAGS_GCC_OPTION. Please keep this
#   macro in sync with AX_CHECK_{PREPROC,COMPILE}_FLAG.
#
# LICENSE
#
#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
#   Copyright (c) 2011 Maarten Bosmans <mkbosmans@gmail.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.  This file is offered as-is, without any
#   warranty.

#serial 6

AC_DEFUN([AX_CHECK_LINK_FLAG],
[AC_PREREQ(2.64)dnl for _AC_LANG_PREFIX and AS_VAR_IF
AS_VAR_PUSHDEF([CACHEVAR],[ax_cv_check_ldflags_$4_$1])dnl
AC_CACHE_CHECK([whether the linker accepts $1], CACHEVAR, [
  ax_check_save_flags=$LDFLAGS
  LDFLAGS="$LDFLAGS $4 $1"
  AC_LINK_IFELSE([m4_default([$5],[AC_LANG_PROGRAM()])],
    [AS_VAR_SET(CACHEVAR,[yes])],
    [AS_VAR_SET(CACHEVAR,[no])])
  LDFLAGS=$ax_check_save_flags])
AS_VAR_IF(CACHEVAR,yes,
  [m4_default([$2], :)],
  [m4_default([$3], :)])
AS_VAR_POPDEF([CACHEVAR])dnl
])dnl AX_CHECK_LINK_FLAGS

# ===========================================================================
#  https://www.gnu.org/software/autoconf-archive/ax_check_preproc_flag.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_CHECK_PREPROC_FLAG(FLAG, [ACTION-SUCCESS], [ACTION-FAILURE], [EXTRA-FLAGS], [INPUT])
#
# DESCRIPTION
#
#   Check whether the given FLAG works with the current language's
#   preprocessor or gives an error.  (Warnings, however, are ignored)
#
#   ACTION-SUCCESS/ACTION-FAILURE are shell commands to execute on
#   success/failure.
#
#   If EXTRA-FLAGS is defined, it is added to the preprocessor's default
#   flags when the check is done.  The check is thus made with the flags:
#   "CPPFLAGS EXTRA-FLAGS FLAG".  This can for example be used to force the
#   preprocessor to issue an error when a bad flag is given.
#
#   INPUT gives an alternative input source to AC_PREPROC_IFELSE.
#
#   NOTE: Implementation based on AX_CFLAGS_GCC_OPTION. Please keep this
#   macro in sync with AX_CHECK_{COMPILE,LINK}_FLAG.
#
# LICENSE
#
#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
#   Copyright (c) 2011 Maarten Bosmans <mkbosmans@gmail.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.  This file is offered as-is, without any
#   warranty.

#serial 7

AC_DEFUN([AX_CHECK_PREPROC_FLAG],
[AC_PREREQ(2.64)dnl for _AC_LANG_PREFIX and AS_VAR_IF
AS_VAR_PUSHDEF([CACHEVAR],[ax_cv_check_[]_AC_LANG_ABBREV[]cppflags_$4_$1])dnl
AC_CACHE_CHECK([whether the _AC_LANG preprocessor accepts $1], CACHEVAR, [
  ax_check_save_flags=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $4 $1"
  AC_PREPROC_IFELSE([m4_default([$5],[AC_LANG_PROGRAM()])],
    [AS_VAR_SET(CACHEVAR,[yes])],
    [AS_VAR_SET(CACHEVAR,[no])])
  CPPFLAGS=$ax_check_save_flags])
AS_VAR_IF(CACHEVAR,yes,
  [m4_default([$2], :)],
  [m4_default([$3], :)])
AS_VAR_POPDEF([CACHEVAR])dnl
])dnl AX_CHECK_PREPROC_FLAGS

# ===========================================================================
#  https://www.gnu.org/software/autoconf-archive/ax_gcc_func_attribute.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_GCC_FUNC_ATTRIBUTE(ATTRIBUTE)
#
# DESCRIPTION
#
#   This macro checks if the compiler supports one of GCC's function
#   attributes; many other compilers also provide function attributes with
#   the same syntax. Compiler warnings are used to detect supported
#   attributes as unsupported ones are ignored by default so quieting
#   warnings when using this macro will yield false positives.
#
#   The ATTRIBUTE parameter holds the name of the attribute to be checked.
#
#   If ATTRIBUTE is supported define HAVE_FUNC_ATTRIBUTE_<ATTRIBUTE>.
#
#   The macro caches its result in the ax_cv_have_func_attribute_<attribute>
#   variable.
#
#   The macro currently supports the following function attributes:
#
#    alias
#    aligned
#    alloc_size
#    always_inline
#    artificial
#    cold
#    const
#    constructor
#    constructor_priority for constructor attribute with priority
#    deprecated
#    destructor
#    dllexport
#    dllimport
#    error
#    externally_visible
#    fallthrough
#    flatten
#    format
#    format_arg
#    gnu_format
#    gnu_inline
#    hot
#    ifunc
#    leaf
#    malloc
#    noclone
#    noinline
#    nonnull
#    noreturn
#    nothrow
#    optimize
#    pure
#    sentinel
#    sentinel_position
#    unused
#    used
#    visibility
#    warning
#    warn_unused_result
#    weak
#    weakref
#
#   Unsupported function attributes will be tested with a prototype
#   returning an int and not accepting any arguments and the result of the
#   check might be wrong or meaningless so use with care.
#
# LICENSE
#
#   Copyright (c) 2013 Gabriele Svelto <gabriele.svelto@gmail.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.  This file is offered as-is, without any
#   warranty.

#serial 13

AC_DEFUN([AX_GCC_FUNC_ATTRIBUTE], [
    AS_VAR_PUSHDEF([ac_var], [ax_cv_have_func_attribute_$1])

    AC_CACHE_CHECK([for __attribute__(($1))], [ac_var], [
        AC_LINK_IFELSE([AC_LANG_PROGRAM([
            m4_case([$1],
                [alias], [
                    int foo( void ) { return 0; }
                    int bar( void ) __attribute__(($1("foo")));
                ],
                [aligned], [
                    int foo( void ) __attribute__(($1(32)));
                ],
                [alloc_size], [
                    void *foo(int a) __attribute__(($1(1)));
                ],
                [always_inline], [
                    inline __attribute__(($1)) int foo( void ) { return 0; }
                ],
                [artificial], [
                    inline __attribute__(($1)) int foo( void ) { return 0; }
                ],
                [cold], [
                    int foo( void ) __attribute__(($1));
                ],
                [const], [
                    int foo( void ) __attribute__(($1));
                ],
                [constructor_priority], [
                    int foo( void ) __attribute__((__constructor__(65535/2)));
                ],
                [constructor], [
                    int foo( void ) __attribute__(($1));
                ],
                [deprecated], [
                    int foo( void ) __attribute__(($1("")));
                ],
                [destructor], [
                    int foo( void ) __attribute__(($1));
                ],
                [dllexport], [
                    __attribute__(($1)) int foo( void ) { return 0; }
                ],
                [dllimport], [
                    int foo( void ) __attribute__(($1));
                ],
                [error], [
                    int foo( void ) __attribute__(($1("")));
                ],
                [externally_visible], [
                    int foo( void ) __attribute__(($1));
                ],
                [fallthrough], [
                    void foo( int x ) {switch (x) { case 1: __attribute__(($1)); case 2: break ; }};
                ],
                [flatten], [
                    int foo( void ) __attribute__(($1));
                ],
                [format], [
                    int foo(const char *p, ...) __attribute__(($1(printf, 1, 2)));
                ],
                [gnu_format], [
                    int foo(const char *p, ...) __attribute__((format(gnu_printf, 1, 2)));
                ],
                [format_arg], [
                    char *foo(const char *p) __attribute__(($1(1)));
                ],
                [gnu_inline], [
                    inline __attribute__(($1)) int foo( void ) { return 0; }
                ],
                [hot], [
                    int foo( void ) __attribute__(($1));
                ],
                [ifunc], [
                    int my_foo( void ) { return 0; }
                    static int (*resolve_foo(void))(void) { return my_foo; }
                    int foo( void ) __attribute__(($1("resolve_foo")));
                ],
                [leaf], [
                    __attribute__(($1)) int foo( void ) { return 0; }
                ],
                [malloc], [
                    void *foo( void ) __attribute__(($1));
                ],
                [noclone], [
                    int foo( void ) __attribute__(($1));
                ],
                [noinline], [
                    __attribute__(($1)) int foo( void ) { return 0; }
                ],
                [nonnull], [
                    int foo(char *p) __attribute__(($1(1)));
                ],
                [noreturn], [
                    void foo( void ) __attribute__(($1));
                ],
                [nothrow], [
                    int foo( void ) __attribute__(($1));
                ],
                [optimize], [
                    __attribute__(($1(3))) int foo( void ) { return 0; }
                ],
                [pure], [
                    int foo( void ) __attribute__(($1));
                ],
                [sentinel], [
                    int foo(void *p, ...) __attribute__(($1));
                ],
                [sentinel_position], [
                    int foo(void *p, ...) __attribute__(($1(1)));
                ],
                [returns_nonnull], [
                    void *foo( void ) __attribute__(($1));
                ],
                [unused], [
                    int foo( void ) __attribute__(($1));
                ],
                [used], [
                    int foo( void ) __attribute__(($1));
                ],
                [visibility], [
                    int foo_def( void ) __attribute__(($1("default")));
                    int foo_hid( void ) __attribute__(($1("hidden")));
                    int foo_int( void ) __attribute__(($1("internal")));
                    int foo_pro( void ) __attribute__(($1("protected")));
                ],
                [warning], [
                    int foo( void ) __attribute__(($1("")));
                ],
                [warn_unused_result], [
                    int foo( void ) __attribute__(($1));
                ],
                [weak], [
                    int foo( void ) __attribute__(($1));
                ],
                [weakref], [
                    static int foo( void ) { return 0; }
                    static int bar( void ) __attribute__(($1("foo")));
                ],
                [
                 m4_warn([syntax], [Unsupported attribute $1, the test may fail])
                 int foo( void ) __attribute__(($1));
                ]
            )], [])
            ],
            dnl GCC doesn't exit with an error if an unknown attribute is
            dnl provided but only outputs a warning, so accept the attribute
            dnl only if no warning were issued.
            [AS_IF([grep -- -Wattributes conftest.err],
                [AS_VAR_SET([ac_var], [no])],
                [AS_VAR_SET([ac_var], [yes])])],
            [AS_VAR_SET([ac_var], [no])])
    ])

    AS_IF([test yes = AS_VAR_GET([ac_var])],
        [AC_DEFINE_UNQUOTED(AS_TR_CPP(HAVE_FUNC_ATTRIBUTE_$1), 1,
            [Define to 1 if the system has the `$1' function attribute])], [])

    AS_VAR_POPDEF([ac_var])
])

# ===========================================================================
#        https://www.gnu.org/software/autoconf-archive/ax_pthread.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_PTHREAD([ACTION-IF-FOUND[, ACTION-IF-NOT-FOUND]])
#
# DESCRIPTION
#
#   This macro figures out how to build C programs using POSIX threads. It
#   sets the PTHREAD_LIBS output variable to the threads library and linker
#   flags, and the PTHREAD_CFLAGS output variable to any special C compiler
#   flags that are needed. (The user can also force certain compiler
#   flags/libs to be tested by setting these environment variables.)
#
#   Also sets PTHREAD_CC and PTHREAD_CXX to any special C compiler that is
#   needed for multi-threaded programs (defaults to the value of CC
#   respectively CXX otherwise). (This is necessary on e.g. AIX to use the
#   special cc_r/CC_r compiler alias.)
#
#   NOTE: You are assumed to not only compile your program with these flags,
#   but also to link with them as well. For example, you might link with
#   $PTHREAD_CC $CFLAGS $PTHREAD_CFLAGS $LDFLAGS ... $PTHREAD_LIBS $LIBS
#   $PTHREAD_CXX $CXXFLAGS $PTHREAD_CFLAGS $LDFLAGS ... $PTHREAD_LIBS $LIBS
#
#   If you are only building threaded programs, you may wish to use these
#   variables in your default LIBS, CFLAGS, and CC:
#
#     LIBS="$PTHREAD_LIBS $LIBS"
#     CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
#     CXXFLAGS="$CXXFLAGS $PTHREAD_CFLAGS"
#     CC="$PTHREAD_CC"
#     CXX="$PTHREAD_CXX"
#
#   In addition, if the PTHREAD_CREATE_JOINABLE thread-attribute constant
#   has a nonstandard name, this macro defines PTHREAD_CREATE_JOINABLE to
#   that name (e.g. PTHREAD_CREATE_UNDETACHED on AIX).
#
#   Also HAVE_PTHREAD_PRIO_INHERIT is defined if pthread is found and the
#   PTHREAD_PRIO_INHERIT symbol is defined when compiling with
#   PTHREAD_CFLAGS.
#
#   ACTION-IF-FOUND is a list of shell commands to run if a threads library
#   is found, and ACTION-IF-NOT-FOUND is a list of commands to run it if it
#   is not found. If ACTION-IF-FOUND is not specified, the default action
#   will define HAVE_PTHREAD.
#
#   Please let the authors know if this macro fails on any platform, or if
#   you have any other suggestions or comments. This macro was based on work
#   by SGJ on autoconf scripts for FFTW (http://www.fftw.org/) (with help
#   from M. Frigo), as well as ac_pthread and hb_pthread macros posted by
#   Alejandro Forero Cuervo to the autoconf macro repository. We are also
#   grateful for the helpful feedback of numerous users.
#
#   Updated for Autoconf 2.68 by Daniel Richard G.
#
# LICENSE
#
#   Copyright (c) 2008 Steven G. Johnson <stevenj@alum.mit.edu>
#   Copyright (c) 2011 Daniel Richard G. <skunk@iSKUNK.ORG>
#   Copyright (c) 2019 Marc Stevens <marc.stevens@cwi.nl>
#
#   This program is free software: you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation, either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <https://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

#serial 31

AU_ALIAS([ACX_PTHREAD], [AX_PTHREAD])
AC_DEFUN([AX_PTHREAD], [
AC_REQUIRE([AC_CANONICAL_HOST])
AC_REQUIRE([AC_PROG_CC])
AC_REQUIRE([AC_PROG_SED])
AC_LANG_PUSH([C])
ax_pthread_ok=no

# We used to check for pthread.h first, but this fails if pthread.h
# requires special compiler flags (e.g. on Tru64 or Sequent).
# It gets checked for in the link test anyway.

# First of all, check if the user has set any of the PTHREAD_LIBS,
# etcetera environment variables, and if threads linking works using
# them:
if test "x$PTHREAD_CFLAGS$PTHREAD_LIBS" != "x"; then
        ax_pthread_save_CC="$CC"
        ax_pthread_save_CFLAGS="$CFLAGS"
        ax_pthread_save_LIBS="$LIBS"
        AS_IF([test "x$PTHREAD_CC" != "x"], [CC="$PTHREAD_CC"])
        AS_IF([test "x$PTHREAD_CXX" != "x"], [CXX="$PTHREAD_CXX"])
        CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
        LIBS="$PTHREAD_LIBS $LIBS"
        AC_MSG_CHECKING([for pthread_join using $CC $PTHREAD_CFLAGS $PTHREAD_LIBS])
        AC_LINK_IFELSE([AC_LANG_CALL([], [pthread_join])], [ax_pthread_ok=yes])
        AC_MSG_RESULT([$ax_pthread_ok])
        if test "x$ax_pthread_ok" = "xno"; then
                PTHREAD_LIBS=""
                PTHREAD_CFLAGS=""
        fi
        CC="$ax_pthread_save_CC"
        CFLAGS="$ax_pthread_save_CFLAGS"
        LIBS="$ax_pthread_save_LIBS"
fi

# We must check for the threads library under a number of different
# names; the ordering is very important because some systems
# (e.g. DEC) have both -lpthread and -lpthreads, where one of the
# libraries is broken (non-POSIX).

# Create a list of thread flags to try. Items with a "," contain both
# C compiler flags (before ",") and linker flags (after ","). Other items
# starting with a "-" are C compiler flags, and remaining items are
# library names, except for "none" which indicates that we try without
# any flags at all, and "pthread-config" which is a program returning
# the flags for the Pth emulation library.

ax_pthread_flags="pthreads none -Kthread -pthread -pthreads -mthreads pthread --thread-safe -mt pthread-config"

# The ordering *is* (sometimes) important.  Some notes on the
# individual items follow:

# pthreads: AIX (must check this before -lpthread)
# none: in case threads are in libc; should be tried before -Kthread and
#       other compiler flags to prevent continual compiler warnings
# -Kthread: Sequent (threads in libc, but -Kthread needed for pthread.h)
# -pthread: Linux/gcc (kernel threads), BSD/gcc (userland threads), Tru64
#           (Note: HP C rejects this with "bad form for `-t' option")
# -pthreads: Solaris/gcc (Note: HP C also rejects)
# -mt: Sun Workshop C (may only link SunOS threads [-lthread], but it
#      doesn't hurt to check since this sometimes defines pthreads and
#      -D_REENTRANT too), HP C (must be checked before -lpthread, which
#      is present but should not be used directly; and before -mthreads,
#      because the compiler interprets this as "-mt" + "-hreads")
# -mthreads: Mingw32/gcc, Lynx/gcc
# pthread: Linux, etcetera
# --thread-safe: KAI C++
# pthread-config: use pthread-config program (for GNU Pth library)

case $host_os in

        freebsd*)

        # -kthread: FreeBSD kernel threads (preferred to -pthread since SMP-able)
        # lthread: LinuxThreads port on FreeBSD (also preferred to -pthread)

        ax_pthread_flags="-kthread lthread $ax_pthread_flags"
        ;;

        hpux*)

        # From the cc(1) man page: "[-mt] Sets various -D flags to enable
        # multi-threading and also sets -lpthread."

        ax_pthread_flags="-mt -pthread pthread $ax_pthread_flags"
        ;;

        openedition*)

        # IBM z/OS requires a feature-test macro to be defined in order to
        # enable POSIX threads at all, so give the user a hint if this is
        # not set. (We don't define these ourselves, as they can affect
        # other portions of the system API in unpredictable ways.)

        AC_EGREP_CPP([AX_PTHREAD_ZOS_MISSING],
            [
#            if !defined(_OPEN_THREADS) && !defined(_UNIX03_THREADS)
             AX_PTHREAD_ZOS_MISSING
#            endif
            ],
            [AC_MSG_WARN([IBM z/OS requires -D_OPEN_THREADS or -D_UNIX03_THREADS to enable pthreads support.])])
        ;;

        solaris*)

        # On Solaris (at least, for some versions), libc contains stubbed
        # (non-functional) versions of the pthreads routines, so link-based
        # tests will erroneously succeed. (N.B.: The stubs are missing
        # pthread_cleanup_push, or rather a function called by this macro,
        # so we could check for that, but who knows whether they'll stub
        # that too in a future libc.)  So we'll check first for the
        # standard Solaris way of linking pthreads (-mt -lpthread).

        ax_pthread_flags="-mt,-lpthread pthread $ax_pthread_flags"
        ;;
esac

# Are we compiling with Clang?

AC_CACHE_CHECK([whether $CC is Clang],
    [ax_cv_PTHREAD_CLANG],
    [ax_cv_PTHREAD_CLANG=no
     # Note that Autoconf sets GCC=yes for Clang as well as GCC
     if test "x$GCC" = "xyes"; then
        AC_EGREP_CPP([AX_PTHREAD_CC_IS_CLANG],
            [/* Note: Clang 2.7 lacks __clang_[a-z]+__ */
#            if defined(__clang__) && defined(__llvm__)
             AX_PTHREAD_CC_IS_CLANG
#            endif
            ],
            [ax_cv_PTHREAD_CLANG=yes])
     fi
    ])
ax_pthread_clang="$ax_cv_PTHREAD_CLANG"


# GCC generally uses -pthread, or -pthreads on some platforms (e.g. SPARC)

# Note that for GCC and Clang -pthread generally implies -lpthread,
# except when -nostdlib is passed.
# This is problematic using libtool to build C++ shared libraries with pthread:
# [1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=25460
# [2] https://bugzilla.redhat.com/show_bug.cgi?id=661333
# [3] https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=468555
# To solve this, first try -pthread together with -lpthread for GCC

AS_IF([test "x$GCC" = "xyes"],
      [ax_pthread_flags="-pthread,-lpthread -pthread -pthreads $ax_pthread_flags"])

# Clang takes -pthread (never supported any other flag), but we'll try with -lpthread first

AS_IF([test "x$ax_pthread_clang" = "xyes"],
      [ax_pthread_flags="-pthread,-lpthread -pthread"])


# The presence of a feature test macro requesting re-entrant function
# definitions is, on some systems, a strong hint that pthreads support is
# correctly enabled

case $host_os in
        darwin* | hpux* | linux* | osf* | solaris*)
        ax_pthread_check_macro="_REENTRANT"
        ;;

        aix*)
        ax_pthread_check_macro="_THREAD_SAFE"
        ;;

        *)
        ax_pthread_check_macro="--"
        ;;
esac
AS_IF([test "x$ax_pthread_check_macro" = "x--"],
      [ax_pthread_check_cond=0],
      [ax_pthread_check_cond="!defined($ax_pthread_check_macro)"])


if test "x$ax_pthread_ok" = "xno"; then
for ax_pthread_try_flag in $ax_pthread_flags; do

        case $ax_pthread_try_flag in
                none)
                AC_MSG_CHECKING([whether pthreads work without any flags])
                ;;

                *,*)
                PTHREAD_CFLAGS=`echo $ax_pthread_try_flag | sed "s/^\(.*\),\(.*\)$/\1/"`
                PTHREAD_LIBS=`echo $ax_pthread_try_flag | sed "s/^\(.*\),\(.*\)$/\2/"`
                AC_MSG_CHECKING([whether pthreads work with "$PTHREAD_CFLAGS" and "$PTHREAD_LIBS"])
                ;;

                -*)
                AC_MSG_CHECKING([whether pthreads work with $ax_pthread_try_flag])
                PTHREAD_CFLAGS="$ax_pthread_try_flag"
                ;;

                pthread-config)
                AC_CHECK_PROG([ax_pthread_config], [pthread-config], [yes], [no])
                AS_IF([test "x$ax_pthread_config" = "xno"], [continue])
                PTHREAD_CFLAGS="`pthread-config --cflags`"
                PTHREAD_LIBS="`pthread-config --ldflags` `pthread-config --libs`"
                ;;

                *)
                AC_MSG_CHECKING([for the pthreads library -l$ax_pthread_try_flag])
                PTHREAD_LIBS="-l$ax_pthread_try_flag"
                ;;
        esac

        ax_pthread_save_CFLAGS="$CFLAGS"
        ax_pthread_save_LIBS="$LIBS"
        CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
        LIBS="$PTHREAD_LIBS $LIBS"

        # Check for various functions.  We must include pthread.h,
        # since some functions may be macros.  (On the Sequent, we
        # need a special flag -Kthread to make this header compile.)
        # We check for pthread_join because it is in -lpthread on IRIX
        # while pthread_create is in libc.  We check for pthread_attr_init
        # due to DEC craziness with -lpthreads.  We check for
        # pthread_cleanup_push because it is one of the few pthread
        # functions on Solaris that doesn't have a non-functional libc stub.
        # We try pthread_create on general principles.

        AC_LINK_IFELSE([AC_LANG_PROGRAM([#include <pthread.h>
#                       if $ax_pthread_check_cond
#                        error "$ax_pthread_check_macro must be defined"
#                       endif
                        static void *some_global = NULL;
                        static void routine(void *a)
                          {
                             /* To avoid any unused-parameter or
                                unused-but-set-parameter warning.  */
                             some_global = a;
                          }
                        static void *start_routine(void *a) { return a; }],
                       [pthread_t th; pthread_attr_t attr;
                        pthread_create(&th, 0, start_routine, 0);
                        pthread_join(th, 0);
                        pthread_attr_init(&attr);
                        pthread_cleanup_push(routine, 0);
                        pthread_cleanup_pop(0) /* ; */])],
            [ax_pthread_ok=yes],
            [])

        CFLAGS="$ax_pthread_save_CFLAGS"
        LIBS="$ax_pthread_save_LIBS"

        AC_MSG_RESULT([$ax_pthread_ok])
        AS_IF([test "x$ax_pthread_ok" = "xyes"], [break])

        PTHREAD_LIBS=""
        PTHREAD_CFLAGS=""
done
fi


# Clang needs special handling, because older versions handle the -pthread
# option in a rather... idiosyncratic way

if test "x$ax_pthread_clang" = "xyes"; then

        # Clang takes -pthread; it has never supported any other flag

        # (Note 1: This will need to be revisited if a system that Clang
        # supports has POSIX threads in a separate library.  This tends not
        # to be the way of modern systems, but it's conceivable.)

        # (Note 2: On some systems, notably Darwin, -pthread is not needed
        # to get POSIX threads support; the API is always present and
        # active.  We could reasonably leave PTHREAD_CFLAGS empty.  But
        # -pthread does define _REENTRANT, and while the Darwin headers
        # ignore this macro, third-party headers might not.)

        # However, older versions of Clang make a point of warning the user
        # that, in an invocation where only linking and no compilation is
        # taking place, the -pthread option has no effect ("argument unused
        # during compilation").  They expect -pthread to be passed in only
        # when source code is being compiled.
        #
        # Problem is, this is at odds with the way Automake and most other
        # C build frameworks function, which is that the same flags used in
        # compilation (CFLAGS) are also used in linking.  Many systems
        # supported by AX_PTHREAD require exactly this for POSIX threads
        # support, and in fact it is often not straightforward to specify a
        # flag that is used only in the compilation phase and not in
        # linking.  Such a scenario is extremely rare in practice.
        #
        # Even though use of the -pthread flag in linking would only print
        # a warning, this can be a nuisance for well-run software projects
        # that build with -Werror.  So if the active version of Clang has
        # this misfeature, we search for an option to squash it.

        AC_CACHE_CHECK([whether Clang needs flag to prevent "argument unused" warning when linking with -pthread],
            [ax_cv_PTHREAD_CLANG_NO_WARN_FLAG],
            [ax_cv_PTHREAD_CLANG_NO_WARN_FLAG=unknown
             # Create an alternate version of $ac_link that compiles and
             # links in two steps (.c -> .o, .o -> exe) instead of one
             # (.c -> exe), because the warning occurs only in the second
             # step
             ax_pthread_save_ac_link="$ac_link"
             ax_pthread_sed='s/conftest\.\$ac_ext/conftest.$ac_objext/g'
             ax_pthread_link_step=`AS_ECHO(["$ac_link"]) | sed "$ax_pthread_sed"`
             ax_pthread_2step_ac_link="($ac_compile) && (echo ==== >&5) && ($ax_pthread_link_step)"
             ax_pthread_save_CFLAGS="$CFLAGS"
             for ax_pthread_try in '' -Qunused-arguments -Wno-unused-command-line-argument unknown; do
                AS_IF([test "x$ax_pthread_try" = "xunknown"], [break])
                CFLAGS="-Werror -Wunknown-warning-option $ax_pthread_try -pthread $ax_pthread_save_CFLAGS"
                ac_link="$ax_pthread_save_ac_link"
                AC_LINK_IFELSE([AC_LANG_SOURCE([[int main(void){return 0;}]])],
                    [ac_link="$ax_pthread_2step_ac_link"
                     AC_LINK_IFELSE([AC_LANG_SOURCE([[int main(void){return 0;}]])],
                         [break])
                    ])
             done
             ac_link="$ax_pthread_save_ac_link"
             CFLAGS="$ax_pthread_save_CFLAGS"
             AS_IF([test "x$ax_pthread_try" = "x"], [ax_pthread_try=no])
             ax_cv_PTHREAD_CLANG_NO_WARN_FLAG="$ax_pthread_try"
            ])

        case "$ax_cv_PTHREAD_CLANG_NO_WARN_FLAG" in
                no | unknown) ;;
                *) PTHREAD_CFLAGS="$ax_cv_PTHREAD_CLANG_NO_WARN_FLAG $PTHREAD_CFLAGS" ;;
        esac

fi # $ax_pthread_clang = yes



# Various other checks:
if test "x$ax_pthread_ok" = "xyes"; then
        ax_pthread_save_CFLAGS="$CFLAGS"
        ax_pthread_save_LIBS="$LIBS"
        CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
        LIBS="$PTHREAD_LIBS $LIBS"

        # Detect AIX lossage: JOINABLE attribute is called UNDETACHED.
        AC_CACHE_CHECK([for joinable pthread attribute],
            [ax_cv_PTHREAD_JOINABLE_ATTR],
            [ax_cv_PTHREAD_JOINABLE_ATTR=unknown
             for ax_pthread_attr in PTHREAD_CREATE_JOINABLE PTHREAD_CREATE_UNDETACHED; do
                 AC_LINK_IFELSE([AC_LANG_PROGRAM([#include <pthread.h>],
                                                 [int attr = $ax_pthread_attr; return attr /* ; */])],
                                [ax_cv_PTHREAD_JOINABLE_ATTR=$ax_pthread_attr; break],
                                [])
             done
            ])
        AS_IF([test "x$ax_cv_PTHREAD_JOINABLE_ATTR" != "xunknown" && \
               test "x$ax_cv_PTHREAD_JOINABLE_ATTR" != "xPTHREAD_CREATE_JOINABLE" && \
               test "x$ax_pthread_joinable_attr_defined" != "xyes"],
              [AC_DEFINE_UNQUOTED([PTHREAD_CREATE_JOINABLE],
                                  [$ax_cv_PTHREAD_JOINABLE_ATTR],
                                  [Define to necessary symbol if this constant
                                   uses a non-standard name on your system.])
               ax_pthread_joinable_attr_defined=yes
              ])

        AC_CACHE_CHECK([whether more special flags are required for pthreads],
            [ax_cv_PTHREAD_SPECIAL_FLAGS],
            [ax_cv_PTHREAD_SPECIAL_FLAGS=no
             case $host_os in
             solaris*)
             ax_cv_PTHREAD_SPECIAL_FLAGS="-D_POSIX_PTHREAD_SEMANTICS"
             ;;
             esac
            ])
        AS_IF([test "x$ax_cv_PTHREAD_SPECIAL_FLAGS" != "xno" && \
               test "x$ax_pthread_special_flags_added" != "xyes"],
              [PTHREAD_CFLAGS="$ax_cv_PTHREAD_SPECIAL_FLAGS $PTHREAD_CFLAGS"
               ax_pthread_special_flags_added=yes])

        AC_CACHE_CHECK([for PTHREAD_PRIO_INHERIT],
            [ax_cv_PTHREAD_PRIO_INHERIT],
            [AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <pthread.h>]],
                                             [[int i = PTHREAD_PRIO_INHERIT;
                                               return i;]])],
                            [ax_cv_PTHREAD_PRIO_INHERIT=yes],
                            [ax_cv_PTHREAD_PRIO_INHERIT=no])
            ])
        AS_IF([test "x$ax_cv_PTHREAD_PRIO_INHERIT" = "xyes" && \
               test "x$ax_pthread_prio_inherit_defined" != "xyes"],
              [AC_DEFINE([HAVE_PTHREAD_PRIO_INHERIT], [1], [Have PTHREAD_PRIO_INHERIT.])
               ax_pthread_prio_inherit_defined=yes
              ])

        CFLAGS="$ax_pthread_save_CFLAGS"
        LIBS="$ax_pthread_save_LIBS"

        # More AIX lossage: compile with *_r variant
        if test "x$GCC" != "xyes"; then
            case $host_os in
                aix*)
                AS_CASE(["x/$CC"],
                    [x*/c89|x*/c89_128|x*/c99|x*/c99_128|x*/cc|x*/cc128|x*/xlc|x*/xlc_v6|x*/xlc128|x*/xlc128_v6],
                    [#handle absolute path differently from PATH based program lookup
                     AS_CASE(["x$CC"],
                         [x/*],
                         [
			   AS_IF([AS_EXECUTABLE_P([${CC}_r])],[PTHREAD_CC="${CC}_r"])
			   AS_IF([test "x${CXX}" != "x"], [AS_IF([AS_EXECUTABLE_P([${CXX}_r])],[PTHREAD_CXX="${CXX}_r"])])
			 ],
                         [
			   AC_CHECK_PROGS([PTHREAD_CC],[${CC}_r],[$CC])
			   AS_IF([test "x${CXX}" != "x"], [AC_CHECK_PROGS([PTHREAD_CXX],[${CXX}_r],[$CXX])])
			 ]
                     )
                    ])
                ;;
            esac
        fi
fi

test -n "$PTHREAD_CC" || PTHREAD_CC="$CC"
test -n "$PTHREAD_CXX" || PTHREAD_CXX="$CXX"

AC_SUBST([PTHREAD_LIBS])
AC_SUBST([PTHREAD_CFLAGS])
AC_SUBST([PTHREAD_CC])
AC_SUBST([PTHREAD_CXX])

# Finally, execute ACTION-IF-FOUND/ACTION-IF-NOT-FOUND:
if test "x$ax_pthread_ok" = "xyes"; then
        ifelse([$1],,[AC_DEFINE([HAVE_PTHREAD],[1],[Define if you have POSIX threads libraries and header files.])],[$1])
        :
else
        ax_pthread_ok=no
        $2
fi
AC_LANG_POP
])dnl AX_PTHREAD

# Copyright (C) 2002-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_AUTOMAKE_VERSION(VERSION)
# ----------------------------
# Automake X.Y traces this macro to ensure aclocal.m4 has been
# generated from the m4 files accompanying Automake X.Y.
# (This private macro should not be called outside this file.)
AC_DEFUN([AM_AUTOMAKE_VERSION],
[am__api_version='1.18'
dnl Some users find AM_AUTOMAKE_VERSION and mistake it for a way to
dnl require some minimum version.  Point them to the right macro.
m4_if([$1], [1.18], [],
      [AC_FATAL([Do not call $0, use AM_INIT_AUTOMAKE([$1]).])])dnl
])

# _AM_AUTOCONF_VERSION(VERSION)
# -----------------------------
# aclocal traces this macro to find the Autoconf version.
# This is a private macro too.  Using m4_define simplifies
# the logic in aclocal, which can simply ignore this definition.
m4_define([_AM_AUTOCONF_VERSION], [])

# AM_SET_CURRENT_AUTOMAKE_VERSION
# -------------------------------
# Call AM_AUTOMAKE_VERSION and AM_AUTOMAKE_VERSION so they can be traced.
# This function is AC_REQUIREd by AM_INIT_AUTOMAKE.
AC_DEFUN([AM_SET_CURRENT_AUTOMAKE_VERSION],
[AM_AUTOMAKE_VERSION([1.18])dnl
m4_ifndef([AC_AUTOCONF_VERSION],
  [m4_copy([m4_PACKAGE_VERSION], [AC_AUTOCONF_VERSION])])dnl
_AM_AUTOCONF_VERSION(m4_defn([AC_AUTOCONF_VERSION]))])

# AM_AUX_DIR_EXPAND                                         -*- Autoconf -*-

# Copyright (C) 2001-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# For projects using AC_CONFIG_AUX_DIR([foo]), Autoconf sets
# $ac_aux_dir to '$srcdir/foo'.  In other projects, it is set to
# '$srcdir', '$srcdir/..', or '$srcdir/../..'.
#
# Of course, Automake must honor this variable whenever it calls a
# tool from the auxiliary directory.  The problem is that $srcdir (and
# therefore $ac_aux_dir as well) can be either absolute or relative,
# depending on how configure is run.  This is pretty annoying, since
# it makes $ac_aux_dir quite unusable in subdirectories: in the top
# source directory, any form will work fine, but in subdirectories a
# relative path needs to be adjusted first.
#
# $ac_aux_dir/missing
#    fails when called from a subdirectory if $ac_aux_dir is relative
# $top_srcdir/$ac_aux_dir/missing
#    fails if $ac_aux_dir is absolute,
#    fails when called from a subdirectory in a VPATH build with
#          a relative $ac_aux_dir
#
# The reason of the latter failure is that $top_srcdir and $ac_aux_dir
# are both prefixed by $srcdir.  In an in-source build this is usually
# harmless because $srcdir is '.', but things will broke when you
# start a VPATH build or use an absolute $srcdir.
#
# So we could use something similar to $top_srcdir/$ac_aux_dir/missing,
# iff we strip the leading $srcdir from $ac_aux_dir.  That would be:
#   am_aux_dir='\$(top_srcdir)/'`expr "$ac_aux_dir" : "$srcdir//*\(.*\)"`
# and then we would define $MISSING as
#   MISSING="\${SHELL} $am_aux_dir/missing"
# This will work as long as MISSING is not called from configure, because
# unfortunately $(top_srcdir) has no meaning in configure.
# However there are other variables, like CC, which are often used in
# configure, and could therefore not use this "fixed" $ac_aux_dir.
#
# Another solution, used here, is to always expand $ac_aux_dir to an
# absolute PATH.  The drawback is that using absolute paths prevent a
# configured tree to be moved without reconfiguration.

AC_DEFUN([AM_AUX_DIR_EXPAND],
[AC_REQUIRE([AC_CONFIG_AUX_DIR_DEFAULT])dnl
# Expand $ac_aux_dir to an absolute path.
am_aux_dir=`cd "$ac_aux_dir" && pwd`
])

# AM_CONDITIONAL                                            -*- Autoconf -*-

# Copyright (C) 1997-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_CONDITIONAL(NAME, SHELL-CONDITION)
# -------------------------------------
# Define a conditional.
AC_DEFUN([AM_CONDITIONAL],
[AC_PREREQ([2.52])dnl
 m4_if([$1], [TRUE],  [AC_FATAL([$0: invalid condition: $1])],
       [$1], [FALSE], [AC_FATAL([$0: invalid condition: $1])])dnl
AC_SUBST([$1_TRUE])dnl
AC_SUBST([$1_FALSE])dnl
_AM_SUBST_NOTMAKE([$1_TRUE])dnl
_AM_SUBST_NOTMAKE([$1_FALSE])dnl
m4_define([_AM_COND_VALUE_$1], [$2])dnl
if $2; then
  $1_TRUE=
  $1_FALSE='#'
else
  $1_TRUE='#'
  $1_FALSE=
fi
AC_CONFIG_COMMANDS_PRE(
[if test -z "${$1_TRUE}" && test -z "${$1_FALSE}"; then
  AC_MSG_ERROR([[conditional "$1" was never defined.
Usually this means the macro was only invoked conditionally.]])
fi])])

# Copyright (C) 1999-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.


# There are a few dirty hacks below to avoid letting 'AC_PROG_CC' be
# written in clear, in which case automake, when reading aclocal.m4,
# will think it sees a *use*, and therefore will trigger all it's
# C support machinery.  Also note that it means that autoscan, seeing
# CC etc. in the Makefile, will ask for an AC_PROG_CC use...


# _AM_DEPENDENCIES(NAME)
# ----------------------
# See how the compiler implements dependency checking.
# NAME is "CC", "CXX", "OBJC", "OBJCXX", "UPC", or "GJC".
# We try a few techniques and use that to set a single cache variable.
#
# We don't AC_REQUIRE the corresponding AC_PROG_CC since the latter was
# modified to invoke _AM_DEPENDENCIES(CC); we would have a circular
# dependency, and given that the user is not expected to run this macro,
# just rely on AC_PROG_CC.
AC_DEFUN([_AM_DEPENDENCIES],
[AC_REQUIRE([AM_SET_DEPDIR])dnl
AC_REQUIRE([AM_OUTPUT_DEPENDENCY_COMMANDS])dnl
AC_REQUIRE([AM_MAKE_INCLUDE])dnl
AC_REQUIRE([AM_DEP_TRACK])dnl

m4_if([$1], [CC],   [depcc="$CC"   am_compiler_list=],
      [$1], [CXX],  [depcc="$CXX"  am_compiler_list=],
      [$1], [OBJC], [depcc="$OBJC" am_compiler_list='gcc3 gcc'],
      [$1], [OBJCXX], [depcc="$OBJCXX" am_compiler_list='gcc3 gcc'],
      [$1], [UPC],  [depcc="$UPC"  am_compiler_list=],
      [$1], [GCJ],  [depcc="$GCJ"  am_compiler_list='gcc3 gcc'],
                    [depcc="$$1"   am_compiler_list=])

AC_CACHE_CHECK([dependency style of $depcc],
               [am_cv_$1_dependencies_compiler_type],
[if test -z "$AMDEP_TRUE" && test -f "$am_depcomp"; then
  # We make a subdir and do the tests there.  Otherwise we can end up
  # making bogus files that we don't know about and never remove.  For
  # instance it was reported that on HP-UX the gcc test will end up
  # making a dummy file named 'D' -- because '-MD' means "put the output
  # in D".
  rm -rf conftest.dir
  mkdir conftest.dir
  # Copy depcomp to subdir because otherwise we won't find it if we're
  # using a relative directory.
  cp "$am_depcomp" conftest.dir
  cd conftest.dir
  # We will build objects and dependencies in a subdirectory because
  # it helps to detect inapplicable dependency modes.  For instance
  # both Tru64's cc and ICC support -MD to output dependencies as a
  # side effect of compilation, but ICC will put the dependencies in
  # the current directory while Tru64 will put them in the object
  # directory.
  mkdir sub

  am_cv_$1_dependencies_compiler_type=none
  if test "$am_compiler_list" = ""; then
     am_compiler_list=`sed -n ['s/^#*\([a-zA-Z0-9]*\))$/\1/p'] < ./depcomp`
  fi
  am__universal=false
  m4_case([$1], [CC],
    [case " $depcc " in #(
     *\ -arch\ *\ -arch\ *) am__universal=true ;;
     esac],
    [CXX],
    [case " $depcc " in #(
     *\ -arch\ *\ -arch\ *) am__universal=true ;;
     esac])

  for depmode in $am_compiler_list; do
    # Setup a source with many dependencies, because some compilers
    # like to wrap large dependency lists on column 80 (with \), and
    # we should not choose a depcomp mode which is confused by this.
    #
    # We need to recreate these files for each test, as the compiler may
    # overwrite some of them when testing with obscure command lines.
    # This happens at least with the AIX C compiler.
    : > sub/conftest.c
    for i in 1 2 3 4 5 6; do
      echo '#include "conftst'$i'.h"' >> sub/conftest.c
      # Using ": > sub/conftst$i.h" creates only sub/conftst1.h with
      # Solaris 10 /bin/sh.
      echo '/* dummy */' > sub/conftst$i.h
    done
    echo "${am__include} ${am__quote}sub/conftest.Po${am__quote}" > confmf

    # We check with '-c' and '-o' for the sake of the "dashmstdout"
    # mode.  It turns out that the SunPro C++ compiler does not properly
    # handle '-M -o', and we need to detect this.  Also, some Intel
    # versions had trouble with output in subdirs.
    am__obj=sub/conftest.${OBJEXT-o}
    am__minus_obj="-o $am__obj"
    case $depmode in
    gcc)
      # This depmode causes a compiler race in universal mode.
      test "$am__universal" = false || continue
      ;;
    nosideeffect)
      # After this tag, mechanisms are not by side-effect, so they'll
      # only be used when explicitly requested.
      if test "x$enable_dependency_tracking" = xyes; then
	continue
      else
	break
      fi
      ;;
    msvc7 | msvc7msys | msvisualcpp | msvcmsys)
      # This compiler won't grok '-c -o', but also, the minuso test has
      # not run yet.  These depmodes are late enough in the game, and
      # so weak that their functioning should not be impacted.
      am__obj=conftest.${OBJEXT-o}
      am__minus_obj=
      ;;
    none) break ;;
    esac
    if depmode=$depmode \
       source=sub/conftest.c object=$am__obj \
       depfile=sub/conftest.Po tmpdepfile=sub/conftest.TPo \
       $SHELL ./depcomp $depcc -c $am__minus_obj sub/conftest.c \
         >/dev/null 2>conftest.err &&
       grep sub/conftst1.h sub/conftest.Po > /dev/null 2>&1 &&
       grep sub/conftst6.h sub/conftest.Po > /dev/null 2>&1 &&
       grep $am__obj sub/conftest.Po > /dev/null 2>&1 &&
       ${MAKE-make} -s -f confmf > /dev/null 2>&1; then
      # icc doesn't choke on unknown options, it will just issue warnings
      # or remarks (even with -Werror).  So we grep stderr for any message
      # that says an option was ignored or not supported.
      # When given -MP, icc 7.0 and 7.1 complain thus:
      #   icc: Command line warning: ignoring option '-M'; no argument required
      # The diagnosis changed in icc 8.0:
      #   icc: Command line remark: option '-MP' not supported
      if (grep 'ignoring option' conftest.err ||
          grep 'not supported' conftest.err) >/dev/null 2>&1; then :; else
        am_cv_$1_dependencies_compiler_type=$depmode
        break
      fi
    fi
  done

  cd ..
  rm -rf conftest.dir
else
  am_cv_$1_dependencies_compiler_type=none
fi
])
AC_SUBST([$1DEPMODE], [depmode=$am_cv_$1_dependencies_compiler_type])
AM_CONDITIONAL([am__fastdep$1], [
  test "x$enable_dependency_tracking" != xno \
  && test "$am_cv_$1_dependencies_compiler_type" = gcc3])
])


# AM_SET_DEPDIR
# -------------
# Choose a directory name for dependency files.
# This macro is AC_REQUIREd in _AM_DEPENDENCIES.
AC_DEFUN([AM_SET_DEPDIR],
[AC_REQUIRE([AM_SET_LEADING_DOT])dnl
AC_SUBST([DEPDIR], ["${am__leading_dot}deps"])dnl
])


# AM_DEP_TRACK
# ------------
AC_DEFUN([AM_DEP_TRACK],
[AC_ARG_ENABLE([dependency-tracking], [dnl
AS_HELP_STRING(
  [--enable-dependency-tracking],
  [do not reject slow dependency extractors])
AS_HELP_STRING(
  [--disable-dependency-tracking],
  [speeds up one-time build])])
if test "x$enable_dependency_tracking" != xno; then
  am_depcomp="$ac_aux_dir/depcomp"
  AMDEPBACKSLASH='\'
  am__nodep='_no'
fi
AM_CONDITIONAL([AMDEP], [test "x$enable_dependency_tracking" != xno])
AC_SUBST([AMDEPBACKSLASH])dnl
_AM_SUBST_NOTMAKE([AMDEPBACKSLASH])dnl
AC_SUBST([am__nodep])dnl
_AM_SUBST_NOTMAKE([am__nodep])dnl
])

# Generate code to set up dependency tracking.              -*- Autoconf -*-

# Copyright (C) 1999-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_OUTPUT_DEPENDENCY_COMMANDS
# ------------------------------
AC_DEFUN([_AM_OUTPUT_DEPENDENCY_COMMANDS],
[{
  # Older Autoconf quotes --file arguments for eval, but not when files
  # are listed without --file.  Let's play safe and only enable the eval
  # if we detect the quoting.
  # TODO: see whether this extra hack can be removed once we start
  # requiring Autoconf 2.70 or later.
  AS_CASE([$CONFIG_FILES],
          [*\'*], [eval set x "$CONFIG_FILES"],
          [*], [set x $CONFIG_FILES])
  shift
  # Used to flag and report bootstrapping failures.
  am_rc=0
  for am_mf
  do
    # Strip MF so we end up with the name of the file.
    am_mf=`AS_ECHO(["$am_mf"]) | sed -e 's/:.*$//'`
    # Check whether this is an Automake generated Makefile which includes
    # dependency-tracking related rules and includes.
    # Grep'ing the whole file directly is not great: AIX grep has a line
    # limit of 2048, but all sed's we know have understand at least 4000.
    sed -n 's,^am--depfiles:.*,X,p' "$am_mf" | grep X >/dev/null 2>&1 \
      || continue
    am_dirpart=`AS_DIRNAME(["$am_mf"])`
    am_filepart=`AS_BASENAME(["$am_mf"])`
    AM_RUN_LOG([cd "$am_dirpart" \
      && sed -e '/# am--include-marker/d' "$am_filepart" \
        | $MAKE -f - am--depfiles]) || am_rc=$?
  done
  if test $am_rc -ne 0; then
    AC_MSG_FAILURE([Something went wrong bootstrapping makefile fragments
    for automatic dependency tracking.  If GNU make was not used, consider
    re-running the configure script with MAKE="gmake" (or whatever is
    necessary).  You can also try re-running configure with the
    '--disable-dependency-tracking' option to at least be able to build
    the package (albeit without support for automatic dependency tracking).])
  fi
  AS_UNSET([am_dirpart])
  AS_UNSET([am_filepart])
  AS_UNSET([am_mf])
  AS_UNSET([am_rc])
  rm -f conftest-deps.mk
}
])# _AM_OUTPUT_DEPENDENCY_COMMANDS


# AM_OUTPUT_DEPENDENCY_COMMANDS
# -----------------------------
# This macro should only be invoked once -- use via AC_REQUIRE.
#
# This code is only required when automatic dependency tracking is enabled.
# This creates each '.Po' and '.Plo' makefile fragment that we'll need in
# order to bootstrap the dependency handling code.
AC_DEFUN([AM_OUTPUT_DEPENDENCY_COMMANDS],
[AC_CONFIG_COMMANDS([depfiles],
     [test x"$AMDEP_TRUE" != x"" || _AM_OUTPUT_DEPENDENCY_COMMANDS],
     [AMDEP_TRUE="$AMDEP_TRUE" MAKE="${MAKE-make}"])])

# Do all the work for Automake.                             -*- Autoconf -*-

# Copyright (C) 1996-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This macro actually does too much.  Some checks are only needed if
# your package does certain things.  But this isn't really a big deal.

dnl Redefine AC_PROG_CC to automatically invoke _AM_PROG_CC_C_O.
m4_define([AC_PROG_CC],
m4_defn([AC_PROG_CC])
[_AM_PROG_CC_C_O
])

# AM_INIT_AUTOMAKE(PACKAGE, VERSION, [NO-DEFINE])
# AM_INIT_AUTOMAKE([OPTIONS])
# -----------------------------------------------
# The call with PACKAGE and VERSION arguments is the old style
# call (pre autoconf-2.50), which is being phased out.  PACKAGE
# and VERSION should now be passed to AC_INIT and removed from
# the call to AM_INIT_AUTOMAKE.
# We support both call styles for the transition.  After
# the next Automake release, Autoconf can make the AC_INIT
# arguments mandatory, and then we can depend on a new Autoconf
# release and drop the old call support.
AC_DEFUN([AM_INIT_AUTOMAKE],
[AC_PREREQ([2.65])dnl
m4_ifdef([_$0_ALREADY_INIT],
  [m4_fatal([$0 expanded multiple times
]m4_defn([_$0_ALREADY_INIT]))],
  [m4_define([_$0_ALREADY_INIT], m4_expansion_stack)])dnl
dnl Autoconf wants to disallow AM_ names.  We explicitly allow
dnl the ones we care about.
m4_pattern_allow([^AM_[A-Z]+FLAGS$])dnl
AC_REQUIRE([AM_SET_CURRENT_AUTOMAKE_VERSION])dnl
AC_REQUIRE([AC_PROG_INSTALL])dnl
if test "`cd $srcdir && pwd`" != "`pwd`"; then
  # Use -I$(srcdir) only when $(srcdir) != ., so that make's output
  # is not polluted with repeated "-I."
  AC_SUBST([am__isrc], [' -I$(srcdir)'])_AM_SUBST_NOTMAKE([am__isrc])dnl
  # test to see if srcdir already configured
  if test -f $srcdir/config.status; then
    AC_MSG_ERROR([source directory already configured; run "make distclean" there first])
  fi
fi

# test whether we have cygpath
if test -z "$CYGPATH_W"; then
  if (cygpath --version) >/dev/null 2>/dev/null; then
    CYGPATH_W='cygpath -w'
  else
    CYGPATH_W=echo
  fi
fi
AC_SUBST([CYGPATH_W])

# Define the identity of the package.
dnl Distinguish between old-style and new-style calls.
m4_ifval([$2],
[AC_DIAGNOSE([obsolete],
             [$0: two- and three-arguments forms are deprecated.])
m4_ifval([$3], [_AM_SET_OPTION([no-define])])dnl
 AC_SUBST([PACKAGE], [$1])dnl
 AC_SUBST([VERSION], [$2])],
[_AM_SET_OPTIONS([$1])dnl
dnl Diagnose old-style AC_INIT with new-style AM_AUTOMAKE_INIT.
m4_if(
  m4_ifset([AC_PACKAGE_NAME], [ok]):m4_ifset([AC_PACKAGE_VERSION], [ok]),
  [ok:ok],,
  [m4_fatal([AC_INIT should be called with package and version arguments])])dnl
 AC_SUBST([PACKAGE], ['AC_PACKAGE_TARNAME'])dnl
 AC_SUBST([VERSION], ['AC_PACKAGE_VERSION'])])dnl

_AM_IF_OPTION([no-define],,
[AC_DEFINE_UNQUOTED([PACKAGE], ["$PACKAGE"], [Name of package])
 AC_DEFINE_UNQUOTED([VERSION], ["$VERSION"], [Version number of package])])dnl

# Some tools Automake needs.
AC_REQUIRE([AM_SANITY_CHECK])dnl
AC_REQUIRE([AC_ARG_PROGRAM])dnl
AM_MISSING_PROG([ACLOCAL], [aclocal-${am__api_version}])
AM_MISSING_PROG([AUTOCONF], [autoconf])
AM_MISSING_PROG([AUTOMAKE], [automake-${am__api_version}])
AM_MISSING_PROG([AUTOHEADER], [autoheader])
AM_MISSING_PROG([MAKEINFO], [makeinfo])
AC_REQUIRE([AM_PROG_INSTALL_SH])dnl
AC_REQUIRE([AM_PROG_INSTALL_STRIP])dnl
AC_REQUIRE([AC_PROG_MKDIR_P])dnl
# For better backward compatibility.  To be removed once Automake 1.9.x
# dies out for good.  For more background, see:
# <https://lists.gnu.org/archive/html/automake/2012-07/msg00001.html>
# <https://lists.gnu.org/archive/html/automake/2012-07/msg00014.html>
AC_SUBST([mkdir_p], ['$(MKDIR_P)'])
# We need awk for the "check" target (and possibly the TAP driver).  The
# system "awk" is bad on some platforms.
AC_REQUIRE([AC_PROG_AWK])dnl
AC_REQUIRE([AC_PROG_MAKE_SET])dnl
AC_REQUIRE([AM_SET_LEADING_DOT])dnl
_AM_IF_OPTION([tar-ustar], [_AM_PROG_TAR([ustar])],
  [_AM_IF_OPTION([tar-pax], [_AM_PROG_TAR([pax])],
    [_AM_IF_OPTION([tar-v7], [_AM_PROG_TAR([v7])],
      [_AM_PROG_TAR([ustar])])])])
_AM_IF_OPTION([no-dependencies],,
[AC_PROVIDE_IFELSE([AC_PROG_CC],
		  [_AM_DEPENDENCIES([CC])],
		  [m4_define([AC_PROG_CC],
			     m4_defn([AC_PROG_CC])[_AM_DEPENDENCIES([CC])])])dnl
AC_PROVIDE_IFELSE([AC_PROG_CXX],
		  [_AM_DEPENDENCIES([CXX])],
		  [m4_define([AC_PROG_CXX],
			     m4_defn([AC_PROG_CXX])[_AM_DEPENDENCIES([CXX])])])dnl
AC_PROVIDE_IFELSE([AC_PROG_OBJC],
		  [_AM_DEPENDENCIES([OBJC])],
		  [m4_define([AC_PROG_OBJC],
			     m4_defn([AC_PROG_OBJC])[_AM_DEPENDENCIES([OBJC])])])dnl
AC_PROVIDE_IFELSE([AC_PROG_OBJCXX],
		  [_AM_DEPENDENCIES([OBJCXX])],
		  [m4_define([AC_PROG_OBJCXX],
			     m4_defn([AC_PROG_OBJCXX])[_AM_DEPENDENCIES([OBJCXX])])])dnl
])
# Variables for tags utilities; see am/tags.am
if test -z "$CTAGS"; then
  CTAGS=ctags
fi
AC_SUBST([CTAGS])
if test -z "$ETAGS"; then
  ETAGS=etags
fi
AC_SUBST([ETAGS])
if test -z "$CSCOPE"; then
  CSCOPE=cscope
fi
AC_SUBST([CSCOPE])

AC_REQUIRE([_AM_SILENT_RULES])dnl
dnl The testsuite driver may need to know about EXEEXT, so add the
dnl 'am__EXEEXT' conditional if _AM_COMPILER_EXEEXT was seen.  This
dnl macro is hooked onto _AC_COMPILER_EXEEXT early, see below.
AC_CONFIG_COMMANDS_PRE(dnl
[m4_provide_if([_AM_COMPILER_EXEEXT],
  [AM_CONDITIONAL([am__EXEEXT], [test -n "$EXEEXT"])])])dnl

AC_REQUIRE([_AM_PROG_RM_F])
AC_REQUIRE([_AM_PROG_XARGS_N])

dnl The trailing newline in this macro's definition is deliberate, for
dnl backward compatibility and to allow trailing 'dnl'-style comments
dnl after the AM_INIT_AUTOMAKE invocation. See automake bug#16841.
])

dnl Hook into '_AC_COMPILER_EXEEXT' early to learn its expansion.  Do not
dnl add the conditional right here, as _AC_COMPILER_EXEEXT may be further
dnl mangled by Autoconf and run in a shell conditional statement.
m4_define([_AC_COMPILER_EXEEXT],
m4_defn([_AC_COMPILER_EXEEXT])[m4_provide([_AM_COMPILER_EXEEXT])])

# When config.status generates a header, we must update the stamp-h file.
# This file resides in the same directory as the config header
# that is generated.  The stamp files are numbered to have different names.

# Autoconf calls _AC_AM_CONFIG_HEADER_HOOK (when defined) in the
# loop where config.status creates the headers, so we can generate
# our stamp files there.
AC_DEFUN([_AC_AM_CONFIG_HEADER_HOOK],
[# Compute $1's index in $config_headers.
_am_arg=$1
_am_stamp_count=1
for _am_header in $config_headers :; do
  case $_am_header in
    $_am_arg | $_am_arg:* )
      break ;;
    * )
      _am_stamp_count=`expr $_am_stamp_count + 1` ;;
  esac
done
echo "timestamp for $_am_arg" >`AS_DIRNAME(["$_am_arg"])`/stamp-h[]$_am_stamp_count])

# Copyright (C) 2001-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_PROG_INSTALL_SH
# ------------------
# Define $install_sh.
AC_DEFUN([AM_PROG_INSTALL_SH],
[AC_REQUIRE([AM_AUX_DIR_EXPAND])dnl
if test x"${install_sh+set}" != xset; then
  case $am_aux_dir in
  *\ * | *\	*)
    install_sh="\${SHELL} '$am_aux_dir/install-sh'" ;;
  *)
    install_sh="\${SHELL} $am_aux_dir/install-sh"
  esac
fi
AC_SUBST([install_sh])])

# Copyright (C) 2003-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# Check whether the underlying file-system supports filenames
# with a leading dot.  For instance MS-DOS doesn't.
AC_DEFUN([AM_SET_LEADING_DOT],
[rm -rf .tst 2>/dev/null
mkdir .tst 2>/dev/null
if test -d .tst; then
  am__leading_dot=.
else
  am__leading_dot=_
fi
rmdir .tst 2>/dev/null
AC_SUBST([am__leading_dot])])

# Add --enable-maintainer-mode option to configure.         -*- Autoconf -*-
# From Jim Meyering

# Copyright (C) 1996-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_MAINTAINER_MODE([DEFAULT-MODE])
# ----------------------------------
# Control maintainer-specific portions of Makefiles.
# Default is to disable them, unless 'enable' is passed literally.
# For symmetry, 'disable' may be passed as well.  Anyway, the user
# can override the default with the --enable/--disable switch.
AC_DEFUN([AM_MAINTAINER_MODE],
[m4_case(m4_default([$1], [disable]),
       [enable], [m4_define([am_maintainer_other], [disable])],
       [disable], [m4_define([am_maintainer_other], [enable])],
       [m4_define([am_maintainer_other], [enable])
        m4_warn([syntax], [unexpected argument to AM@&t@_MAINTAINER_MODE: $1])])
AC_MSG_CHECKING([whether to enable maintainer-specific portions of Makefiles])
  dnl maintainer-mode's default is 'disable' unless 'enable' is passed
  AC_ARG_ENABLE([maintainer-mode],
    [AS_HELP_STRING([--]am_maintainer_other[-maintainer-mode],
      am_maintainer_other[ make rules and dependencies not useful
      (and sometimes confusing) to the casual installer])],
    [USE_MAINTAINER_MODE=$enableval],
    [USE_MAINTAINER_MODE=]m4_if(am_maintainer_other, [enable], [no], [yes]))
  AC_MSG_RESULT([$USE_MAINTAINER_MODE])
  AM_CONDITIONAL([MAINTAINER_MODE], [test $USE_MAINTAINER_MODE = yes])
  MAINT=$MAINTAINER_MODE_TRUE
  AC_SUBST([MAINT])dnl
]
)

# Check to see how 'make' treats includes.	            -*- Autoconf -*-

# Copyright (C) 2001-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_MAKE_INCLUDE()
# -----------------
# Check whether make has an 'include' directive that can support all
# the idioms we need for our automatic dependency tracking code.
AC_DEFUN([AM_MAKE_INCLUDE],
[AC_MSG_CHECKING([whether ${MAKE-make} supports the include directive])
cat > confinc.mk << 'END'
am__doit:
	@echo this is the am__doit target >confinc.out
.PHONY: am__doit
END
am__include="#"
am__quote=
# BSD make does it like this.
echo '.include "confinc.mk" # ignored' > confmf.BSD
# Other make implementations (GNU, Solaris 10, AIX) do it like this.
echo 'include confinc.mk # ignored' > confmf.GNU
_am_result=no
for s in GNU BSD; do
  AM_RUN_LOG([${MAKE-make} -f confmf.$s && cat confinc.out])
  AS_CASE([$?:`cat confinc.out 2>/dev/null`],
      ['0:this is the am__doit target'],
      [AS_CASE([$s],
          [BSD], [am__include='.include' am__quote='"'],
          [am__include='include' am__quote=''])])
  if test "$am__include" != "#"; then
    _am_result="yes ($s style)"
    break
  fi
done
rm -f confinc.* confmf.*
AC_MSG_RESULT([${_am_result}])
AC_SUBST([am__include])])
AC_SUBST([am__quote])])

# Fake the existence of programs that GNU maintainers use.  -*- Autoconf -*-

# Copyright (C) 1997-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_MISSING_PROG(NAME, PROGRAM)
# ------------------------------
AC_DEFUN([AM_MISSING_PROG],
[AC_REQUIRE([AM_MISSING_HAS_RUN])
$1=${$1-"${am_missing_run}$2"}
AC_SUBST($1)])

# AM_MISSING_HAS_RUN
# ------------------
# Define MISSING if not defined so far and test if it is modern enough.
# If it is, set am_missing_run to use it, otherwise, to nothing.
AC_DEFUN([AM_MISSING_HAS_RUN],
[AC_REQUIRE([AM_AUX_DIR_EXPAND])dnl
AC_REQUIRE_AUX_FILE([missing])dnl
if test x"${MISSING+set}" != xset; then
  MISSING="\${SHELL} '$am_aux_dir/missing'"
fi
# Use eval to expand $SHELL
if eval "$MISSING --is-lightweight"; then
  am_missing_run="$MISSING "
else
  am_missing_run=
  AC_MSG_WARN(['missing' script is too old or missing])
fi
])

# Helper functions for option handling.                     -*- Autoconf -*-

# Copyright (C) 2001-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_MANGLE_OPTION(NAME)
# -----------------------
AC_DEFUN([_AM_MANGLE_OPTION],
[[_AM_OPTION_]m4_bpatsubst($1, [[^a-zA-Z0-9_]], [_])])

# _AM_SET_OPTION(NAME)
# --------------------
# Set option NAME.  Presently that only means defining a flag for this option.
AC_DEFUN([_AM_SET_OPTION],
[m4_define(_AM_MANGLE_OPTION([$1]), [1])])

# _AM_SET_OPTIONS(OPTIONS)
# ------------------------
# OPTIONS is a space-separated list of Automake options.
AC_DEFUN([_AM_SET_OPTIONS],
[m4_foreach_w([_AM_Option], [$1], [_AM_SET_OPTION(_AM_Option)])])

# _AM_IF_OPTION(OPTION, IF-SET, [IF-NOT-SET])
# -------------------------------------------
# Execute IF-SET if OPTION is set, IF-NOT-SET otherwise.
AC_DEFUN([_AM_IF_OPTION],
[m4_ifset(_AM_MANGLE_OPTION([$1]), [$2], [$3])])

# Copyright (C) 1999-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_PROG_CC_C_O
# ---------------
# Like AC_PROG_CC_C_O, but changed for automake.  We rewrite AC_PROG_CC
# to automatically call this.
AC_DEFUN([_AM_PROG_CC_C_O],
[AC_REQUIRE([AM_AUX_DIR_EXPAND])dnl
AC_REQUIRE_AUX_FILE([compile])dnl
AC_LANG_PUSH([C])dnl
AC_CACHE_CHECK(
  [whether $CC understands -c and -o together],
  [am_cv_prog_cc_c_o],
  [AC_LANG_CONFTEST([AC_LANG_PROGRAM([])])
  # Make sure it works both with $CC and with simple cc.
  # Following AC_PROG_CC_C_O, we do the test twice because some
  # compilers refuse to overwrite an existing .o file with -o,
  # though they will create one.
  am_cv_prog_cc_c_o=yes
  for am_i in 1 2; do
    if AM_RUN_LOG([$CC -c conftest.$ac_ext -o conftest2.$ac_objext]) \
         && test -f conftest2.$ac_objext; then
      : OK
    else
      am_cv_prog_cc_c_o=no
      break
    fi
  done
  # aligned with autoconf, so not including core; see bug#72225.
  rm -f -r a.out a.exe b.out conftest.$ac_ext conftest.$ac_objext \
    conftest.dSYM conftest1.$ac_ext conftest1.$ac_objext conftest1.dSYM \
    conftest2.$ac_ext conftest2.$ac_objext conftest2.dSYM
  unset am_i])
if test "$am_cv_prog_cc_c_o" != yes; then
   # Losing compiler, so override with the script.
   # FIXME: It is wrong to rewrite CC.
   # But if we don't then we get into trouble of one sort or another.
   # A longer-term fix would be to have automake use am__CC in this case,
   # and then we could set am__CC="\$(top_srcdir)/compile \$(CC)"
   CC="$am_aux_dir/compile $CC"
fi
AC_LANG_POP([C])])

# For backward compatibility.
AC_DEFUN_ONCE([AM_PROG_CC_C_O], [AC_REQUIRE([AC_PROG_CC])])

# Copyright (C) 2022-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_PROG_RM_F
# ---------------
# Check whether 'rm -f' without any arguments works.
# https://bugs.gnu.org/10828
AC_DEFUN([_AM_PROG_RM_F],
[am__rm_f_notfound=
AS_IF([(rm -f && rm -fr && rm -rf) 2>/dev/null], [], [am__rm_f_notfound='""'])
AC_SUBST(am__rm_f_notfound)
])

# Copyright (C) 2001-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_RUN_LOG(COMMAND)
# -------------------
# Run COMMAND, save the exit status in ac_status, and log it.
# (This has been adapted from Autoconf's _AC_RUN_LOG macro.)
AC_DEFUN([AM_RUN_LOG],
[{ echo "$as_me:$LINENO: $1" >&AS_MESSAGE_LOG_FD
   ($1) >&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD
   ac_status=$?
   echo "$as_me:$LINENO: \$? = $ac_status" >&AS_MESSAGE_LOG_FD
   (exit $ac_status); }])

# Check to make sure that the build environment is sane.    -*- Autoconf -*-

# Copyright (C) 1996-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_SLEEP_FRACTIONAL_SECONDS
# ----------------------------
AC_DEFUN([_AM_SLEEP_FRACTIONAL_SECONDS], [dnl
AC_CACHE_CHECK([whether sleep supports fractional seconds],
               am_cv_sleep_fractional_seconds, [dnl
AS_IF([sleep 0.001 2>/dev/null], [am_cv_sleep_fractional_seconds=yes],
                                 [am_cv_sleep_fractional_seconds=no])
])])

# _AM_FILESYSTEM_TIMESTAMP_RESOLUTION
# -----------------------------------
# Determine the filesystem's resolution for file modification
# timestamps.  The coarsest we know of is FAT, with a resolution
# of only two seconds, even with the most recent "exFAT" extensions.
# The finest (e.g. ext4 with large inodes, XFS, ZFS) is one
# nanosecond, matching clock_gettime.  However, it is probably not
# possible to delay execution of a shell script for less than one
# millisecond, due to process creation overhead and scheduling
# granularity, so we don't check for anything finer than that. (See below.)
AC_DEFUN([_AM_FILESYSTEM_TIMESTAMP_RESOLUTION], [dnl
AC_REQUIRE([_AM_SLEEP_FRACTIONAL_SECONDS])
AC_CACHE_CHECK([filesystem timestamp resolution],
               am_cv_filesystem_timestamp_resolution, [dnl
# Default to the worst case.
am_cv_filesystem_timestamp_resolution=2

# Only try to go finer than 1 sec if sleep can do it.
# Don't try 1 sec, because if 0.01 sec and 0.1 sec don't work,
# - 1 sec is not much of a win compared to 2 sec, and
# - it takes 2 seconds to perform the test whether 1 sec works.
# 
# Instead, just use the default 2s on platforms that have 1s resolution,
# accept the extra 1s delay when using $sleep in the Automake tests, in
# exchange for not incurring the 2s delay for running the test for all
# packages.
#
am_try_resolutions=
if test "$am_cv_sleep_fractional_seconds" = yes; then
  # Even a millisecond often causes a bunch of false positives,
  # so just try a hundredth of a second. The time saved between .001 and
  # .01 is not terribly consequential.
  am_try_resolutions="0.01 0.1 $am_try_resolutions"
fi

# In order to catch current-generation FAT out, we must *modify* files
# that already exist; the *creation* timestamp is finer.  Use names
# that make ls -t sort them differently when they have equal
# timestamps than when they have distinct timestamps, keeping
# in mind that ls -t prints the *newest* file first.
rm -f conftest.ts?
: > conftest.ts1
: > conftest.ts2
: > conftest.ts3

# Make sure ls -t actually works.  Do 'set' in a subshell so we don't
# clobber the current shell's arguments. (Outer-level square brackets
# are removed by m4; they're present so that m4 does not expand
# <dollar><star>; be careful, easy to get confused.)
if (
     set X `[ls -t conftest.ts[12]]` &&
     {
       test "$[]*" != "X conftest.ts1 conftest.ts2" ||
       test "$[]*" != "X conftest.ts2 conftest.ts1";
     }
); then :; else
  # If neither matched, then we have a broken ls.  This can happen
  # if, for instance, CONFIG_SHELL is bash and it inherits a
  # broken ls alias from the environment.  This has actually
  # happened.  Such a system could not be considered "sane".
  _AS_ECHO_UNQUOTED(
    ["Bad output from ls -t: \"`[ls -t conftest.ts[12]]`\""],
    [AS_MESSAGE_LOG_FD])
  AC_MSG_FAILURE([ls -t produces unexpected output.
Make sure there is not a broken ls alias in your environment.])
fi

for am_try_res in $am_try_resolutions; do
  # Any one fine-grained sleep might happen to cross the boundary
  # between two values of a coarser actual resolution, but if we do
  # two fine-grained sleeps in a row, at least one of them will fall
  # entirely within a coarse interval.
  echo alpha > conftest.ts1
  sleep $am_try_res
  echo beta > conftest.ts2
  sleep $am_try_res
  echo gamma > conftest.ts3

  # We assume that 'ls -t' will make use of high-resolution
  # timestamps if the operating system supports them at all.
  if (set X `ls -t conftest.ts?` &&
      test "$[]2" = conftest.ts3 &&
      test "$[]3" = conftest.ts2 &&
      test "$[]4" = conftest.ts1); then
    #
    # Ok, ls -t worked. If we're at a resolution of 1 second, we're done,
    # because we don't need to test make.
    make_ok=true
    if test $am_try_res != 1; then
      # But if we've succeeded so far with a subsecond resolution, we
      # have one more thing to check: make. It can happen that
      # everything else supports the subsecond mtimes, but make doesn't;
      # notably on macOS, which ships make 3.81 from 2006 (the last one
      # released under GPLv2). https://bugs.gnu.org/68808
      # 
      # We test $MAKE if it is defined in the environment, else "make".
      # It might get overridden later, but our hope is that in practice
      # it does not matter: it is the system "make" which is (by far)
      # the most likely to be broken, whereas if the user overrides it,
      # probably they did so with a better, or at least not worse, make.
      # https://lists.gnu.org/archive/html/automake/2024-06/msg00051.html
      #
      # Create a Makefile (real tab character here):
      rm -f conftest.mk
      echo 'conftest.ts1: conftest.ts2' >conftest.mk
      echo '	touch conftest.ts2' >>conftest.mk
      #
      # Now, running
      #   touch conftest.ts1; touch conftest.ts2; make
      # should touch ts1 because ts2 is newer. This could happen by luck,
      # but most often, it will fail if make's support is insufficient. So
      # test for several consecutive successes.
      #
      # (We reuse conftest.ts[12] because we still want to modify existing
      # files, not create new ones, per above.)
      n=0
      make=${MAKE-make}
      until test $n -eq 3; do
        echo one > conftest.ts1
        sleep $am_try_res
        echo two > conftest.ts2 # ts2 should now be newer than ts1
        if $make -f conftest.mk | grep 'up to date' >/dev/null; then
          make_ok=false
          break # out of $n loop
        fi
        n=`expr $n + 1`
      done
    fi
    #
    if $make_ok; then
      # Everything we know to check worked out, so call this resolution good.
      am_cv_filesystem_timestamp_resolution=$am_try_res
      break # out of $am_try_res loop
    fi
    # Otherwise, we'll go on to check the next resolution.
  fi
done
rm -f conftest.ts?
# (end _am_filesystem_timestamp_resolution)
])])

# AM_SANITY_CHECK
# ---------------
AC_DEFUN([AM_SANITY_CHECK],
[AC_REQUIRE([_AM_FILESYSTEM_TIMESTAMP_RESOLUTION])
# This check should not be cached, as it may vary across builds of
# different projects.
AC_MSG_CHECKING([whether build environment is sane])
# Reject unsafe characters in $srcdir or the absolute working directory
# name.  Accept space and tab only in the latter.
am_lf='
'
case `pwd` in
  *[[\\\"\#\$\&\'\`$am_lf]]*)
    AC_MSG_RESULT([no])
    AC_MSG_ERROR([unsafe absolute working directory name]);;
esac
case $srcdir in
  *[[\\\"\#\$\&\'\`$am_lf\ \	]]*)
    AC_MSG_RESULT([no])
    AC_MSG_ERROR([unsafe srcdir value: '$srcdir']);;
esac

# Do 'set' in a subshell so we don't clobber the current shell's
# arguments.  Must try -L first in case configure is actually a
# symlink; some systems play weird games with the mod time of symlinks
# (eg FreeBSD returns the mod time of the symlink's containing
# directory).
am_build_env_is_sane=no
am_has_slept=no
rm -f conftest.file
for am_try in 1 2; do
  echo "timestamp, slept: $am_has_slept" > conftest.file
  if (
    set X `ls -Lt "$srcdir/configure" conftest.file 2> /dev/null`
    if test "$[]*" = "X"; then
      # -L didn't work.
      set X `ls -t "$srcdir/configure" conftest.file`
    fi
    test "$[]2" = conftest.file
  ); then
    am_build_env_is_sane=yes
    break
  fi
  # Just in case.
  sleep "$am_cv_filesystem_timestamp_resolution"
  am_has_slept=yes
done

AC_MSG_RESULT([$am_build_env_is_sane])
if test "$am_build_env_is_sane" = no; then
  AC_MSG_ERROR([newly created file is older than distributed files!
Check your system clock])
fi

# If we didn't sleep, we still need to ensure time stamps of config.status and
# generated files are strictly newer.
am_sleep_pid=
AS_IF([test -e conftest.file || grep 'slept: no' conftest.file >/dev/null 2>&1],, [dnl
  ( sleep "$am_cv_filesystem_timestamp_resolution" ) &
  am_sleep_pid=$!
])
AC_CONFIG_COMMANDS_PRE(
  [AC_MSG_CHECKING([that generated files are newer than configure])
   if test -n "$am_sleep_pid"; then
     # Hide warnings about reused PIDs.
     wait $am_sleep_pid 2>/dev/null
   fi
   AC_MSG_RESULT([done])])
rm -f conftest.file
])

# Copyright (C) 2009-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_SILENT_RULES
# ----------------
# Enable less verbose build rules support.
AC_DEFUN([_AM_SILENT_RULES],
[AM_DEFAULT_VERBOSITY=1
AC_ARG_ENABLE([silent-rules], [dnl
AS_HELP_STRING(
  [--enable-silent-rules],
  [less verbose build output (undo: "make V=1")])
AS_HELP_STRING(
  [--disable-silent-rules],
  [verbose build output (undo: "make V=0")])dnl
])
dnl
dnl A few 'make' implementations (e.g., NonStop OS and NextStep)
dnl do not support nested variable expansions.
dnl See automake bug#9928 and bug#10237.
am_make=${MAKE-make}
AC_CACHE_CHECK([whether $am_make supports nested variables],
   [am_cv_make_support_nested_variables],
   [if AS_ECHO([['TRUE=$(BAR$(V))
BAR0=false
BAR1=true
V=1
am__doit:
	@$(TRUE)
.PHONY: am__doit']]) | $am_make -f - >/dev/null 2>&1; then
  am_cv_make_support_nested_variables=yes
else
  am_cv_make_support_nested_variables=no
fi])
AC_SUBST([AM_V])dnl
AM_SUBST_NOTMAKE([AM_V])dnl
AC_SUBST([AM_DEFAULT_V])dnl
AM_SUBST_NOTMAKE([AM_DEFAULT_V])dnl
AC_SUBST([AM_DEFAULT_VERBOSITY])dnl
AM_BACKSLASH='\'
AC_SUBST([AM_BACKSLASH])dnl
_AM_SUBST_NOTMAKE([AM_BACKSLASH])dnl
dnl Delay evaluation of AM_DEFAULT_VERBOSITY to the end to allow multiple calls
dnl to AM_SILENT_RULES to change the default value.
AC_CONFIG_COMMANDS_PRE([dnl
case $enable_silent_rules in @%:@ (((
  yes) AM_DEFAULT_VERBOSITY=0;;
   no) AM_DEFAULT_VERBOSITY=1;;
esac
if test $am_cv_make_support_nested_variables = yes; then
  dnl Using '$V' instead of '$(V)' breaks IRIX make.
  AM_V='$(V)'
  AM_DEFAULT_V='$(AM_DEFAULT_VERBOSITY)'
else
  AM_V=$AM_DEFAULT_VERBOSITY
  AM_DEFAULT_V=$AM_DEFAULT_VERBOSITY
fi
])dnl
])

# AM_SILENT_RULES([DEFAULT])
# --------------------------
# Set the default verbosity level to DEFAULT ("yes" being less verbose, "no" or
# empty being verbose).
AC_DEFUN([AM_SILENT_RULES],
[AC_REQUIRE([_AM_SILENT_RULES])
AM_DEFAULT_VERBOSITY=m4_if([$1], [yes], [0], [1])m4_newline
dnl We intentionally force a newline after the assignment, since a) nothing
dnl good can come of more text following, and b) that was the behavior
dnl before 1.17. See https://bugs.gnu.org/72267.
])

# Copyright (C) 2001-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_PROG_INSTALL_STRIP
# ---------------------
# One issue with vendor 'install' (even GNU) is that you can't
# specify the program used to strip binaries.  This is especially
# annoying in cross-compiling environments, where the build's strip
# is unlikely to handle the host's binaries.
# Fortunately install-sh will honor a STRIPPROG variable, so we
# always use install-sh in "make install-strip", and initialize
# STRIPPROG with the value of the STRIP variable (set by the user).
AC_DEFUN([AM_PROG_INSTALL_STRIP],
[AC_REQUIRE([AM_PROG_INSTALL_SH])dnl
# Installed binaries are usually stripped using 'strip' when the user
# run "make install-strip".  However 'strip' might not be the right
# tool to use in cross-compilation environments, therefore Automake
# will honor the 'STRIP' environment variable to overrule this program.
dnl Don't test for $cross_compiling = yes, because it might be 'maybe'.
if test "$cross_compiling" != no; then
  AC_CHECK_TOOL([STRIP], [strip], :)
fi
INSTALL_STRIP_PROGRAM="\$(install_sh) -c -s"
AC_SUBST([INSTALL_STRIP_PROGRAM])])

# Copyright (C) 2006-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_SUBST_NOTMAKE(VARIABLE)
# ---------------------------
# Prevent Automake from outputting VARIABLE = @VARIABLE@ in Makefile.in.
# This macro is traced by Automake.
AC_DEFUN([_AM_SUBST_NOTMAKE])

# AM_SUBST_NOTMAKE(VARIABLE)
# --------------------------
# Public sister of _AM_SUBST_NOTMAKE.
AC_DEFUN([AM_SUBST_NOTMAKE], [_AM_SUBST_NOTMAKE($@)])

# Check how to create a tarball.                            -*- Autoconf -*-

# Copyright (C) 2004-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_PROG_TAR(FORMAT)
# --------------------
# Check how to create a tarball in format FORMAT.
# FORMAT should be one of 'v7', 'ustar', or 'pax'.
#
# Substitute a variable $(am__tar) that is a command
# writing to stdout a FORMAT-tarball containing the directory
# $tardir.
#     tardir=directory && $(am__tar) > result.tar
#
# Substitute a variable $(am__untar) that extract such
# a tarball read from stdin.
#     $(am__untar) < result.tar
#
AC_DEFUN([_AM_PROG_TAR],
[# Always define AMTAR for backward compatibility.  Yes, it's still used
# in the wild :-(  We should find a proper way to deprecate it ...
AC_SUBST([AMTAR], ['$${TAR-tar}'])

# We'll loop over all known methods to create a tar archive until one works.
_am_tools='gnutar m4_if([$1], [ustar], [plaintar]) pax cpio none'

m4_if([$1], [v7],
  [am__tar='$${TAR-tar} chof - "$$tardir"' am__untar='$${TAR-tar} xf -'],

  [m4_case([$1],
    [ustar],
     [# The POSIX 1988 'ustar' format is defined with fixed-size fields.
      # There is notably a 21 bits limit for the UID and the GID.  In fact,
      # the 'pax' utility can hang on bigger UID/GID (see automake bug#8343
      # and bug#13588).
      am_max_uid=2097151 # 2^21 - 1
      am_max_gid=$am_max_uid
      # The $UID and $GID variables are not portable, so we need to resort
      # to the POSIX-mandated id(1) utility.  Errors in the 'id' calls
      # below are definitely unexpected, so allow the users to see them
      # (that is, avoid stderr redirection).
      am_uid=`id -u || echo unknown`
      am_gid=`id -g || echo unknown`
      AC_MSG_CHECKING([whether UID '$am_uid' is supported by ustar format])
      if test x$am_uid = xunknown; then
        AC_MSG_WARN([ancient id detected; assuming current UID is ok, but dist-ustar might not work])
      elif test $am_uid -le $am_max_uid; then
        AC_MSG_RESULT([yes])
      else
        AC_MSG_RESULT([no])
        _am_tools=none
      fi
      AC_MSG_CHECKING([whether GID '$am_gid' is supported by ustar format])
      if test x$gm_gid = xunknown; then
        AC_MSG_WARN([ancient id detected; assuming current GID is ok, but dist-ustar might not work])
      elif test $am_gid -le $am_max_gid; then
        AC_MSG_RESULT([yes])
      else
        AC_MSG_RESULT([no])
        _am_tools=none
      fi],

  [pax],
    [],

  [m4_fatal([Unknown tar format])])

  AC_MSG_CHECKING([how to create a $1 tar archive])

  # Go ahead even if we have the value already cached.  We do so because we
  # need to set the values for the 'am__tar' and 'am__untar' variables.
  _am_tools=${am_cv_prog_tar_$1-$_am_tools}

  for _am_tool in $_am_tools; do
    case $_am_tool in
    gnutar)
      for _am_tar in tar gnutar gtar; do
        AM_RUN_LOG([$_am_tar --version]) && break
      done
      am__tar="$_am_tar --format=m4_if([$1], [pax], [posix], [$1]) -chf - "'"$$tardir"'
      am__tar_="$_am_tar --format=m4_if([$1], [pax], [posix], [$1]) -chf - "'"$tardir"'
      am__untar="$_am_tar -xf -"
      ;;
    plaintar)
      # Must skip GNU tar: if it does not support --format= it doesn't create
      # ustar tarball either.
      (tar --version) >/dev/null 2>&1 && continue
      am__tar='tar chf - "$$tardir"'
      am__tar_='tar chf - "$tardir"'
      am__untar='tar xf -'
      ;;
    pax)
      am__tar='pax -L -x $1 -w "$$tardir"'
      am__tar_='pax -L -x $1 -w "$tardir"'
      am__untar='pax -r'
      ;;
    cpio)
      am__tar='find "$$tardir" -print | cpio -o -H $1 -L'
      am__tar_='find "$tardir" -print | cpio -o -H $1 -L'
      am__untar='cpio -i -H $1 -d'
      ;;
    none)
      am__tar=false
      am__tar_=false
      am__untar=false
      ;;
    esac

    # If the value was cached, stop now.  We just wanted to have am__tar
    # and am__untar set.
    test -n "${am_cv_prog_tar_$1}" && break

    # tar/untar a dummy directory, and stop if the command works.
    rm -rf conftest.dir
    mkdir conftest.dir
    echo GrepMe > conftest.dir/file
    AM_RUN_LOG([tardir=conftest.dir && eval $am__tar_ >conftest.tar])
    rm -rf conftest.dir
    if test -s conftest.tar; then
      AM_RUN_LOG([$am__untar <conftest.tar])
      AM_RUN_LOG([cat conftest.dir/file])
      grep GrepMe conftest.dir/file >/dev/null 2>&1 && break
    fi
  done
  rm -rf conftest.dir

  AC_CACHE_VAL([am_cv_prog_tar_$1], [am_cv_prog_tar_$1=$_am_tool])
  AC_MSG_RESULT([$am_cv_prog_tar_$1])])

AC_SUBST([am__tar])
AC_SUBST([am__untar])
]) # _AM_PROG_TAR

# Copyright (C) 2022-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_PROG_XARGS_N
# ----------------
# Check whether 'xargs -n' works.  It should work everywhere, so the fallback
# is not optimized at all as we never expect to use it.
AC_DEFUN([_AM_PROG_XARGS_N],
[AC_CACHE_CHECK([xargs -n works], am_cv_xargs_n_works, [dnl
AS_IF([test "`echo 1 2 3 | xargs -n2 echo`" = "1 2
3"], [am_cv_xargs_n_works=yes], [am_cv_xargs_n_works=no])])
AS_IF([test "$am_cv_xargs_n_works" = yes], [am__xargs_n='xargs -n'], [dnl
  am__xargs_n='am__xargs_n () { shift; sed "s/ /\\n/g" | while read am__xargs_n_arg; do "$@" "$am__xargs_n_arg"; done; }'
])dnl
AC_SUBST(am__xargs_n)
])

m4_include([build-aux/m4/libtool.m4])
m4_include([build-aux/m4/ltoptions.m4])
m4_include([build-aux/m4/ltsugar.m4])
m4_include([build-aux/m4/ltversion.m4])
m4_include([build-aux/m4/lt~obsolete.m4])
