PACKAGE     = mxml
CATEGORY    = applications

NAME        = sdsc-$(PACKAGE)-modules
RELEASE     = 4
PKGROOT     = /opt/modulefiles/$(CATEGORY)/$(PACKAGE)

VERSION_SRC = $(REDHAT.ROOT)/src/$(PACKAGE)/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No\nObsoletes:sdsc-mxml-modules_gnu,sdsc-mxml-modules_intel,sdsc-mxml-modules_pgi
