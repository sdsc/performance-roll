NAME        = papi-modules_$(ROLLCOMPILER)
RELEASE     = 1
PKGROOT     = /opt/modulefiles/applications/.$(ROLLCOMPILER)/papi

VERSION_SRC = $(REDHAT.ROOT)/src/papi/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No
