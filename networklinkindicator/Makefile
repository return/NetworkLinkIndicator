include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NetworkLinkIndicator
NetworkLinkIndicator_FILES = NetworkLinkIndicator.mm
NetworkLinkIndicator_INSTALL_PATH = /Library/PreferenceBundles
NetworkLinkIndicator_FRAMEWORKS = UIKit
NetworkLinkIndicator_PRIVATE_FRAMEWORKS = Preferences
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 11.2
TARGET = iphone:clang:11.2:latest
ARCHS := arm64

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NetworkLinkIndicator.plist$(ECHO_END)
