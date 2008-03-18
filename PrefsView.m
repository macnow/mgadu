/*
 By Adam Bellmore

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
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIImage.h>
#import <UIKit/UITextView.h>
#import <UIKit/UISwitchControl.h>

#import "ApolloCore.h"
#import "PrefsView.h"
#import "ViewController.h"
#import "PurpleInterface.h"
#import "EyeCandy.h" 

@implementation PrefsView

- (id) initWithFrame:(CGRect) aframe
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
		float transparent[4] = {0.0, 0.0, 0.0, 0.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

                top_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 59.0f)];
                [top_bar setImage:[UIImage applicationImageNamed: @"login_topnav_background.png"]];

                cancel_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
                [cancel_button setFrame:CGRectMake(5, 7.0, 59.0, 32.0)];
                [cancel_button setImage: [UIImage applicationImageNamed: @"login_addcancelbutton_up.png"]
                                        forState: 0];
                [cancel_button setImage: [UIImage applicationImageNamed: @"login_addcancelbutton_down.png"]
                                        forState: 1];
                [cancel_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

                save_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
                [save_button setFrame:CGRectMake(aframe.size.width-(61.0+5.0), 7.0, 61.0, 32.0)];
                [save_button setImage: [UIImage applicationImageNamed: @"login_addsavebutton_up.png"]
                                        forState: 0];
                [save_button setImage: [UIImage applicationImageNamed: @"login_addsavebutton_down.png"]
                                        forState: 1];
                [save_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

                contact_view = [[UIView alloc] initWithFrame: CGRectMake(0, 45, 320, 415)];

                archive_cell = [[UIPreferencesTextTableCell alloc] init];
                [archive_cell setTitle: [NSString stringWithUTF8String: "Archiwum wiadomości"]];
                [archive_cell setEnabled:YES];

                archive_switch = [[UISwitchControl alloc] initWithFrame:CGRectMake(208.0f, 10.0f, 50.0f, 58.0f)];
            		[archive_switch setBackgroundColor: CGColorCreate(colorSpace, transparent)];
            		[archive_switch addTarget:self action:@selector(switchClick:) forEvents: 1<<6]; 
                [archive_cell addSubview:archive_switch];
                

                sounds_cell = [[UIPreferencesTextTableCell alloc] init];
                [sounds_cell setTitle: [NSString stringWithUTF8String: "Dźwięki"]];
                [sounds_cell setEnabled:YES];

                sounds_switch = [[UISwitchControl alloc] initWithFrame:CGRectMake(208.0f, 10.0f, 50.0f, 58.0f)];
            		[sounds_switch setBackgroundColor: CGColorCreate(colorSpace, transparent)];
            		[sounds_switch addTarget:self action:@selector(switchClick:) forEvents: 1<<6]; 
                [sounds_cell addSubview:sounds_switch];


                vibrating_cell = [[UIPreferencesTextTableCell alloc] init];
                [vibrating_cell setTitle: [NSString stringWithUTF8String: "Wibracje"]];
                [vibrating_cell setEnabled:YES];

                vibrating_switch = [[UISwitchControl alloc] initWithFrame:CGRectMake(208.0f, 10.0f, 50.0f, 58.0f)];
            		[vibrating_switch setBackgroundColor: CGColorCreate(colorSpace, transparent)];
            		[vibrating_switch addTarget:self action:@selector(switchClick:) forEvents: 1<<6]; 
                [vibrating_cell addSubview:vibrating_switch];




                pref_table = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 415.0f)];
                [pref_table setDataSource:self];
                [pref_table setDelegate:self];
                [pref_table reloadData];

                [contact_view addSubview:pref_table];
                [self addSubview:top_bar];
                [self addSubview:cancel_button];
                [self addSubview:save_button];
                [self addSubview:contact_view];
		
	}
	return self;
}


- (void) buttonEvent:(UIPushButton *)button 
{
	NSLog(@"BUTTON");
	if (![button isPressed] && [button isHighlighted])
        {
		if(button == cancel_button)
		{
			[[ViewController sharedInstance] transitionToLoginView];
		}
		if(button == save_button)
		{
			[self savePrefs];
			[[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "" ] withTitle:[NSString stringWithUTF8String: "Ustawienia zostały zapisane!"]];
			[[ViewController sharedInstance] transitionToLoginView];
		}
	}
}


// Table methods
-(int) numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable
{
        return 1;
}

-(int) preferencesTable:(UIPreferencesTable *)aTable numberOfRowsInGroup:(int)group
{
	if(group == 0)
	{
		return 3;
	}
	else if(group == 1)
	{
        	return 1;
	}
	else if(group == 2)
	{
        	return 1;
	}
}

-(UIPreferencesTableCell *) preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group
{
        UIPreferencesTableCell * cell = [[UIPreferencesTableCell alloc] init];
        return [cell autorelease];
}

-(float) preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed
{
        return proposed;
}

-(BOOL) preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group
{
        return;
}

-(UIPreferencesTextTableCell *) preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group
{
  if(group == 0)
  {
    if(row == 0)
      return archive_cell;
    else if(row == 1)
      return sounds_cell;
    else if(row == 2)
      return vibrating_cell;
  }
  return nil;
}

- (void)tableRowSelected:(NSNotification *)notification
{
    if([pref_table selectedRow] == 5)
    {
      [self removeBuddy];
    }
}

-(void) switchClick:(UISwitchControl *) sw
{	
  /*if ([sw value]) { 
    NSLog(@"switchClick ON");
  } else {
    NSLog(@"switchClick OFF");
  }*/
	//[user setActive: [sw value]];
} 

- (void)savePrefs
{
  NSLog(@"savePrefs");//archive_switch
  if ([archive_switch value])  purple_prefs_set_bool("/purple/logging/log_ims", TRUE); 
  else purple_prefs_set_bool("/purple/logging/log_ims", FALSE);  
  
  if ([sounds_switch value])  purple_prefs_set_bool("/mgadu/sounds", TRUE); 
  else purple_prefs_set_bool("/mgadu/sounds", FALSE);  

  if ([vibrating_switch value])  purple_prefs_set_bool("/mgadu/vibrating", TRUE); 
  else purple_prefs_set_bool("/mgadu/vibrating", FALSE);  

  
}

- (void)reloadData
{
  NSLog(@"PREFS reloadData");  
  if (!purple_prefs_exists("/mgadu"))
  {
    purple_prefs_add_none("/mgadu");
    purple_prefs_add_bool("/mgadu/sounds",YES);
    purple_prefs_add_bool("/mgadu/vibrating",YES);
    NSLog(@"prefs/gadu added");
  } else {
    NSLog(@"prefs/gadu exists");
  }
  
  if (purple_prefs_get_bool("/purple/logging/log_ims")) [archive_switch setValue: YES];
  else [archive_switch setValue: NO];

  if (purple_prefs_get_bool("/mgadu/sounds")) [sounds_switch setValue: YES];
  else [sounds_switch setValue: NO];

  if (purple_prefs_get_bool("/mgadu/vibrating")) [vibrating_switch setValue: YES];
  else [vibrating_switch setValue: NO];


}
@end

