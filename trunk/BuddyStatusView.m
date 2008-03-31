/*
 By Maciej Nowakowski

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
#import "BuddyStatusView.h"
#import "ViewController.h"
#import "PurpleInterface.h"
#import "EyeCandy.h" 

@implementation BuddyStatusView

- (id) initWithFrame:(CGRect) aframe withAccount:(PurpleAccount *) pa
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
		account = pa;
		user = [[ApolloCore sharedInstance]  getApolloUser:account];

                top_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 59.0f)];
                [top_bar setImage:[UIImage applicationImageNamed: @"login_topnav_background.png"]];

                cancel_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
                [cancel_button setFrame:CGRectMake(5, 7.0, 59.0, 32.0)];
                [cancel_button setImage: [UIImage applicationImageNamed: @"login_addcancelbutton_up.png"]
                                        forState: 0];
                [cancel_button setImage: [UIImage applicationImageNamed: @"login_addcancelbutton_down.png"]
                                        forState: 1];
                [cancel_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

	        set_button = [[UIPreferencesTableCell alloc] init];
                [set_button setTitle: [NSString stringWithUTF8String: "Ustaw opis"]];
                [set_button setHighlighted:YES];
                [set_button setTarget:self];

                list_view = [[UIView alloc] initWithFrame: CGRectMake(0, 45, 320, 415)];

		back_cell = [[UIPreferencesTableCell alloc] init];
                [back_cell setTitle: [NSString stringWithUTF8String: "Dostępny"]];
                [back_cell setImage: [UIImage applicationImageNamed: @"status_back.png"]];

		away_cell = [[UIPreferencesTableCell alloc] init];
                [away_cell setTitle: [NSString stringWithUTF8String: "Zaraz wracam"]];
                [away_cell setImage: [UIImage applicationImageNamed: @"status_away.png"]];

		invisible_cell = [[UIPreferencesTableCell alloc] init];
                [invisible_cell setTitle: [NSString stringWithUTF8String: "Niewidoczny"]];
                [invisible_cell setImage: [UIImage applicationImageNamed: @"status_invisible.png"]];

                status_cell = [[UIPreferencesTextTableCell alloc] init];
		[status_cell setPlaceHolderValue: [NSString stringWithUTF8String: "Opis..."]];
                [status_cell setEnabled:YES];
                status_field = [status_cell textField];

                pref_table = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 415.0f)];
                [pref_table setDataSource:self];
                [pref_table setDelegate:self];
                [pref_table reloadData];

		//[status_field setText:[[user getStatusMessage] UTF8String]];
                [list_view addSubview:pref_table];
                [self addSubview:top_bar];
                [self addSubview:cancel_button];
               	[self addSubview:list_view];
		
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
			[[ViewController sharedInstance] transitionToBuddyListView];
		}
	}
}


// Table methods
-(int) numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable
{
        return 3;
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
                {
                        return back_cell;
                }
                else if(row == 1)
                {
                        return away_cell;
                }
                else if(row == 2)
                {
                        return invisible_cell;
                }
	}
        else if(group == 1)
        {
                if(row == 0)
                {
                        return status_cell;
                }
        }
        else if(group == 2)
        {
                if(row == 0)
                {
                        return set_button;
                }
        }
        return nil;
}

- (void)tableRowSelected:(NSNotification *)notification
{
    NSLog(@"Row: %d",[pref_table selectedRow]);
    if([pref_table selectedRow] == 1)
    {
	[user setInvisible:NO];
	[user setAway:NO];
    }
    else if([pref_table selectedRow] == 2)
    {
	[user setInvisible:NO];
	[user setAway:YES];
    }
    else if([pref_table selectedRow] == 3)
    {
	[user setAway:NO];
	[user setInvisible:YES];
    }
    else if([pref_table selectedRow] == 7)
    {
	NSLog(@"Zmiana statusu opisowego na %@",[status_field text]);
	PurpleStatus* status = purple_account_get_active_status(account);
        purple_status_set_attr_string(status, "message", [[status_field text] UTF8String]);
    	PurplePlugin *gg_plugin = purple_find_prpl("prpl-gg"); 
    	PurplePluginProtocolInfo*    _prpl_info= PURPLE_PLUGIN_PROTOCOL_INFO(gg_plugin); 
    	_prpl_info->set_status(account, status); 
	[[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "" ] withTitle:[NSString stringWithUTF8String: "Opis został ustawiony!"]];
	[[ViewController sharedInstance] transitionToBuddyListView];
    }
}

@end

