NAME               = mxml_$(ROLLCOMPILER)
VERSION            = 2.7
RELEASE            = 0
PKGROOT            = /opt/mxml/$(ROLLCOMPILER)
RPM.EXTRAS         = AutoReq:No

SRC_SUBDIR         = mxml

SOURCE_NAME        = mxml
SOURCE_VERSION     = $(VERSION)
SOURCE_SUFFIX      = tar.gz
SOURCE_PKG         = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR         = $(SOURCE_PKG:%.$(SOURCE_SUFFIX)=%)

TAR_GZ_PKGS        = $(SOURCE_PKG)
