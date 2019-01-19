// #import <Preferences/Preferences.h>
#import <Preferences/PSListController.h>
#import <Flipswitch/Flipswitch.h>
#import <notify.h>

// The tweak's Settings to enable/disable the indicator //
#define kPreferencesLocation @"/var/mobile/Library/Preferences/lt.pagefau.return0e.networklinkindicator.plist"
#define LOCALISATION_BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/NetworkLinkIndicator.bundle"]

@interface NetworkLinkIndicatorListController: PSListController {
	NSArray *specifiers;
}
-(void)reloadPrefs:(NSNotification*)notification;
@end
static BOOL NLCIsIndicatorEnabled;

@implementation NetworkLinkIndicatorListController
-(id)init{
	self = [super init];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadPrefs" object:nil];

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)reloadCallback,
									CFSTR("lt.pagefau.return0e.networklinkindicator/fsSwitchON"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately
									);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)reloadCallback,
									CFSTR("lt.pagefau.return0e.networklinkindicator/fsSwitchOFF"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately
									);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPrefs:) name:@"reloadPrefs" object:nil];

	return self;
}
- (id)specifiers 
{
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"NetworkLinkIndicator" target:self] retain];
	}
	specifiers = _specifiers;
	return _specifiers;
}
void reloadCallback() 
{
	NSLog(@"NetworkLinkIndicatorListController: reloading preferences");	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPrefs" object:nil];
}
-(void)reloadPrefs:(NSNotification*)notification
{
	[self reloadSpecifiers];
}

-(void)enableTweak{

		 NSMutableDictionary * tweak_preferences = [ [NSMutableDictionary alloc] initWithContentsOfFile:kPreferencesLocation];

		// This is for the tweak's preferences.
	 	NLCIsIndicatorEnabled = ([tweak_preferences objectForKey:@"NLCIsIndicatorEnabled"] ? [[tweak_preferences objectForKey:@"NLCIsIndicatorEnabled"] boolValue] : NLCIsIndicatorEnabled);

		if(NLCIsIndicatorEnabled == true){
			// NSLog(@"NetworkLinkConditioner: The tweak is enabled");
		}else{
			// NSLog(@"NetworkLinkConditioner: The tweak is disabled");
		}
}
@end