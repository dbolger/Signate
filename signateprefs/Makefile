include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SignatePrefs

SignatePrefs_FILES = SGNRootListController.m
SignatePrefs_INSTALL_PATH = /Library/PreferenceBundles
SignatePrefs_FRAMEWORKS = UIKit
SignatePrefs_PRIVATE_FRAMEWORKS = Preferences
SignatePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SignatePrefs.plist$(ECHO_END)
