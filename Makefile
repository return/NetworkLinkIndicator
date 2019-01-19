include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NetworkLinkIndicator
NetworkLinkIndicator_FILES = Tweak.xm
NetworkLinkIndicator_FRAMEWORKS = Foundation CoreFoundation
NetworkLinkIndicator_PRIVATE_FRAMEWORKS = Preferences
NetworkLinkIndicator_CFLAGS = -fobjc-arc -w
ARCHS := arm64

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"

SUBPROJECTS += networklinkindicator

include $(THEOS_MAKE_PATH)/aggregate.mk