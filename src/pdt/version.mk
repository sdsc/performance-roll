NAME               = pdt_$(ROLLCOMPILER)
VERSION            = 3.18.1
RELEASE            = 0
PKGROOT            = /opt/pdt/$(ROLLCOMPILER)

SRC_SUBDIR         = pdt

SOURCE_NAME        = pdtoolkit
SOURCE_VERSION     = $(VERSION)
SOURCE_SUFFIX      = tgz
SOURCE_PKG         = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR         = $(SOURCE_PKG:%.$(SOURCE_SUFFIX)=%)

TGZ_PKGS           = $(SOURCE_PKG)
