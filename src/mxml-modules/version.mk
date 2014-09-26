NAME        = mxml-modules_$(ROLLCOMPILER)
RELEASE     = 1
PKGROOT     = /opt/modulefiles/applications/.$(ROLLCOMPILER)/mxml

VERSION_SRC = $(REDHAT.ROOT)/src/mxml/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No
