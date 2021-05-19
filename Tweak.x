#import <sysctl.h>

static bool uptimeTextEnabled = YES;
static bool enabled = YES;
static int displaySetting = 1;
static int fontSize = 16;
static int fontWeight = 1;
static int fontAlignment = 1;
static CGFloat horizontalOffset = 0;
static CGFloat verticalOffset = 145;
static UILabel *uptimeLabel;
static NSTimer *timer;
int notCentered;

@interface SBFPagedScrollView : UIScrollView
@end

@interface _UILegibilitySettings
@property (nonatomic,retain) UIColor * primaryColor;
@end

@interface SBUILegibilityLabel : UIView
@property (assign,nonatomic) long long textAlignment;
@property (nonatomic,copy) UIColor * textColor;
@property (nonatomic,retain) UIFont * font;
@end

@interface SBFLockScreenDateView : UIView
@property (nonatomic,retain) UIColor * textColor;
@property (nonatomic,readonly) double contentAlpha;
-(NSMutableString *)updateUptime;
-(void)setUptimeLabel;
@end

@interface CSCoverSheetView : UIView
@property (nonatomic,retain) SBFLockScreenDateView * dateView;
@property (nonatomic,retain) SBFPagedScrollView * scrollView;
@end

@interface CSCoverSheetViewController : UIViewController
@property (nonatomic,readonly) CSCoverSheetView * coverSheetView;
@end

static void reloadSettings() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.5px.signate.plist"];
	if(prefs) {
		uptimeTextEnabled = [prefs objectForKey:@"uptimeTextEnabled"] ? [[prefs objectForKey:@"uptimeTextEnabled"] intValue] : enabled;
		enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] intValue] : enabled;
		displaySetting = [prefs objectForKey:@"displaySetting"] ? [[prefs objectForKey:@"displaySetting"] intValue] : displaySetting;
		fontWeight = [prefs objectForKey:@"fontWeight"] ? [[prefs objectForKey:@"fontWeight"] intValue] : fontWeight;
		fontAlignment = [prefs objectForKey:@"fontAlignment"] ? [[prefs objectForKey:@"fontAlignment"] intValue] : fontAlignment;
		horizontalOffset = [prefs objectForKey:@"offsetWidth"] ? [[prefs objectForKey:@"offsetWidth"] floatValue] : horizontalOffset;
		verticalOffset = [prefs objectForKey:@"offsetHeight"] ? [[prefs objectForKey:@"offsetHeight"] floatValue] : verticalOffset;
	}
}

static void updateVisibility(int action)
{
	[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn
			 animations:^{ uptimeLabel.alpha = action;}
completion:nil];
}

%hook SBFPagedScrollView
-(void)setCurrentPageIndex:(unsigned long long)arg1 {
	%orig;

	if (arg1 == 1)
		updateVisibility(1);
	else
		updateVisibility(0);
}
%end
%hook SBFLockScreenDateView
-(void)layoutSubviews {
	%orig;
	if (enabled) {
		if (!uptimeLabel)
		{
			uptimeLabel = [[UILabel alloc] init];
			[self addSubview:uptimeLabel];
			timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setUptimeLabel) userInfo:nil repeats:YES];
		} 
	}
}

-(void)_updateLabels {
	%orig;
	[self setUptimeLabel];
}

-(void)_updateLabelAlpha {
	%orig;
	uptimeLabel.alpha = self.contentAlpha;
}

-(void)setDateToTimeStretch:(double)arg1 {
	%orig;
	if (arg1 > 0) {
		uptimeLabel.frame = CGRectMake(uptimeLabel.frame.origin.x,self.frame.origin.y + verticalOffset + arg1,uptimeLabel.frame.size.width,uptimeLabel.frame.size.height);
	}
}
%new
-(void)setUptimeLabel {
	reloadSettings();
	if (!enabled && uptimeLabel) {
		[uptimeLabel removeFromSuperview];
		uptimeLabel = nil;
		if (timer) {
			[timer invalidate];
		}
		return;
	} else if (enabled && !uptimeLabel) {
		uptimeLabel = [[UILabel alloc] init];
		[self addSubview:uptimeLabel];
		timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setUptimeLabel) userInfo:nil repeats:YES];	
	}
	UIFontWeight weight = UIFontWeightRegular;
	if (fontWeight == 0) {
		weight = UIFontWeightThin;
	} else if (fontWeight == 2) {
		weight = UIFontWeightBold;
	} else if (fontWeight == 3) {
		weight = UIFontWeightHeavy;
	}
	uptimeLabel.textColor = [UIColor whiteColor];
	uptimeLabel.textAlignment = fontAlignment;
	uptimeLabel.font = [UIFont systemFontOfSize:fontSize weight:weight];
	if ([[UIScreen mainScreen] bounds].size.width <= [[UIScreen mainScreen] bounds].size.height) {
		[uptimeLabel setFrame:CGRectMake(horizontalOffset, self.frame.origin.y + verticalOffset, self.frame.size.width , fontSize)];
	}
	uptimeLabel.text = [self updateUptime];
	uptimeLabel.lineBreakMode = NSLineBreakByWordWrapping;
	uptimeLabel.numberOfLines = 0;
}
%new
- (NSMutableString *)updateUptime {
	NSMutableString* nextUptimeString = [[NSMutableString alloc] init];
	struct timeval sys_boot_time;
	int arg_arr[2] = {CTL_KERN, KERN_BOOTTIME};
	size_t struct_size = sizeof(sys_boot_time);
	sysctl(arg_arr, 2, &sys_boot_time, &struct_size, NULL, 0);
	__darwin_time_t uptime = time(NULL) - sys_boot_time.tv_sec;
	if(!uptime) {
		uptime = (__darwin_time_t)[NSProcessInfo processInfo].systemUptime;
	}
	if (uptimeTextEnabled) {
		[nextUptimeString appendString:[NSString stringWithFormat:@"Uptime: %@", nextUptimeString]];
	}
	if(uptime) {
		// convert uptime to string
		int dividers[] = {86400, 3600, 60, 1};
		NSArray *unitNames = @[@"Day", @"Hour", @"Minute", @"Second"];
		int usable = 0;
		int loopcounter;
		int res = uptime;
		for (loopcounter = 0; loopcounter <= displaySetting; loopcounter++) {
			usable = res / dividers[loopcounter];
			res = (int)uptime % dividers[loopcounter];
			if(usable) {
				[nextUptimeString appendString:[NSString stringWithFormat:@"%d %@%s ", usable, [unitNames objectAtIndex:loopcounter], (usable > 1 ? "s" : "")]];
			}
		}
	}
	return nextUptimeString;
}

%end
%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadSettings, CFSTR("com.5px.signate.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	reloadSettings();
}
