

#import <Preferences/PSListController.h>
#import <Preferences/PSViewController.h>
#import <UIKit/UIKit.h>

// The tweak's Settings to enable/disable the indicator //
#define kPreferencesLocationNLC @"/var/mobile/Library/Preferences/lt.pagefau.return0e.networklinkindicator.plist"
#define LOCALISATION_BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/networklinkindicator.bundle"]
#define NSLocalizedStringInBundle(key) NSLocalizedStringFromTableInBundle(key, @"NetworkLinkIndicator", LOCALISATION_BUNDLE, nil)

// Apple's Network Link Conditioner plist and  // 
#define kPreferencesLocation @"/var/mobile/Library/Preferences/com.apple.network.prefPaneSimulate.plist"

@interface UIApplication (Private)
-(void)addStatusBarStyleOverrides:(int)style;
-(void)removeStatusBarStyleOverrides:(int)style;
-(void)setGlowAnimationEnabled:(BOOL)enabled forStyle:(int)style;
-(void)setDoubleHeightStatusText:(NSString*)text forStyle:(int)style;
@end

@interface PSTableCell : UITableViewCell
- (void)setValue:(id)arg1;
@end

// The NLISwitchController class allows the tweak to set the default tweak values in NSUserDefaults.
// Needed for the NLC On/Off Button.

@interface NLISwitchController : NSObject { 
 NSUserDefaults* userPreferences; 
}

@property (nonatomic) BOOL currentEnabledSetting;
@property (nonatomic) BOOL nliEnabled;	

+(NLISwitchController*)sharedInstance;
-(void)updateSettings;
-(void)setEnabled:(BOOL)enabled;
@end

@implementation NLISwitchController
+(NLISwitchController*)sharedInstance
{
	// A singleton is being created in this class
	// Creating a dispatch type
	static dispatch_once_t dpatch = 0;
	// Creating a strong link to a uninitialised _sharedObject.
	__strong static id _sharedObject = nil;
	
	// Define dispatch method to conform to singleton pattern.
	// Initialise the sharedObject in a dispatch block using the 'dpatch' pointer.
	dispatch_once(&dpatch,^{
		// Initialise to self.
		_sharedObject = [[self alloc] init];
	});
	// Next we return the initialised shared object, ready for use in
	// different classes and safe access.
	return _sharedObject;
}
-(id)init
{
	self = [super init];

	if(self)
	{
		NSLog(@"NLISwitchController init");
				
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:kPreferencesLocationNLC];

		// Get the value of the preference key: SKIsEnabled.
		id isEnabled = [userPreferences objectForKey:@"NLCIsIndicatorEnabled"];

		// Check if the switch is disabled, or else it is enabled.
		BOOL switchEnabled = isEnabled ? [isEnabled boolValue] : YES;
		
		// Let us see if NSUserDefaults is fine. Get the user defaults
		// in the domain of the Preferences application
		userPreferences = [[NSUserDefaults alloc] initWithSuiteName:@"lt.pagefau.return0e.networklinkindicator"];
		
		NSLog(@"User preferences from the announcer identity: %@",userPreferences);

		// Register the enabled preferences
		[userPreferences registerDefaults:@{
					@"enable" : @YES
		 }];

		// Saving the preferences to the setting file.
		[userPreferences setBool:switchEnabled forKey:@"NLCIsIndicatorEnabled"];
		
		// Detect if the settings have changed
		 _currentEnabledSetting = NO;
		 
		 // Get the settings from the switchEnabled bool and set the 
		 // internal state _nliEnabled to that.
		_nliEnabled = switchEnabled;
		
		NSLog(@"_nliEnabled: %d", _nliEnabled);
		
	}

	return self;
}
// Code to update the preferences slider.
-(void)updateSettings
{
	[self setEnabled:[userPreferences boolForKey:@"NLCIsIndicatorEnabled"]];
	_currentEnabledSetting = NO;
}
// Boolean for key for the preferences
-(void)setEnabled:(BOOL)enabled
{
	if(enabled == _nliEnabled)
	{
		return;
	}
	
	_nliEnabled = enabled;
	
	if(!_currentEnabledSetting)
	{
		[userPreferences setBool:_nliEnabled forKey:@"NLCIsIndicatorEnabled"];
	}
}		
@end

