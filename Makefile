################################################################################
#
# Makefile
#
# Sean<SeanInApril@163.com>
#
# build arm-elf toolchain classic version 3.2.1 in mordern ubuntu envirments
#
################################################################################
# envirment:
#    Ubuntu 16.04
#
# relative packages
#    autoconfig automake libtool texinfo gperf
#
# default combination packages(v3.2.1):
#    (can be downloaded from ftp://sources.redhat.com/pub/)
#    binutils-2.13.1.tar.gz
#    gcc-core-3.2.1.tar.gz
#    gcc-g++-3.2.1.tar.gz
#    gdb-8.1.tar.gz
#    newlib-1.11.0.tar.gz
#
# patch:
#    (made by Sean)
#    binutils-2.13.1-arm-elf.patch
#    gcc-3.2.1-arm-elf.patch
#
# build steps
#    make (all)		//default
#
#    make download	//download packages
#    make pre(pare)	//prepare
#    make com(pile)	//build
#    make pack		//tarball
#    make ins(tall)	//install
#    make tst		//test toolchain
#    make clean
#    make clean_package //clean download packages
#    make clean_target  //clean install directory
#    make clean_tst	    //clean test
#    make clean_all	    //clean clean_package clean_target clean_tst
################################################################################
# tested _GCC_VER_:
#
#    3.2.1(default)
#    3.4.6 as well
################################################################################

#config here
#------------------------8<----------------------------
_GCC_VER_ := 3.2.1
#_PATH_   := $(HOME)/gnutools
_PATH_    :=
#absolute path only
#------------------------8<----------------------------

ifeq ($(_GCC_VER_), 3.2.1)
#version 3.2.1
BINUTILS_VERSION := 2.13.1
NEWLIB_VERSION   := 1.11.0
GCC_VERSION      := 3.2.1
GDB_VERSION      := 8.1
else
#version 3.4.6
BINUTILS_VERSION := 2.30
NEWLIB_VERSION   := 1.13.0
GCC_VERSION      := 3.4.6
GDB_VERSION      := 8.1
endif

#supported combinations currently
#1. binutils-2.13.1/gcc-3.2.1/gdb-8.1/newlib-1.11.0
#2. binutils-2.30/gcc-3.4.6/gdb-8.1/newlib-1.13.0
#patch of gcc just because of the new ubuntu envirments

ifeq ($(_PATH_),)
_PREFIX_ := $$(pwd)/gnutools
else
_PREFIX_ := $(_PATH_)
endif

#global config
TARGET := arm-elf
PREFIX := $(_PREFIX_)/$(TARGET)-$(GCC_VERSION)

#SW_DL_URL := ftp://sources.redhat.com/pub
SW_DL_URL := ftp://sourceware.org/pub
DLFLAGS   := -c --tries=0 --timeout=10

SW_DL_URL_NEW := https://mirrors.tuna.tsinghua.edu.cn/gnu

