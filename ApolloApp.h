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
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAnimator.h>
#include "EyeCandy.h"

extern UIApplication *UIApp;
void powerCallback(void *refCon, io_service_t service, natural_t messageType, void *messageArgument); 

@interface ApolloApp : UIApplication 
{
  UIWindow		*_window;
  EyeCandy 		*_eyeCandy; 
  io_connect_t		root_port;
	io_object_t			notifier; 
}
- (void)resetIdles;
- (void)takeSnapshot;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate;
- (void)applicationSuspend:(struct __GSEvent *)event;
- (void)applicationResume:(struct __GSEvent *)event;
- (BOOL)isSuspendingUnderLock;
- (BOOL)applicationIsReadyToSuspend;
- (BOOL) suspendRemainInMemory;
- (void)applicationDidResumeFromUnderLock;
- (void)applicationWillSuspendUnderLock;
@end
