NAME        = ipm-modules_$(ROLLCOMPILER)
RELEASE     = 1
PKGROOT     = /opt/modulefiles/applications/.$(ROLLCOMPILER)/ipm

VERSION_SRC = $(REDHAT.ROOT)/src/ipm/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No
