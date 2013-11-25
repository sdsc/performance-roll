NAME               = papi_$(ROLLCOMPILER)
VERSION            = 5.0.1
RELEASE            = 0
PKGROOT            = /opt/papi/$(ROLLCOMPILER)

SRC_SUBDIR         = papi

SOURCE_NAME        = papi
SOURCE_VERSION     = $(VERSION)
SOURCE_SUFFIX      = tar.gz
SOURCE_PKG         = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR         = $(SOURCE_PKG:%.$(SOURCE_SUFFIX)=%)

TAR_GZ_PKGS        = $(SOURCE_PKG)