#function to check wheather file exsits in path
#return empty, if doesn't exist
#$(1) - name
#$(2) - path
#$(call FILE_DIR_EXIST,name,path)
FILE_DIR_EXIST=$(filter %$(1), $(shell echo $(2)/*))

ifeq ($(_PREFIX_INN_),)
#for the top dir
export PATH+=:$(PREFIX)/bin
else
#for the make -C
export PATH+=:$(_PREFIX_INN_)/bin
endif


.PHONY: all clean

all: download prepare compile pack
#	make download
#	make prepare
#	make compile
#	make pack
	@echo "all end"

################################################################################
# PART 0: usage of this script                                                 #
################################################################################
useage: help

help:
	@echo '---------------arm-elf-toolchain builder v0.2------------------'
	@echo 'make (all)         - default'
	@echo ''
	@echo 'make download      - download packages'
	@echo 'make pre(pare)     - prepare'
	@echo 'make com(pile)     - build'
	@echo 'make ins(tall)     - install'
	@echo 'make tst           - test toolchain'
	@echo 'make clean'
	@echo 'make clean_package - clean download packages'
	@echo 'make clean_target  - clean install directory'
	@echo 'make clean_tst     - clean test'
	@echo 'make clean_all     - clean clean_package clean_target clean_tst'
	@echo 'make help          - usage of this script'

################################################################################
# PART I: download packages                                                    #
################################################################################
dl: download

download:
	mkdir -pv pkg
#	wget $(DLFLAGS) -O pkg/binutils-$(BINUTILS_VERSION).tar.gz $(SW_DL_URL)/binutils/releases/binutils-$(BINUTILS_VERSION).tar.gz
#	wget $(DLFLAGS) -O pkg/gcc-core-$(GCC_VERSION).tar.gz      $(SW_DL_URL)/gcc/releases/gcc-$(GCC_VERSION)/gcc-core-$(GCC_VERSION).tar.gz
#	wget $(DLFLAGS) -O pkg/gcc-g++-$(GCC_VERSION).tar.gz       $(SW_DL_URL)/gcc/releases/gcc-$(GCC_VERSION)/gcc-g++-$(GCC_VERSION).tar.gz
#	wget $(DLFLAGS) -O pkg/gdb-$(GDB_VERSION).tar.gz           $(SW_DL_URL)/gdb/releases/gdb-$(GDB_VERSION).tar.gz
#	wget $(DLFLAGS) -O pkg/newlib-$(NEWLIB_VERSION).tar.gz     $(SW_DL_URL)/newlib/newlib-$(NEWLIB_VERSION).tar.gz

	wget $(DLFLAGS) -O pkg/binutils-$(BINUTILS_VERSION).tar.gz $(SW_DL_URL_NEW)/binutils/binutils-$(BINUTILS_VERSION).tar.gz
	wget $(DLFLAGS) -O pkg/gcc-core-$(GCC_VERSION).tar.gz      $(SW_DL_URL_NEW)/gcc/gcc-$(GCC_VERSION)/gcc-core-$(GCC_VERSION).tar.gz
	wget $(DLFLAGS) -O pkg/gcc-g++-$(GCC_VERSION).tar.gz       $(SW_DL_URL_NEW)/gcc/gcc-$(GCC_VERSION)/gcc-g++-$(GCC_VERSION).tar.gz
	wget $(DLFLAGS) -O pkg/gdb-$(GDB_VERSION).tar.gz           $(SW_DL_URL_NEW)/gdb/gdb-$(GDB_VERSION).tar.gz
	wget $(DLFLAGS) -O pkg/newlib-$(NEWLIB_VERSION).tar.gz     $(SW_DL_URL)/newlib/newlib-$(NEWLIB_VERSION).tar.gz

#gcc-3.2.1 arm only
ifeq ($(_GCC_VER_), 3.2.1)
	wget $(DLFLAGS) $(DLFLAGS) -O pkg/gcc-3.2.1-arm-multilib.patch        http://ecos.sourceware.org/gcc-3.2.1-arm-multilib.patch
endif

################################################################################
# PART II: prepare directory structure                                         #
################################################################################
pre: prepare

prepare:
	mkdir -pv src
	mkdir -pv bld/binutils bld/gcc bld/gdb

ifeq ($(call FILE_DIR_EXIST,binutils-$(BINUTILS_VERSION),src),)
	tar -zxvf pkg/binutils-$(BINUTILS_VERSION).tar.gz -C src
#gcc-3.2.1(binutils-2.13.1) only
ifeq ($(BINUTILS_VERSION), 2.13.1)
	patch -p0 <pkg/binutils-$(BINUTILS_VERSION)-$(TARGET).patch
endif
endif

ifeq ($(call FILE_DIR_EXIST,gcc-$(GCC_VERSION),src),)
	tar -zxvf pkg/gcc-core-$(GCC_VERSION).tar.gz      -C src
	tar -zxvf pkg/gcc-g++-$(GCC_VERSION).tar.gz       -C src
#gcc-3.2.1 arm only
ifeq ($(GCC_VERSION), 3.2.1)
	patch -d src -p0 <pkg/gcc-3.2.1-arm-multilib.patch
endif
	patch -p0 <pkg/gcc-$(GCC_VERSION)-$(TARGET).patch
endif

ifeq ($(call FILE_DIR_EXIST,gdb-$(GDB_VERSION),src),)
	tar -zxvf pkg/gdb-$(GDB_VERSION).tar.gz           -C src
endif

ifeq ($(call FILE_DIR_EXIST,newlib-$(NEWLIB_VERSION),src),)
	tar -zxvf pkg/newlib-$(NEWLIB_VERSION).tar.gz     -C src
	cp -rf src/newlib-$(NEWLIB_VERSION)/newlib src/newlib-$(NEWLIB_VERSION)/libgloss src/gcc-$(GCC_VERSION)
endif

	@echo "prepare end"

################################################################################
# PART III: compile binutils gcc gdb                                           #
################################################################################
com: compile

compile: bin gcc gdb
#	make bin
#	make gcc
#	make gdb
	@echo "compile end"

bin: binutils

binutils:
	make -C bld/binutils -f ../../Makefile binutils_inner _PREFIX_INN_=$(PREFIX)

gcc:
	make -C bld/gcc -f ../../Makefile gcc_inner _PREFIX_INN_=$(PREFIX)

gdb:
	make -C bld/gdb -f ../../Makefile gdb_inner _PREFIX_INN_=$(PREFIX)

binutils_inner:
	@echo "binutils"
ifeq ($(call FILE_DIR_EXIST,Makefile,./),)
	../../src/binutils-$(BINUTILS_VERSION)/configure --target=$(TARGET) --prefix=$(_PREFIX_INN_) -v 2>&1 |tee configure.out
endif
	make -w all install 2>&1 |tee make.out
	@echo "binutils end"

gcc_inner:
	@echo "gcc"
ifeq ($(call FILE_DIR_EXIST,Makefile,./),)
	../../src/gcc-$(GCC_VERSION)/configure --target=$(TARGET) --prefix=$(_PREFIX_INN_) --enable-languages=c,c++ --with-gnu-as --with-gnu-ld --with-newlib --with-gxx-include-dir=$(PREFIX)/$(TARGET)/include -v 2>&1 |tee configure.out
endif
	make -w all install 2>&1 |tee make.out
	@echo "gcc end"

gdb_inner:
	@echo "gdb"
ifeq ($(call FILE_DIR_EXIST,Makefile,./),)
	../../src/gdb-$(GDB_VERSION)/configure --target=$(TARGET) --prefix=$(_PREFIX_INN_) -v 2>&1 |tee configure.out
endif
	make -w all install 2>&1 |tee make.out
	@echo "gdb end"

################################################################################
# PART IV: install manully                                                     #
################################################################################
ins: install

install:
	make -C bld/binutils install
	make -C bld/gcc install
	make -C bld/gdb install

################################################################################
# PART V: test toolchain                                                       #
################################################################################
test-tool:
	make -C test _PREFIX_INN_=$(PREFIX)/bin/$(TARGET)-

################################################################################
# PART VI: make tarball                                                        #
################################################################################
pack:
	mkdir -pv target

	@echo "save versions"
	@echo "binutils-"${BINUTILS_VERSION} >  ${PREFIX}/versions.txt
	@echo "gcc-"${GCC_VERSION}           >> ${PREFIX}/versions.txt
	@echo "newlib-"${NEWLIB_VERSION}     >> ${PREFIX}/versions.txt
	@echo "gdb-"${GDB_VERSION}           >> ${PREFIX}/versions.txt

	tar -zcvf target/$(TARGET)-toolchain-$(GCC_VERSION)-$$(date +%Y%m%d%H%M%S).tar.gz -C $(_PREFIX_) $(TARGET)-$(GCC_VERSION)

################################################################################
# PART VII: clean up                                                           #
################################################################################
clean:
	rm -rf bld src $(PREFIX) *.out

clean_package:
	rm -rf pkg/*.tar.gz

clean_target:
	rm -rf $(PREFIX)

clean_tst:
	make -C test -r clean

clean_all:
	make clean
	make clean_package
	make clean_target
	make clean_tst
