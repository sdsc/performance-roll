PACKAGE     = papi
CATEGORY    = applications

NAME        = sdsc-$(PACKAGE)-modules
RELEASE     = 5
PKGROOT     = /opt/modulefiles/$(CATEGORY)/$(PACKAGE)

VERSION_SRC = $(REDHAT.ROOT)/src/$(PACKAGE)/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No\nAutoProv:No\nObsoletes:sdsc-papi-modules_gnu,sdsc-papi-modules_intel,sdsc-papi-modules_pgi
RPM.PREFIX  = $(PKGROOT)
