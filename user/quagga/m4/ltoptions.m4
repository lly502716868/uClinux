# Helper functions for option handling.                    -*- Autoconf -*-
# Written by Gary V. Vaughan <gary@gnu.org>

# Copyright (C) 2004  Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# serial 1

# This is to help aclocal find these macros, as it can't see m4_define.
AC_DEFUN([LTOPTIONS_VERSION], [m4_if([1])])


# _LT_MANGLE_OPTION(NAME)
# -----------------------
m4_define([_LT_MANGLE_OPTION],
[[_LT_OPTION_]m4_bpatsubst($1, [[^a-zA-Z0-9_]], [_])])


# _LT_SET_OPTION(NAME)
# ------------------------------
# Set option NAME.  Other NAMEs are saved as a flag.
m4_define([_LT_SET_OPTION], [m4_define(_LT_MANGLE_OPTION([$1]))])


# _LT_IF_OPTION(OPTION, IF-SET, [IF-NOT-SET])
# -------------------------------------------
# Execute IF-SET if OPTION is set, IF-NOT-SET otherwise.
m4_define([_LT_IF_OPTION],
[m4_ifdef(_LT_MANGLE_OPTION([$1]), [$2], [$3])])


# _LT_UNLESS_OPTIONS(OPTIONS, IF-NOT-SET)
# ---------------------------------------
# Execute IF-NOT-SET if all OPTIONS are not set.
m4_define([_LT_UNLESS_OPTIONS],
[AC_FOREACH([_LT_Option], [$1],
	    [m4_ifdef(_LT_MANGLE_OPTION(_LT_Option),
		      [m4_define([$0_found])])])[]dnl
m4_ifdef([$0_found], [m4_undefine([$0_found])], [$2
])[]dnl
])


# _LT_SET_OPTIONS(OPTIONS)
# ------------------------
# OPTIONS is a space-separated list of Automake options.
# If any OPTION has a handler macro declared with LT_OPTION_DEFINE,
# despatch to that macro; otherwise complain about the unknown option
# and exit.
m4_define([_LT_SET_OPTIONS],
[AC_FOREACH([_LT_Option], [$1],
    [_LT_SET_OPTION(_LT_Option)
    m4_ifdef(_LT_MANGLE_DEFUN(_LT_Option),
		_LT_MANGLE_DEFUN(_LT_Option),
	[m4_fatal([Unknown option `]_LT_Option[' to LT][_INIT_LIBTOOL])])
    ])dnl
dnl
dnl Simply set some default values (i.e off) if boolean options were not
dnl specified:
_LT_UNLESS_OPTIONS([dlopen], enable_dlopen=no)
_LT_UNLESS_OPTIONS([win32-dll], enable_win32_dll=no)
dnl
dnl If no reference was made to various pairs of opposing options, then
dnl we run the default mode handler for the pair.  For example, if neither
dnl `shared' nor `disable-shared' was passed, we enable building of shared
dnl archives by default:
_LT_UNLESS_OPTIONS([shared disable-shared], [_LT_ENABLE_SHARED])
_LT_UNLESS_OPTIONS([static disable-static], [_LT_ENABLE_STATIC])
_LT_UNLESS_OPTIONS([pic-only no-pic], [_LT_WITH_PIC])
_LT_UNLESS_OPTIONS([fast-install disable-fast-install],
		   [_LT_ENABLE_FAST_INSTALL])
])# _LT_SET_OPTIONS


## ----------------------------------------- ##
## Macros to handle LT_INIT_LIBTOOL options. ##
## ----------------------------------------- ##

m4_define([_LT_MANGLE_DEFUN],
[[_LT_OPTION_DEFUN_]m4_bpatsubst(m4_toupper([$1]), [[^A-Z0-9_]], [_])])


# LT_OPTION_DEFINE(NAME, CODE)
# ----------------------------
m4_define([LT_OPTION_DEFINE],
[m4_define(_LT_MANGLE_DEFUN([$1]), [$2])[]dnl
])# LT_OPTION_DEFINE


# dlopen
# ------
LT_OPTION_DEFINE([dlopen], [enable_dlopen=yes])

AU_DEFUN([AC_LIBTOOL_DLOPEN],
[_LT_SET_OPTION([dlopen])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you
put the `dlopen' option into LT_LIBTOOL_INIT's first parameter.])
])


# win32-dll
# ---------
# Declare package support for building win32 dll's.
LT_OPTION_DEFINE([win32-dll],
[enable_win32_dll=yes

case $host in
*-*-cygwin* | *-*-mingw* | *-*-pw32*)
  AC_CHECK_TOOL(AS, as, false)
  AC_CHECK_TOOL(DLLTOOL, dlltool, false)
  AC_CHECK_TOOL(OBJDUMP, objdump, false)
  ;;
esac

test -z "$AS" && AS=as
_LT_DECL([], [AS],      [0], [Assembler program])dnl

test -z "$DLLTOOL" && DLLTOOL=dlltool
_LT_DECL([], [DLLTOOL], [0], [DLL creation program])dnl

test -z "$OBJDUMP" && OBJDUMP=objdump
_LT_DECL([], [OBJDUMP], [0], [Object dumper program])dnl
])# win32-dll

AU_DEFUN([AC_LIBTOOL_WIN32_DLL],
[_LT_SET_OPTION([win32-dll])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you
put the `win32-dll' option into LT_LIBTOOL_INIT's first parameter.])
])


# _LT_ENABLE_SHARED([DEFAULT])
# ----------------------------
# implement the --enable-shared flag, and supports the `shared' and
# `disable-shared' LT_INIT_LIBTOOL options.
# DEFAULT is either `yes' or `no'.  If omitted, it defaults to `yes'.
m4_define([_LT_ENABLE_SHARED],
[m4_define([_LT_ENABLE_SHARED_DEFAULT], [m4_if($1, no, no, yes)])dnl
AC_ARG_ENABLE([shared],
    [AC_HELP_STRING([--enable-shared@<:@=PKGS@:>@],
	[build shared libraries @<:@default=]_LT_ENABLE_SHARED_DEFAULT[@:>@])],
    [p=${PACKAGE-default}
    case $enableval in
    yes) enable_shared=yes ;;
    no) enable_shared=no ;;
    *)
      enable_shared=no
      # Look at the argument we got.  We use all the common list separators.
      lt_save_ifs="$IFS"; IFS="${IFS}$PATH_SEPARATOR,"
      for pkg in $enableval; do
	IFS="$lt_save_ifs"
	if test "X$pkg" = "X$p"; then
	  enable_shared=yes
	fi
      done
      IFS="$lt_save_ifs"
      ;;
    esac],
    [enable_shared=]_LT_ENABLE_SHARED_DEFAULT)

    _LT_DECL([build_libtool_libs], [enable_shared], [0],
	[Whether or not to build shared libraries])
])# _LT_ENABLE_SHARED

LT_OPTION_DEFINE([shared], [_LT_ENABLE_SHARED([yes])])
LT_OPTION_DEFINE([disable-shared], [_LT_ENABLE_SHARED([no])])

# Old names:
AU_DEFUN([AC_ENABLE_SHARED],
[_LT_SET_OPTION([shared])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you
put the `shared' option into LT_LIBTOOL_INIT's first parameter.])
])

AU_DEFUN([AM_ENABLE_SHARED],
[_LT_SET_OPTION([shared])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you
put the `shared' option into LT_LIBTOOL_INIT's first parameter.])
])

