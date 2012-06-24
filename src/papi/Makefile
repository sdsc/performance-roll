#
# $Id$
#
# @Copyright@
#
# 				Rocks(tm)
# 		         www.rocksclusters.org
# 		        version 4.3 (Mars Hill)
#
# Copyright (c) 2000 - 2011 The Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice unmodified and in its entirety, this list of conditions and the
# following disclaimer in the documentation and/or other materials provided
# with the distribution.
#
# 3. All advertising and press materials, printed or electronic, mentioning
# features or use of this software must display the following acknowledgement:
#
# 	"This product includes software developed by the Rocks(tm)
# 	Cluster Group at the San Diego Supercomputer Center at the
# 	University of California, San Diego and its contributors."
#
# 4. Except as permitted for the purposes of acknowledgment in paragraph 3,
# neither the name or logo of this software nor the names of its
# authors may be used to endorse or promote products derived from this
# software without specific prior written permission.  The name of the
# software includes the following terms, and any derivatives thereof:
# "Rocks", "Rocks Clusters", and "Avalanche Installer".  For licensing of
# the associated name, interested parties should contact Technology
# Transfer & Intellectual Property Services, University of California,
# San Diego, 9500 Gilman Drive, Mail Code 0910, La Jolla, CA 92093-0910,
# Ph: (858) 534-5815, FAX: (858) 534-7345, E-MAIL:invent@ucsd.edu
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS''
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# @Copyright@

ifndef ROLLCOMPILER
  ROLLCOMPILER = gnu
endif

PKGROOT = /opt/papi/$(ROLLCOMPILER)
SOURCE = papi-$(VERSION)
REDHAT.ROOT = $(PWD)/../../

RPM.EXTRAS=%define __os_install_post /usr/lib/rpm/brp-compress

-include $(ROCKSROOT)/etc/Rules.mk

COMPILERSETUP = \
  if test -e /etc/profile.d/modules.sh; then \
    . /etc/profile.d/modules.sh; \
    module load $(ROLLCOMPILER); \
  fi

CCOMP = gcc
FCOMP = g77
CONFIGURE_FLAGS =
ifeq ("$(ROLLCOMPILER)", "intel")
  CCOMP = icc
  FCOMP = ifort
  CONFIGURE_FLAGS = -gcc
else ifeq ("$(ROLLCOMPILER)", "pgi")
  CCOMP = pgcc
  FCOMP = pgf77
  CONFIGURE_FLAGS = -noswitcherror
endif

build:
	tar zxvf $(SOURCE).tar.gz
	cp patch-files/pfmlib_common.c $(SOURCE)/src/libpfm4/lib

install::
	mkdir -p $(PKGROOT)
	mkdir -p $(ROOT)/$(PKGROOT)
	mkdir -p $(REDHAT.ROOT)/src/build-papi-$(ROLLCOMPILER)
	( \
	  $(COMPILERSETUP); \
	  export CC=$(CCOMP); \
	  export CFLAGS=$${CONfIGURE_FLAGS}; \
	  export F77=$(FCOMP); \
	  export FFLAGS=""; \
          echo $${CC}; \
	  mount --bind $(REDHAT.ROOT)/src/build-papi-$(ROLLCOMPILER)  $(PKGROOT); \
	  cd $(SOURCE)/src; \
          ./configure --prefix=$(PKGROOT) --with-libpfm4; \
	  make; \
	  make install; \
          umount $(PKGROOT); \
          cp -r $(REDHAT.ROOT)/src/build-papi-$(ROLLCOMPILER)/* $(ROOT)/$(PKGROOT) \
	)

clean::
	rm -rf $(SOURCE)