NAME               = tau_$(ROLLCOMPILER)_$(ROLLMPI)_$(ROLLNETWORK)
VERSION            = 2.23
RELEASE            = 0
RPM.EXTRAS         = AutoReq:No
PKGROOT            = /opt/tau/$(ROLLCOMPILER)/$(ROLLMPI)

SRC_SUBDIR         = tau

SOURCE_NAME        = tau
SOURCE_VERSION     = $(VERSION)
SOURCE_SUFFIX      = tgz
SOURCE_PKG         = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR         = $(SOURCE_PKG:%.$(SOURCE_SUFFIX)=%)

TGZ_PKGS           = $(SOURCE_PKG)
