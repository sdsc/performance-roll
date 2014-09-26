NAME        = pdt-modules_$(ROLLCOMPILER)
RELEASE     = 1
PKGROOT     = /opt/modulefiles/applications/.$(ROLLCOMPILER)/pdt

VERSION_SRC = $(REDHAT.ROOT)/src/pdt/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

RPM.EXTRAS  = AutoReq:No
