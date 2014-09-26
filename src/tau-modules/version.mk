NAME        = tau-modules_$(ROLLCOMPILER)
RELEASE     = 1
PKGROOT     = /opt/modulefiles/applications/.$(ROLLCOMPILER)/tau

VERSION_SRC = $(REDHAT.ROOT)/src/tau/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No