AU_DEFUN([AC_DISABLE_SHARED],
[_LT_SET_OPTION([disable-shared])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you put
the `disable-shared' option into LT_LIBTOOL_INIT's first parameter.])
])

AU_DEFUN([AM_DISABLE_SHARED],
[_LT_SET_OPTION([disable-shared])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you put
the `disable-shared' option into LT_LIBTOOL_INIT's first parameter.])
])


# _LT_ENABLE_STATIC([DEFAULT])
# ----------------------------
# implement the --enable-static flag, and support the `static' and
# `disable-static' LT_INIT_LIBTOOL options.
# DEFAULT is either `yes' or `no'.  If omitted, it defaults to `yes'.
m4_define([_LT_ENABLE_STATIC],
[m4_define([_LT_ENABLE_STATIC_DEFAULT], [m4_if($1, no, no, yes)])dnl
AC_ARG_ENABLE([static],
    [AC_HELP_STRING([--enable-static@<:@=PKGS@:>@],
	[build static libraries @<:@default=]_LT_ENABLE_STATIC_DEFAULT[@:>@])],
    [p=${PACKAGE-default}
    case $enableval in
    yes) enable_static=yes ;;
    no) enable_static=no ;;
    *)
     enable_static=no
      # Look at the argument we got.  We use all the common list separators.
      lt_save_ifs="$IFS"; IFS="${IFS}$PATH_SEPARATOR,"
      for pkg in $enableval; do
	IFS="$lt_save_ifs"
	if test "X$pkg" = "X$p"; then
	  enable_static=yes
	fi
      done
      IFS="$lt_save_ifs"
      ;;
    esac],
    [enable_static=]_LT_ENABLE_STATIC_DEFAULT)

    _LT_DECL([build_old_libs], [enable_static], [0],
	[Whether or not to build static libraries])
])# _LT_ENABLE_STATIC

