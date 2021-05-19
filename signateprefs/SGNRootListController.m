#import <Preferences/PSListController.h>

@interface SGNRootListController : PSListController

@end
@implementation SGNRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Signate" target:self];
	}

	return _specifiers;
}

-(void)openTwitterDM {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/messages/compose?recipient_id=765771568337264641&text=%28Please+describe+your+issue+here%29"] options:@{} completionHandler:nil];
}
-(void)openTwitter5px {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/o5pxels"] options:@{} completionHandler:nil];
}
-(void)openTwitterRO {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/rollerorangedev"] options:@{} completionHandler:nil];
}


@end
