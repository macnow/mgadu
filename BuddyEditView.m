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
#import "BuddyEditView.h"
#import "ViewController.h"
#import "PurpleInterface.h"
#import "EyeCandy.h" 

@implementation BuddyEditView

- (id) initWithFrame:(CGRect) aframe withBuddy:(Buddy *) buddy withAccount:(PurpleAccount *) pa
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
		b = buddy;
		account = pa;
		const char *aliasUTF8String;
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

	        delete_button = [[UIPreferencesTableCell alloc] init];
                [delete_button setTitle: [NSString stringWithUTF8String: "Usuń kontakt"]];
                [delete_button setHighlighted:YES];
                [delete_button setTarget:self];

                contact_view = [[UIView alloc] initWithFrame: CGRectMake(0, 45, 320, 415)];

                ggnumber_cell = [[UIPreferencesTextTableCell alloc] init];
                [ggnumber_cell setTitle: [NSString stringWithUTF8String: "Numer GG"]];
                [ggnumber_cell setEnabled:NO];
                ggnumber_field = [ggnumber_cell textField];

                alias_cell = [[UIPreferencesTextTableCell alloc] init];
                [alias_cell setTitle: [NSString stringWithUTF8String: "Wyświetlany"]];
                [alias_cell setEnabled:YES];
                alias_field = [alias_cell textField];

                firstname_cell = [[UIPreferencesTextTableCell alloc] init];
                [firstname_cell setTitle: [NSString stringWithUTF8String: "Imię"]];
                [firstname_cell setEnabled:YES];
                firstname_field = [firstname_cell textField];

                lastname_cell = [[UIPreferencesTextTableCell alloc] init];
                [lastname_cell setTitle: [NSString stringWithUTF8String: "Nazwisko"]];
                [lastname_cell setEnabled:YES];
                lastname_field = [lastname_cell textField];

                pref_table = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 415.0f)];
                [pref_table setDataSource:self];
                [pref_table setDelegate:self];
                [pref_table reloadData];

                [contact_view addSubview:pref_table];
                [self addSubview:top_bar];
                [self addSubview:cancel_button];
                [self addSubview:save_button];
                [self addSubview:contact_view];
		
		[ggnumber_field setText:[b getName]];
		[alias_field setText:[b getDisplayName]];
		NSLog([b getProfile]);
		profile = [[b getProfile] componentsSeparatedByString:@"||"];
		if([profile objectAtIndex:0] != nil )
		{
			[firstname_field setText:[profile objectAtIndex:0]];
		} else {
			[firstname_field setText:@""];
		}
		if([profile objectAtIndex:1] != nil )
		{
			[lastname_field setText:[profile objectAtIndex:1]];
		} else {
			[lastname_field setText:@""];
		}	
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
		if(button == save_button)
		{
			[self saveBuddy];
			[[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "" ] withTitle:[NSString stringWithUTF8String: "Kontakt został zmieniony!"]];
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
		return 1;
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
                        return ggnumber_cell;
                }
        }
        else if(group == 1)
        {
                if(row == 0)
                {
                        return alias_cell;
                }
                /*else if(row == 1) 
                {
                        return firstname_cell;
                }
		else if(row == 2)
		{
			return lastname_cell;
		}*/
        }
        else if(group == 2)
        {
                if(row == 0)
                {
                        return delete_button;
                }
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

- (void)saveBuddy
{
	NSString *nick = [alias_field text];
	NSString *firstname = [firstname_field text];
	NSString *lastname = [lastname_field text];
	NSString *ggnumber = [ggnumber_field text];
        [b setAlias:nick];
	//[b setProfile:[NSString stringWithFormat: @"%@||%@", firstname, lastname]];
	//PurpleAccount * pa = [[ApolloCore sharedInstance] getPurpleAccount:[b getOwner]]; 
	PurpleBuddy * purplebuddy = purple_find_buddy(account, [ggnumber UTF8String]);
	if (purplebuddy)
	{
		NSLog(@"Buddy znaleziony");
  		purple_blist_alias_buddy(purplebuddy,[nick UTF8String]);
      		serv_alias_buddy(purplebuddy);
      		purple_blist_schedule_save();
	}
	else
	{
		NSLog(@"Buddy nieznaleziony, dodaje");
		const char *groupUTF8String;
    		groupUTF8String = [@"Buddies" UTF8String]; 
		PurpleGroup *group;
    		if (!(group = purple_find_group(groupUTF8String)))
		{
			group = purple_group_new(groupUTF8String);
			purple_blist_add_group(group, NULL);
	  	}
    		purplebuddy = purple_buddy_new(account, [ggnumber UTF8String], NULL); 
    		purple_blist_add_buddy(purplebuddy, NULL, group, NULL);
    		purple_blist_alias_buddy(purplebuddy,[nick UTF8String]); 
    		purple_account_add_buddy(account, purplebuddy);
    		purple_blist_schedule_save();
	}
}

- (void)removeBuddy
{
	NSLog(@"Remove buddy");
	NSString *ggnumber = [ggnumber_field text];
	PurpleBuddy * purplebuddy = purple_find_buddy(account, [ggnumber UTF8String]);
	User * user = [[ApolloCore sharedInstance] getApolloUser:account];
	if (purplebuddy)
	{
		[user removeBuddyFromBuddyList:b];
 		purple_account_remove_buddy(account, purplebuddy, NULL);
		purple_blist_remove_buddy(purplebuddy);
    		purple_blist_schedule_save();
  	}
	[[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "" ] withTitle:[NSString stringWithUTF8String: "Kontakt został usunięty!"]];
	[[ViewController sharedInstance] transitionToBuddyListView];
  
}
@end

