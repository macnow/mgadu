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
#import "LoginView.h"
#import "BuddyListView.h"
#import "BuddyCell.h"

#include "SlyvLog.m"
#include "User.h"
#include "Buddy.h"

#import "UserManager.h"
#import "ProtocolManager.h"
#import "ProtocolInterface.h"
#import "ViewController.h"
#import "ApolloCore.h"
#import "ApolloNotificationController.h"



@implementation ApolloApp



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
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

	//[ViewController initSharedInstanceWithFrame:rect];

	//User * u = [[UserManager sharedInstance] getUserByName:@"humajime" andProtocol:TESTP];
	//id <ProtocolInterface> prot = [[ProtocolManager sharedInstance] protocolByName:TESTP];
	//[prot logIn:u];

	//NSLog(@"ApolloIMApp.m>> Initing _window...");
	//_window = [[UIWindow alloc] initWithContentRect:rect];	

	//NSLog(@"ApolloIMApp.m>> Initing startView...");
	//UIView * canvas = [[UIView alloc] initWithFrame:rect];
	//startView			=	[[StartView alloc] initWithFrame: rect];
	//LoginView * c = [[LoginView alloc] initWithFrame:rect];
	//[canvas addSubview:c];
	//Buddy * b = [[Buddy alloc] initWithName:@"NestorAjB" andGroup:@"Buddies"];
	//[b setStatusMessage:@"One upon a time there way a monkey!"];
	//BuddyCell * bc = [[BuddyCell alloc] initWithBuddy:b];
		
	//BuddyListView * bv = [[BuddyListView alloc] initWithFrame:rect];
	//[canvas addSubview:bv];

	//NSLog(@"ApolloIMApp.m>> Setting content...");
	//[_window	setContentView:	c]; 
	//[_window	setContentView:	bc]; 
	//[_window	setContentView:	bv]; 
	//[_window	orderFront:		self];
	//[_window	makeKey:		self];
	//[_window	_setHidden:		NO];
	/*
	float x = 0.0f;
	float y = 50.0f;
	int i;
	for(i=0; i<10; i++)
	{
		float lovelyShadeOfGreen[4] = {.1, .9, .1, 1};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();	
		CGRect frame = CGRectMake(x, 0, 4, y);
		UIBox * b = [[UIBox alloc] initWithFrame: frame];
		[b setBackgroundColor: CGColorCreate( colorSpace, lovelyShadeOfGreen)];
		[startView addSubview:b];
		x+=8.0f;
		y+=1.0f;
	}
	*/
	
//	NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Logs/Meteo.log"];
//	freopen("/tmp/Apollo.log", "a", stderr);	
}

-(void)resetIdles
{
	[self resetIdleTimer];
	[self resetIdleDuration:0.0f];
	/*if([UIApp isLocked] || [UIApp isSuspended])
	{
		[[NSString stringWithString:@"NINJA"]writeToFile:@"/tmp/SummerBoard.DisablePowerManagement" atomically:YES encoding:NSUTF8StringEncoding error:nil];	
	}*/
}

- (void)applicationSuspend:(struct __GSEvent *)event 
{
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
		//[[NSString stringWithString:@"NINJA"]writeToFile:@"/tmp/SummerBoard.DisablePowerManagement" atomically:YES encoding:NSUTF8StringEncoding error:nil];			
	}
	else
	{
  	SlyvLog(@"mGadu closed");
		//system("rm /tmp/SummerBoard.DisablePowerManagement");		
		exit(1);
	}
	
}

- (void)applicationResume:(struct __GSEvent *)event 
{
	SlyvLog(@"Resuming...");
	ViewController * vc = [ViewController sharedInstance];
	[vc transitionOnResume];
	//system("rm /tmp/SummerBoard.DisablePowerManagement");	
	[[ApolloNotificationController sharedInstance] clearBadges];
}

- (void)applicationDidResumeFromUnderLock
{
	SlyvLog(@"Resuming from under lock...");
		//system("rm /tmp/SummerBoard.DisablePowerManagement");	
}

- (void)applicationWillSuspendUnderLock
{
	if(![UIApp isLocked])
	{
		SlyvLog(@"Locking...");
		//[[NSString stringWithString:@"NINJA"]writeToFile:@"/tmp/SummerBoard.DisablePowerManagement" atomically:YES encoding:NSUTF8StringEncoding error:nil];	
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
	//system("rm /tmp/SummerBoard.DisablePowerManagement");
	//system("cp /var/mobile/Library/Preferences/hosts /etc/hosts");
}

- (BOOL) suspendRemainInMemory
{
	SlyvLog(@"suspendRemainInMemory");
	if([[ViewController sharedInstance] isAtLoginView])
		return NO;
	return YES;
}

@end