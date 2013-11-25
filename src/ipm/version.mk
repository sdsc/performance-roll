NAME               = ipm_$(ROLLCOMPILER)_$(ROLLMPI)_$(ROLLNETWORK)
VERSION            = 2.0.0
RELEASE            = 11
PKGROOT            = /opt/ipm/$(ROLLCOMPILER)/$(ROLLMPI)

SRC_SUBDIR         = ipm

SOURCE_NAME        = ipm
SOURCE_VERSION     = $(VERSION)
SOURCE_SUFFIX      = tar.gz
SOURCE_PKG         = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR         = $(SOURCE_PKG:%.$(SOURCE_SUFFIX)=%)

TAR_GZ_PKGS        = $(SOURCE_PKG)

