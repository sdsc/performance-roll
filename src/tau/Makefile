# $Id$
#
# @Copyright@
# 
# 				Rocks(r)
# 		         www.rocksclusters.org
# 		         version 5.6 (Emerald Boa)
# 		         version 6.1 (Emerald Boa)
# 
# Copyright (c) 2000 - 2013 The Regents of the University of California.
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
# 	"This product includes software developed by the Rocks(r)
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
#
# $Log$

REDHAT.ROOT = $(CURDIR)/../../

RPM.EXTRAS=%define __os_install_post /usr/lib/rpm/brp-compress

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk
include $(SDSCDEVEL)/Pull.mk
include $(SDSCDEVEL)/Rules.mk

FORTRAN = gfortran
ifeq ("$(COMPILERNAME)", "intel")
  FORTRAN = intel
else ifeq ("$(COMPILERNAME)", "pgi")
  FORTRAN = pgi
endif

PAPI_CACHE = $(REDHAT.ROOT)/cache/build-papi-$(COMPILERNAME)
PAPI_INSTALL = /opt/papi/$(COMPILERNAME)
PDT_CACHE = $(REDHAT.ROOT)/cache/build-pdt-$(COMPILERNAME)
PDT_INSTALL = /opt/pdt/$(COMPILERNAME)

DESCRIPTION:
	$(MODULE_LOAD_CC); \
	( \
	  $(DESCRIBE_PKG); \
	  $(DESCRIBE_CC); \
	  $(DESCRIBE_MPI) \
	) > $@

LICENSE: $(SRC_DIRS)
	$(CHECK_LICENSE_FILES)
	echo University of Oregon > $@

build: $(SRC_DIRS)
	( \
	   $(MODULE_LOAD_CC); \
           cd $(BINUTILS_SOURCE_DIR); \
	   ./configure CFLAGS=-fPIC CXXFLAGS=-fPIC --prefix=$(BINUTILS_SOURCE) --disable-nls --disable-werror; \
           make; \
           make install \
        )
	@echo "::: Package $(NAME) build complete :::"

install::
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	# Using a bind mount appears to be the only way to prevent the build
	# from incorporating $(ROOT) in binary files.  Furthermore, the build
	# embeds paths to papi and pdt in the tau libs, so we need to bind
	# mount those.
	$(PKGROOT_BIND_MOUNT)
	$(call BIND_MOUNT, $(PAPI_INSTALL), $(PAPI_CACHE))
	$(call BIND_MOUNT, $(PDT_INSTALL), $(PDT_CACHE))
	( \
	  $(MODULE_LOAD_CC); \
	  $(MODULE_LOAD_MPI); \
	  cd $(SOURCE_DIR); \
	  ./installtau -prefix=$(PKGROOT) -cc=$(CC) -c++=$(CXX) \
	               -fortran=$(FORTRAN) -mpi -mpiinc=$${MPIHOME}/include \
	               -mpilib=$${MPIHOME}/lib -papi=$(PAPI_INSTALL) \
	               -pdt=$(PDT_INSTALL) -bfd=$(BINUTILS_SOURCE) \
	)
	$(PKGROOT_BIND_UMOUNT)
	$(call BIND_UMOUNT, $(PAPI_INSTALL))
	$(call BIND_UMOUNT, $(PDT_INSTALL))
	$(INSTALL_LICENSE_FILES)
	@echo "::: Package $(NAME) install complete :::"

clean::
	rm -rf $(SOURCE_DIR) $(BINUTILS_SOURCE_DIR) DESCRIPTION LICENSE
