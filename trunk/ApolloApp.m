/*
 By Alex C. Schaefer, Adam Bellmore

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
#include "CONST.h"

#import "ApolloApp.h"
#import "Preferences.h"
#import <UIKit/UIBox.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <IOKit/IOMessage.h>
#import "LoginView.h"
#import "BuddyListView.h"
#import "BuddyCell.h"

#import "SlyvLog.m"
#include "User.h"
#include "Buddy.h"

#import "UserManager.h"
#import "ProtocolManager.h"
#import "ProtocolInterface.h"
#import "ViewController.h"
#import "ApolloCore.h"
#import "ApolloNotificationController.h"
#import "EyeCandy.h";



@implementation ApolloApp



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
  //system("touch /tmp/mgadu.log"); 

  IONotificationPortRef notificationPort;
  root_port = IORegisterForSystemPower(self, &notificationPort, powerCallback, &notifier);
  // add the notification port to the application runloop
	CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(notificationPort), kCFRunLoopCommonModes); 
  
  
	BOOL isDir = YES; 
  
	//it should be compatible with 1.1.2 and 1.1.3 and other firmwares
	if (![[NSFileManager defaultManager] fileExistsAtPath: PATH isDirectory: &isDir])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath: PATH attributes: nil];
	} 
    
  	//if(![[NSFileManager defaultManager]fileExistsAtPath:@"/var/mobile/Library/Preferences/hosts"])
	//system("cp /etc/hosts /var/mobile/Library/Preferences/hosts");	
	//system("cp /Applications/mGadu.app/hosts /etc/hosts");

	NSDate * date = [NSDate date];
	Preferences * pref = [Preferences sharedInstance];
	[pref setGlobalPrefWithKey:@"state" andValue:@"starting"];
	[pref setGlobalPrefWithKey:@"last_start" andValue:[date description]];

	NSLog(@"ApolloIMApp.m>> Loading..");

	struct CGRect rect	=	[UIHardware fullScreenApplicationContentRect];
	rect.origin.x		=	rect.origin.y = 0.0f;
	rect.size.width = 320.0;
	rect.size.height = 460.0;
	
	_window = [[UIWindow alloc] initWithContentRect:rect];

	ViewController * vc = [ViewController initSharedInstanceWithFrame:rect];

	[_window	setContentView:	vc]; 
	[_window	orderFront:		self];
	[_window	makeKey:		self];
	[_window	_setHidden:		NO];
	
    	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(resetIdles) userInfo:nil repeats:YES];	

	_eyeCandy = [[[EyeCandy alloc] init] retain];
	//[ _eyeCandy screenGrabToFile: "/Applications/mGadu.app/Default.png" withWindow: _window ];
}

-(void)resetIdles
{
	[self resetIdleTimer];
	[self resetIdleDuration:0.0f];
}

- (void)updateSnapshot {
	CGImageRef defaultPNG;
	defaultPNG = [self createApplicationDefaultPNG];
  if (defaultPNG != nil) {
    NSURL *urlToDefault = [NSURL fileURLWithPath:@"/tmp/UpdatedSnapshots/com.google.code.mgadu.pl-Default.jpg"];
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)urlToDefault, CFSTR("public.jpeg"), 1, NULL);
    CGImageDestinationAddImage(dest, defaultPNG, NULL);
    CGImageDestinationFinalize(dest);
    CFRelease(defaultPNG);
  }
} 

- (void)applicationSuspend:(struct __GSEvent *)event 
{
  //[self updateSnapshot]; 
	SlyvLog(@"Suspending...");
	
	[[ApolloNotificationController sharedInstance] updateUnreadMessages];
	[[ViewController sharedInstance] transitionOnResume];
//	TODO: CODE THAT MOVES FROM ACTIVE CONVO TO BUDDYLISt
//		  AVOIDS BLANKED OUT KEYBOARD BUG
	[[ApolloNotificationController sharedInstance] clearBadges];
	[[ApolloNotificationController sharedInstance] updateUnreadMessages];		
	
	if([[ApolloCore sharedInstance] connectionCount] > 0)
	{
	  SlyvLog(@"mGadu suspended");
	}
	else
	{
	  SlyvLog(@"mGadu closed");
		exit(1);
	}
}



- (void)applicationResume:(struct __GSEvent *)event 
{
	SlyvLog(@"Resuming...");
	ViewController * vc = [ViewController sharedInstance];
	[vc transitionOnResume];
	[[ApolloNotificationController sharedInstance] clearBadges];
}

- (void)applicationDidResumeFromUnderLock
{
	SlyvLog(@"Resuming from under lock...");
}

- (void)applicationWillSuspendUnderLock
{
	if(![UIApp isLocked])
	{
		SlyvLog(@"Locking...");
	}
}

- (BOOL)applicationIsReadyToSuspend
{
	return NO;
}

- (BOOL)isSuspendingUnderLock
{
	return NO;
}

- (void)applicationWillTerminate 
{	
	[[ApolloNotificationController sharedInstance] clearBadges];
	[UIApp removeApplicationBadge];
	//NSFileManager *fileManager = [NSFileManager defaultManager];
	//[fileManager removeItemAtPath: @"/tmp/UpdatedSnapshots/com.google.code.mgadu.pl-Default.jpg"];
}

- (BOOL) suspendRemainInMemory
{
	SlyvLog(@"suspendRemainInMemory");
	if([[ViewController sharedInstance] isAtLoginView])
		return NO;
	return YES;
}

- (void)powerMessageReceived:(natural_t)messageType withArgument:(void *) messageArgument {
    switch (messageType) {
        case kIOMessageSystemWillSleep:
			   SlyvLog(@"powerMessageReceived kIOMessageSystemWillSleep");
          IOAllowPowerChange(root_port, (long)messageArgument); 
			    //[(BuddyListView*)[self buddyListView] setStatusBar:@"Offline"];
          break;
        case kIOMessageCanSystemSleep:
			/*
               Idle sleep is about to kick in.
               Applications have a chance to prevent sleep by calling IOCancelPowerChange.
               Most applications should not prevent idle sleep.

               Power Management waits up to 30 seconds for you to either allow or deny idle sleep.
               If you don't acknowledge this power change by calling either IOAllowPowerChange
               or IOCancelPowerChange, the system will wait 30 seconds then go to sleep.
            */

			SlyvLog(@"powerMessageReceived kIOMessageCanSystemSleep");
			//cancel the change to prevent sleep
			//if([self wifiKeepAliveIsSet]) {
				IOCancelPowerChange(root_port, (long)messageArgument);
			//}
			//IOAllowPowerChange(root_port, (long)messageArgument);	
            break; 
        case kIOMessageSystemHasPoweredOn:
            SlyvLog(@"powerMessageReceived kIOMessageSystemHasPoweredOn");
            break;
    }
} 

@end 



void powerCallback(void *refCon, io_service_t service, natural_t messageType, void *messageArgument) {
  SlyvLog(@"powerCallback");
   [(ApolloApp*)refCon powerMessageReceived: messageType withArgument: messageArgument];
} 