LT_OPTION_DEFINE([static], [_LT_ENABLE_STATIC([yes])])
LT_OPTION_DEFINE([disable-static], [_LT_ENABLE_STATIC([no])])

# Old names:
AU_DEFUN([AC_ENABLE_STATIC],
[_LT_SET_OPTION([static])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you
put the `static' option into LT_LIBTOOL_INIT's first parameter.])
])

AU_DEFUN([AM_ENABLE_STATIC],
[_LT_SET_OPTION([static])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you
put the `static' option into LT_LIBTOOL_INIT's first parameter.])
])

AU_DEFUN([AC_DISABLE_STATIC],
[_LT_SET_OPTION([disable-static])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you put
the `disable-static' option into LT_LIBTOOL_INIT's first parameter.])
])

AU_DEFUN([AM_DISABLE_STATIC],
[_LT_SET_OPTION([disable-static])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you put
the `disable-static' option into LT_LIBTOOL_INIT's first parameter.])
])


# _LT_ENABLE_FAST_INSTALL([DEFAULT])
# ----------------------------------
# implement the --enable-fast-install flag, and support the `fast-install'
# and `disable-fast-install' LT_INIT_LIBTOOL options.
# DEFAULT is either `yes' or `no'.  If omitted, it defaults to `yes'.
m4_define([_LT_ENABLE_FAST_INSTALL],
[m4_define([_LT_ENABLE_FAST_INSTALL_DEFAULT], [m4_if($1, no, no, yes)])dnl
AC_ARG_ENABLE([fast-install],
    [AC_HELP_STRING([--enable-fast-install@<:@=PKGS@:>@],
    [optimize for fast installation @<:@default=]_LT_ENABLE_FAST_INSTALL_DEFAULT[@:>@])],
    [p=${PACKAGE-default}
    case $enableval in
    yes) enable_fast_install=yes ;;
    no) enable_fast_install=no ;;
    *)
      enable_fast_install=no
      # Look at the argument we got.  We use all the common list separators.
      lt_save_ifs="$IFS"; IFS="${IFS}$PATH_SEPARATOR,"
      for pkg in $enableval; do
	IFS="$lt_save_ifs"
	if test "X$pkg" = "X$p"; then
	  enable_fast_install=yes
	fi
      done
      IFS="$lt_save_ifs"
      ;;
    esac],
    [enable_fast_install=]_LT_ENABLE_FAST_INSTALL_DEFAULT)

_LT_DECL([fast_install], [enable_fast_install], [0],
	 [Whether or not to optimize for fast installation])dnl
])# _LT_ENABLE_FAST_INSTALL

LT_OPTION_DEFINE([fast-install], [_LT_ENABLE_FAST_INSTALL([yes])])
LT_OPTION_DEFINE([disable-fast-install], [_LT_ENABLE_FAST_INSTALL([no])])

# Old names:
AU_DEFUN([AC_ENABLE_FAST_INSTALL],
[_LT_SET_OPTION([fast-install])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you put
the `fast-install' option into LT_LIBTOOL_INIT's first parameter.])
])

AU_DEFUN([AC_DISABLE_FAST_INSTALL],
[_LT_SET_OPTION([disable-fast-install])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you put
the `disable-fast-install' option into LT_LIBTOOL_INIT's first parameter.])
])


# _LT_WITH_PIC([MODE])
# --------------------
# implement the --with-pic flag, and support the `pic-only' and `no-pic'
# LT_INIT_LIBTOOL options.
# MODE is either `yes' or `no'.  If omitted, it defaults to `both'.
m4_define([_LT_WITH_PIC],
[AC_ARG_WITH([pic],
    [AC_HELP_STRING([--with-pic],
	[try to use only PIC/non-PIC objects @<:@default=use both@:>@])],
    [pic_mode="$withval"],
    [pic_mode=default])

test -z "$pic_mode" && pic_mode=m4_if($#, 1, $1, default)

_LT_DECL([], [pic_mode], [0], [What type of objects to build])dnl
])# _LT_WITH_PIC

LT_OPTION_DEFINE([pic-only], [_LT_WITH_PIC([yes])])
LT_OPTION_DEFINE([no-pic], [_LT_WITH_PIC([no])])

# Old name:
AU_DEFUN([AC_LIBTOOL_PIC_MODE],
[_LT_SET_OPTION([pic-only])
AC_DIAGNOSE([obsolete],
[$0: Remove this warning and the call to _LT_SET_OPTION when you
put the `pic-only' option into LT_LIBTOOL_INIT's first parameter.])
])