static void loadPreferences();
extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

void toggleOn();
void toggleOff();

void switchOn();
void switchOff();

// TODO: Obtain Profile name and preview it as a option.
typedef enum {
	NCL_100_PERCENT_LOSS = 0,
	NCL_3G,
	NCL_DSL,
	NCL_EDGE,
	NCL_HIGH_LATENCY_DNS,
	NCL_LTE,
	NCL_VERY_BAD_NETWORK,
	NCL_WIFI,
	NCL_WIFI_AC
} NLCStatus;

// Apple's settings for the Network Link Conditioner.
static NSString  *NLCSelectedProfile 	= @"";

// Tweak indicator boolean to enable the banner.
static BOOL NLCIsIndicatorEnabled 		= NO;

static BOOL NLCSwitch = NO;
static BOOL NLCPrefSwitchPane = NO;

// Method to load preferences //
static void loadPreferences() {

	 NSMutableDictionary * tweak_preferences = [ [NSMutableDictionary alloc] initWithContentsOfFile:kPreferencesLocationNLC];

	if(tweak_preferences){
		// This is for the tweak's setting.
	 	NLCIsIndicatorEnabled = ([tweak_preferences objectForKey:@"NLCIsIndicatorEnabled"] ? [[tweak_preferences objectForKey:@"NLCIsIndicatorEnabled"] boolValue] : NLCIsIndicatorEnabled);
	}
	// Check if the tweak is enabled //
	if(NLCIsIndicatorEnabled == FALSE){
		switchOn();
	}
	else {
		switchOff();
	}
}

%ctor{
	@autoreleasepool{
		loadPreferences();

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPreferences,
										CFSTR("lt.pagefau.return0e.networklinkindicator/settingschanged"),
										NULL,
										CFNotificationSuspensionBehaviorCoalesce
										);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)switchOn,
										CFSTR("lt.pagefau.return0e.networklinkindicator/fsSwitchON"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately
										);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)switchOff,
										CFSTR("lt.pagefau.return0e.networklinkindicator/fsSwitchOFF"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately
										);
		}								
}

void toggleOn() {
	// NSLog(@"NetworkLinkIndicator: Turn on NLC");

	UIApplication * app = [UIApplication sharedApplication];
	[app setGlowAnimationEnabled:YES forStyle:202];
	[app setDoubleHeightStatusText:@"Network Link Conditioner is Running." forStyle:202];
	[app addStatusBarStyleOverrides:4];
}
void toggleOff() {
	// NSLog(@"NetworkLinkIndicator: Turn off NLC Indication");

	UIApplication * app = [UIApplication sharedApplication];
	[app setGlowAnimationEnabled:NO forStyle:202];
	[app removeStatusBarStyleOverrides:4];
}

void switchOn() {
	// Sets the on switch for the tweak.
	[[NLISwitchController sharedInstance] setEnabled:YES];
}

void switchOff() {
	// Sets the off switch for the tweak.
	[[NLISwitchController sharedInstance] setEnabled:NO];
	toggleOff();
}

%hook PSTableCell
- (void)setValue:(id)arg1
{
	%orig;
	// Check if the NLC is switched on with our tweak also switched on or not.
	if(NLCPrefSwitchPane == YES && NLCIsIndicatorEnabled == FALSE) {
		if([arg1 isEqual:@"On"]) {
			NLCSwitch = YES;
			// NSLog(@"NLC is Enabled");
			toggleOn();
		} else if([arg1 isEqual:@"Off"]) {
			NLCSwitch = NO;
			// NSLog(@"NLC is Disabled");
			toggleOff();
		}
	} 
	else {
		NLCSwitch = NO;
	}
}
%end

%hook PSListController
- (id)specifierForID:(id)arg1
{
	NSString * str = [%orig identifier];
	NSString * str2 = [%orig name];
	
	// Check if the user is in the NLC settings prefpane and is about to enable/disable the NLC.
	// TODO: This hack probably needs to be replaced with something more reliable. (XPC?) 
	if(([str isEqual:@"NLC"] && [str2 isEqual:@"Status"])) {
		NSLog(@"You are in the NLC Prefpane");
		NLCPrefSwitchPane = YES;
	}
	else{
		NLCPrefSwitchPane = NO;
	}
	return %orig;
}
%end


