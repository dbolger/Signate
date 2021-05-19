PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)
INSTALL_TARGET_PROCESSES = SpringBoard
export ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = Signate
Signate_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations 
$(TWEAK_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MobileTimer SpringBoardFoundation CoverSheet
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += signateprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
