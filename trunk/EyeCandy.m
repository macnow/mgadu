#import "EyeCandy.h"

@implementation EyeCandy

- (void) showStandardAlert:(NSString *)title closeBtnTitle:(NSString *)closeTitle withError:(NSError *)error
{
	alertButton = [NSArray arrayWithObjects:@"Close",nil];
	alert = [[UIAlertSheet alloc] initWithTitle:title buttons:alertButton defaultButtonIndex:0 delegate:self context:nil];
	[alert setBodyText: [error localizedDescription]];
	[alert popupAlertAnimated: TRUE];
}

- (void) showStandardAlertWithString:(NSString *)title closeBtnTitle:(NSString *)closeTitle withError:(NSString *)error
{
	alertButton = [NSArray arrayWithObjects:@"Close",nil];
	alert = [[UIAlertSheet alloc] initWithTitle:title buttons:alertButton defaultButtonIndex:0 delegate:self context:nil];
	[alert setBodyText: error];
	[alert popupAlertAnimated: TRUE];
}

- (void) alertSheet: (UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated: TRUE];
}

- (void)showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect
{
	progress = [[UIProgressHUD alloc] initWithWindow: w];
	[progress setText: label];
	[progress drawRect: rect];
	[progress show: YES];
	
	[v addSubview:progress];
}

- (void)hideProgressHUD
{
	[progress show: NO];
	[progress removeFromSuperview];
}

- (void)screenGrabToFile: (NSString *) filename withWindow:(UIWindow *) _window
{
	CGImageRef image = [_window createSnapshotWithRect: CGRectMake(0.0f, 20.0f, 320.0f, 460.0f)];
	CFStringRef path = CFStringCreateWithCString( nil, filename, kCFStringEncodingASCII );
	CFURLRef url = CFURLCreateWithFileSystemPath( nil, path, kCFURLPOSIXPathStyle, 0 );
	
	CFStringRef type = CFStringCreateWithCString( nil, "public.png", kCFStringEncodingASCII );
	CGImageDestinationRef dest = CGImageDestinationCreateWithURL(url, type, 1, NULL);
	CGImageDestinationAddImage(dest, image, NULL);
	CGImageDestinationFinalize(dest);
	
	CFRelease(dest);
	CGImageRelease( image );
	CFRelease( url );
	CFRelease( type );
}

@end