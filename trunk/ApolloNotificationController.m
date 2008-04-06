#import "ApolloNotificationController.h"
#import "ApolloCore.h"
#import <UIKit/UIKit.h>
#import <Celestial/AVController.h>
#import <Celestial/AVQueue.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVController-AVController_Celeste.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <time.h>
#import "CONST.h"
//Special thankyou to Jonathan Saggau, nice code mate.

//From Aaron hillegass
#define LogMethod() NSLog(@"-[%@ %s]", self, _cmd)

static id sharedInst;
static NSRecursiveLock *lock;

extern UIApplication *UIApp;

extern void * _CTServerConnectionCreate(CFAllocatorRef, int (*)(void *, CFStringRef, CFDictionaryRef, void *), int *);
extern int _CTServerConnectionSetVibratorState(int *, void *, int, float, float, float, float); 

@interface ApolloNotificationController (PrivateAPI)
-(void)play:(AVItem *)item;
@end

@implementation ApolloNotificationController

+ (void)initialize
{
    sharedInst = lock = nil;
}

+ (id)sharedInstance
{
    [lock lock];
    if (!sharedInst)
    {
        sharedInst = [[[self class] alloc] init];
    }
    [lock unlock];    
    return sharedInst;
}

- (id)init
{
	self = [super init];
	_isPlaying = NO;
	_isVibrating = NO; 
	if (nil!= self)
	{
//		addressBook = [[AddressBook alloc] init];	
	
		NSError *err;				
		NSLog(@"RINGER STATE %d", [UIHardware ringerState]);
		[UIApp removeApplicationBadge];
		totalUnreadMessages = 0;
		
		//Sound declarations
		NSString *path = [NSString stringWithFormat: @"%@/ApolloRecv.wav", PATH_MEDIA];
		//NSLog (@"pathMedia: %@", pathMedia);
		NSLog (@"wav path: %@", path);
		recvIm = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

		path = [NSString stringWithFormat: @"%@/ApolloSend.wav", PATH_MEDIA];
//		path = [[NSBundle mainBundle] pathForResource:@"ApolloSend" ofType:@"aiff" inDirectory:@"/"];		
		sendIm = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

		path = [NSString stringWithFormat: @"%@/ApolloSignOn.wav", PATH_MEDIA];
		signOn = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}
		
		path = [NSString stringWithFormat: @"%@/ApolloSignOff.wav", PATH_MEDIA];
		signOff = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

/*
		path = [[NSBundle mainBundle] pathForResource:@"ApolloGoAway" ofType:@"wav" inDirectory:@"/"];
		goAway = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}
		
		path = [[NSBundle mainBundle] pathForResource:@"ApolloComeBack" ofType:@"wav" inDirectory:@"/"];
		comeBack = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}		*/

		controller = [[AVController alloc] init];
//		controller = [AVController avController];
		[controller setDelegate:self];
		[controller setVibrationEnabled:YES];		
		
		q = [[AVQueue alloc] init];
		
		[q appendItem:recvIm error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}

		[q appendItem:sendIm error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:signOn error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:signOff error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
/*
		[q appendItem:goAway error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:comeBack error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}					*/
	}
	return self;
}

-(NSString*)getDisplayNameOfIMUser:(NSString*)cleanName forProtocol:(NSString*)proto
{
//       return [addressBook getDisplayNameOfIMUser:cleanName  protocol:proto];
	return nil;
}

-(void)vibrateForDuration
{
  //Slyv: fuck the thread, i think (and i hope) we don't neeed it
	//[NSThread detachNewThreadSelector:@selector(vibrateThread) toTarget:self withObject:nil];
	//NSLog (@"VIBR: %d", system("ps x | grep vibrator > /dev/null"));
	NSLog (@"Vibrating");
	if(_isVibrating == NO && purple_prefs_get_bool("/mgadu/vibrating")) {
		NSLog(@"Start Vibrating...");
		_isVibrating = YES;
		[NSThread detachNewThreadSelector:@selector(vibrateThread) toTarget:self withObject:nil];
	} 
	
	
	
  //system("/Applications/mGadu.app/vibrator &");
}

int vibratecallback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data) {
	return 1;
} 

-(void)vibrateThread
{
	NSAutoreleasePool* p = [[NSAutoreleasePool alloc] init];
	int x;
  void *connection = _CTServerConnectionCreate(kCFAllocatorDefault, vibratecallback, NULL);
 
	_CTServerConnectionSetVibratorState(&x, connection, 3, 10.0, 10.0, 10.0, 10.0);
  time_t now = time(NULL);
  while (time(NULL) - now < 0.5) { }
	_CTServerConnectionSetVibratorState(&x, connection, 0, 10.0, 10.0, 10.0, 10.0);
	_isVibrating = NO;
	[p release]; 
	


	//This all should work.  But it doesn't.  So fuck that noise. We'll do this the old fashion way.
	/*NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];	
	NSLog(@"VIBR CHECK");
	NSLog (@"VIBR: %d", system("ps x | grep vibrator > /dev/null")); 
	if (system("ps x | grep vibrator > /dev/null") <= 0) {
  	NSLog(@"VIBRATING");
    system("/Applications/mGadu.app/vibrator &");
  } else {
  	NSLog(@"NOT VIBRATING");
  }
	[pool release];	*/
	
/*	int x = 0;    
	NSLog(@"Connecting to telephony...");
	int connection = _CTServerConnectionCreate(kCFAllocatorDefault, callback, &x);    
	NSLog(@"Setting vibrator state...");
	int ret = _CTServerConnectionSetVibratorState(&x, connection, 3, 10, 10, 10, 10);    
	NSLog(@"Timing it...");
	time_t now = time(NULL);    	
	while (time(NULL) - now < 10)
	{
	}	
	NSLog(@"Killing vibrator...");	
	_CTServerConnectionSetVibratorState(&x, connection, 0, 10, 10, 10, 10);*/
	
	
}

