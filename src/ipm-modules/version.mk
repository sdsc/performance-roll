PACKAGE     = ipm
CATEGORY    = applications

NAME        = sdsc-$(PACKAGE)-modules
RELEASE     = 7
PKGROOT     = /opt/modulefiles/$(CATEGORY)/$(PACKAGE)

VERSION_SRC = $(REDHAT.ROOT)/src/$(PACKAGE)/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No\nAutoProv:No\nObsoletes:sdsc-ipm-modules_gnu,sdsc-ipm-modules_intel,sdsc-ipm-modules_pgi
RPM.PREFIX  = $(PKGROOT)
