#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
include $(TOPDIR)/rules.mk

PKG_NAME:=rtl_fm_streamer
PKG_VERSION:=2.0.2
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=TheCosmicSlug <thecosmicslug@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

## Adjust this to point to local src
SOURCE_DIR:=./src

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtl_fm_streamer/Default
  TITLE:=FM Streaming with RTL-SDR based radios
  URL:=http://sdr.osmocom.org/trac/wiki/rtl-sdr
endef

define Package/rtl_fm_streamer/Default/description
  rtl_fm_streamer allows DVB-T dongles based on the Realtek RTL2832U to be used as
  an inexpensive FM Radio.
endef

define Package/rtl_fm_streamer
  $(call Package/rtl_fm_streamer/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+librt +libpthread +libev +libusb-1.0 +librtlsdr
endef

TARGET_CFLAGS += $(FPIC)
TARGET_CFLAGS += \
    -I$(STAGING_DIR)/usr/include/libev
TARGET_CFLAGS += \
    -I$(STAGING_DIR)/usr/include/libusb-1.0 
 
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
endef

define Package/rtl_fm_streamer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/rtl_* $(1)/usr/bin/
endef


$(eval $(call BuildPackage,rtl_fm_streamer))