- (void)dealloc
{
/*recvIm
sendIm
signOn
signOff
goAway
comeBack*/
	[recvIm release]; recvIm = nil;
	[sendIm release]; sendIm = nil;
	[signOn release]; signOn = nil;
	[signOff release]; signOff = nil;
	[goAway release]; goAway = nil;
	[comeBack release]; comeBack = nil;
	[q release]; q = nil;
	[controller release]; controller = nil;
	[super dealloc];
}

int callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data) 
{
    return 1;
}

-(void)setVibrateEnabled:(bool)enable
{
	vibrateEnabled = enable;	
}

-(BOOL) vibrateEnabled
{
	return vibrateEnabled;
}

-(BOOL)soundEnabled
{
	return soundEnabled;
}

-(void)playSignOff
{
	[self play:signOff withVibrating:false];
}

-(void)playSignon
{
	[self play:signOn withVibrating:false];
}

-(void)playSendIm
{
	[self play:sendIm withVibrating:false];	
}

-(void)playRecvIm
{
	[self play:recvIm withVibrating:true];
}

-(void)receiveUnreadMessages:(int)msgCount  //should just do playRecvIm
{
	totalUnreadMessages+=msgCount;
	[self updateUnreadMessages];
	NSLog(@"Set count to %d",msgCount);	
}

-(void)updateUnreadMessages
{
//	if([UIApp isSuspended] || [UIApp isLocked])
	{
		[lock lock];
		if(totalUnreadMessages <= 20)
			[UIApp setApplicationBadge:[NSString stringWithFormat:@"%u",totalUnreadMessages]];
		else
			[UIApp setApplicationBadge:@"20+"];
		[lock unlock];
	}
	if(totalUnreadMessages == 0)
	{
		[UIApp removeApplicationBadge];
        	[UIApp removeStatusBarImageNamed:@"mGaduMsg"];
        	[UIApp removeStatusBarImageNamed:[[ApolloCore sharedInstance] getRealStatus]];
        	[UIApp addStatusBarImageNamed:[[ApolloCore sharedInstance] getRealStatus] removeOnAbnormalExit:YES];
		NSLog(@"Clearing badge...");
	} else {	
        	[UIApp removeStatusBarImageNamed:[[ApolloCore sharedInstance] getRealStatus]];
        	[UIApp removeStatusBarImageNamed:@"mGaduMsg"];
	        [UIApp addStatusBarImageNamed:@"mGaduMsg" removeOnAbnormalExit:YES];
	}
}

-(void)switchToConvoWithMsgs:(int)msgCount
{
	totalUnreadMessages-=msgCount;
	[self updateUnreadMessages];
	NSLog(@"Decrementing badge...");
}

-(void)clearBadges
{	
//	totalUnreadMessages = 0;
//	[UIApp removeApplicationBadge];
}

-(void)playGoAway
{
	[self play:goAway withVibrating:true];
}

-(void)playComeBack
{
	[self play:comeBack withVibrating:true];
}

-(void)play:(AVItem *)item withVibrating:(bool)vibr
{

  //Slyv - this is from original Apollo, but it causes iphone freezes when many "plays" in short time
	//[NSThread detachNewThreadSelector:@selector(soundThread:) toTarget:self withObject:item];


  //Slyv, i uncommented below, and it dosn't freeze anymore
	if([UIHardware ringerState] && purple_prefs_get_bool("/mgadu/sounds"))  //this will be moved to individual options to allow customized which sounds on/off.  I am lazy right now.
	{
	 [lock lock];
		NSLog(@"Playing.X");
		[controller setCurrentItem:item];
		[controller setCurrentTime:(double)0.0];
		NSError *err;
		[controller play:&err];
		[lock unlock];

		//if(nil != err)
		//{
			//NSLog(@"err! = %@    [controller play:&err];", err); 
			//exit(1);
		//}
	}
	if (vibr) [self vibrateForDuration];
}

-(void)soundThread:(AVItem *)item
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if([UIHardware ringerState])  //this will be moved to individual options to allow customized which sounds on/off.  I am lazy right now.
	{
		[lock lock];
		NSLog(@"Playing.");
		[controller setCurrentItem:item];
		[controller setCurrentTime:(double)0.0];
		NSError *err;
		[controller play:&err];
		//if(nil != err)
		//{
		//	NSLog(@"err! = %@    [controller play:&err];", err); 
		//	exit(1);
		//}
		[lock unlock];
	}	
	//[self vibrateForDuration];
	[pool release];	
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  NSLog(@"NOTIFICATION>> Request for selector: %@", NSStringFromSelector(aSelector));
  return [super respondsToSelector:aSelector];
}

-(void)stop;
{
	[controller pause];
}


- (void)queueItemWasAdded:(id)fp8
{
LogMethod();
}
@end
