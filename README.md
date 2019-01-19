## NetworkLinkIndicator

A tweak to show a banner of Apple's NetworkLinkConditioner running in the background, similar to the macOS version of the tool which shows a StatusBar item.

When switched on, this tool shows a banner whenever the NetworkLinkConditioner is switched on. That's it. This is useful for switching between profiles and you forget to turn off the conditioner when testing.

As long as the tweak is enabled, the banner will be shown when the NetworkLinkConditioner is also switched on.

# Requirements
* A Jailbroken 64 bit iOS device
* iOS 9+

Using a 32 bit iOS device is not supported. (I don't own such a device to test this.)

Download the tweak on the releases page, or if you prefer to build it yourself, read the building instructions below.

# Building Requirements
* Theos Development Environment
* iOS 9+ SDK
* iDevice SSH Access

Clone this repo and run the following:

`export THEOS_DEVICE_IP=$(YOUR_IDEVICE_IP_ADDRESS)`

`export THEOS_DEVICE_PORT=$(YOUR_IDEVICE_SSH_PORT)`

`make package install`

Restart the Settings app and it should be available as a PreferencePane.

# License
GPL-3.0
