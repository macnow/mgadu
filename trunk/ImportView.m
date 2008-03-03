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
#include <glib.h>
#include <string.h>
#include <unistd.h>

#import "ApolloCore.h"
#import "ImportView.h"
#import "ViewController.h"
#import "PurpleInterface.h"
#import "EyeCandy.h" 

static void plugin_server_import_cb (PurplePluginAction * action)
{
	/*purple_notify_message (helloworld_plugin, PURPLE_NOTIFY_MSG_INFO,
		"Plugin Actions Test", "This is a plugin actions test :)", NULL, NULL,
		NULL);*/
		NSLog(@"SLYV CALLBACK");
} 

static void plugin_server_import_userdata_cb (PurplePluginAction * action)
{
	/*purple_notify_message (helloworld_plugin, PURPLE_NOTIFY_MSG_INFO,
		"Plugin Actions Test", "This is a plugin actions test :)", NULL, NULL,
		NULL);*/
		NSLog(@"SLYV CALLBACK USERDATA");
} 


@implementation ImportView

-(id) initWithFrame:(CGRect) aframe withAccount:(PurpleAccount *) pa 
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
	  account=pa;
		bg_box = [[UIBox alloc] initWithFrame:aframe];

		top_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 59.0f)];
                [top_bar setImage:[UIImage applicationImageNamed: @"login_topnav_background.png"]];

		cancel_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
                [cancel_button setFrame:CGRectMake(5.0, 7.0, 84.0, 32.0)];
                [cancel_button setImage: [UIImage applicationImageNamed: @"chat_buddybutton_up.png"]
                                        forState: 0];
                [cancel_button setImage: [UIImage applicationImageNamed: @"chat_buddybutton_down.png"]
                                        forState: 1];
		[cancel_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
		
		
		server_import_button = [[UIPreferencesTableCell alloc] init];
		[server_import_button setTitle: [NSString stringWithUTF8String: "Importuj kontakty z serwera"]];
		[server_import_button setTarget:self];

				
		server_export_button = [[UIPreferencesTableCell alloc] init];
		[server_export_button setTitle: [NSString stringWithUTF8String: "Eksportuj kontakty na serwer"]];
		[server_export_button setTarget:self];


		file_import_button = [[UIPreferencesTableCell alloc] init];
		[file_import_button setTitle: [NSString stringWithUTF8String: "Importuj listę kontaktów z pliku"]];
		[file_import_button setTarget:self];

    file_about_text = [[UIPreferencesTableCell alloc]  init];
    [file_about_text setTitle:[NSString stringWithUTF8String: "Najpierw wykonaj eksport kontaktów w gadugadu do pliku gadugadu.txt, a następnie wgraj go do katalogu /var/mobile/Library/mGadu/ (jeśli masz 1.1.3) lub /var/root/Library/mGadu/ (jeśli 1.1.2) w iPhonie." ]];
    [file_about_text _setDrawAsLabel: YES];
    [file_about_text setDrawsBackground: NO];

		remove_all_button = [[UIPreferencesTableCell alloc] init];
		[remove_all_button setTitle: [NSString stringWithUTF8String: "Usuń wszystkie kontakty"]];
		[remove_all_button setTarget:self];


		pref_table = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 45.0f, 320.0f, 415.0f)];
		[pref_table setDataSource:self];
		[pref_table setDelegate:self];
		[pref_table reloadData];
    
    //[self addSubview:server_import_button];
		[self addSubview:bg_box];
		[bg_box addSubview:pref_table];
		[self addSubview:top_bar];
		[self addSubview:cancel_button];
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
	return 5;
}

-(int) preferencesTable:(UIPreferencesTable *)aTable numberOfRowsInGroup:(int)group
{
		return 1;
}

-(UIPreferencesTableCell *) preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group
{
	UIPreferencesTableCell * cell = [[UIPreferencesTableCell alloc] init];
	return [cell autorelease];
}

-(float) preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed
{
    switch (group) {
    case 0:
      if (row == -1) return 20;  // server import - top margin
      return proposed;
    case 1:
      if (row == -1) return 20;  // server export - top margin
      return proposed;
    case 2:
      if (row == -1) return 20;  // file import - top margin
      return proposed;
    case 3:
      if (row == -1) return 5;  // text - top margin
      return 100;          // text - height
    case 4:
      if (row == -1) return 20;  // remove all - top margin
      return proposed;
    default:
      if (row == -1) return 5;  /* group label - empty space height*/
      return proposed;
  }}

-(BOOL) preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group
{
	return;
}

-(UIPreferencesTextTableCell *) preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group
{
  switch(group) {
    case 0:
      switch(row) {
				case 0: return server_import_button;
			}
    case 1:
      switch(row) {
				case 0: return server_export_button;
			}
    case 2:
      return file_import_button;
    case 3:
      return file_about_text;
    case 4:
      return remove_all_button;
  }
}

- (void)tableRowSelected:(NSNotification *)notification
{
  switch ([pref_table selectedRow]) {
    case 1:
      _eyeCandy = [[[EyeCandy alloc] init] retain];
      [_eyeCandy showProgressHUD:[NSString stringWithUTF8String: "Trwa import kontaktów z serwera..." ] withWindow:[_delegate getWindow] withView:[ViewController sharedInstance] withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
      [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(importFromServer:) userInfo:nil repeats:NO];
      break;
    case 3:
      _eyeCandy = [[[EyeCandy alloc] init] retain];
      [_eyeCandy showProgressHUD:[NSString stringWithUTF8String: "Trwa eksport kontaktów na serwer..." ] withWindow:[_delegate getWindow] withView:[ViewController sharedInstance] withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
      [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(exportToServer:) userInfo:nil repeats:NO];
      break;
    case 5:
      [self importFromFile];
      break;
    case 9:
      [self removeAllBuddies];
      break;
  }


	/*if([pref_table selectedRow] == 7)
	{
		// delete the user
		[[UserManager sharedInstance] removeUser:last_user_editing];
		
		[[ViewController sharedInstance] transitionToLoginViewWithEditActive:YES];
	}*/
}

-(void) importFromServerFinished:(id)param
{
  [_eyeCandy hideProgressHUD];
  purple_blist_schedule_save();
  [[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "" ] withTitle:[NSString stringWithUTF8String: "Import kontaktów z serwera zakończony"]];
  [[ViewController sharedInstance] transitionToBuddyListView];
}

-(void) importFromServer:(id)param
{
  NSLog(@"server import");
  //PurpleAccount
  PurplePlugin *plugin = purple_account_get_connection(account)->prpl;
  
  if (PURPLE_PLUGIN_HAS_ACTIONS(plugin)) { 
  	GList	*l, *actions;
  	actions = PURPLE_PLUGIN_ACTIONS(plugin, purple_account_get_connection(account));
  
  	//Avoid adding separators between nonexistant items (i.e. items which Purple shows but we don't)
  	BOOL	addedAnAction = NO;
  	for (l = actions; l; l = l->next) {
  		if (l->data) {
  			PurplePluginAction	*action;
  			NSDictionary		*dict;
  			NSString			*title;
  			action = (PurplePluginAction *) l->data;
  			title=[NSString stringWithUTF8String:action->label];
  			if ([title isEqualToString:@"Download buddylist from Server"]) {
  		    NSLog(@"SLYV ACTION: %@", title);
      		PurplePluginAction *act = purple_plugin_action_new(NULL, action->callback);
      		if (act->callback) {
      			act->plugin = purple_account_get_connection(account)->prpl;
      			act->context = purple_account_get_connection(account);
      			act->callback(act);
      		} else {
  			    [[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "Spróbuj ponownie za chwilę" ] withTitle:[NSString stringWithUTF8String: "Błąd podczas importu"]];
          }
  			}
  			purple_plugin_action_free(action);
  		}
  	}
  	g_list_free(actions);
  }	
  [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(importFromServerFinished:) userInfo:nil repeats:NO];

}


-(void) exportToServerFinished:(id)param
{
  [_eyeCandy hideProgressHUD];
  purple_blist_schedule_save();
  [[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "" ] withTitle:[NSString stringWithUTF8String: "Eksport kontaktów na serwer zakończony"]];
  [[ViewController sharedInstance] transitionToBuddyListView];
}

-(void) exportToServer:(id)param
{
  NSLog(@"server export");
  //PurpleAccount
  PurplePlugin *plugin = purple_account_get_connection(account)->prpl;
  
  if (PURPLE_PLUGIN_HAS_ACTIONS(plugin)) { 
  	GList	*l, *actions;
  	actions = PURPLE_PLUGIN_ACTIONS(plugin, purple_account_get_connection(account));
  
  	//Avoid adding separators between nonexistant items (i.e. items which Purple shows but we don't)
  	BOOL	addedAnAction = NO;
  	for (l = actions; l; l = l->next) {
  		if (l->data) {
  			PurplePluginAction	*action;
  			NSDictionary		*dict;
  			NSString			*title;
  			action = (PurplePluginAction *) l->data;
  			title=[NSString stringWithUTF8String:action->label];
  			if ([title isEqualToString:@"Upload buddylist to Server"]) {
  		    NSLog(@"SLYV ACTION: %@", title);
      		PurplePluginAction *act = purple_plugin_action_new(NULL, action->callback);
      		if (act->callback) {
      			act->plugin = purple_account_get_connection(account)->prpl;
      			act->context = purple_account_get_connection(account);
      			act->callback(act);
      		} else {
  			    [[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "Spróbuj ponownie za chwilę" ] withTitle:[NSString stringWithUTF8String: "Błąd podczas eksportu"]];
          }
  			}
  			purple_plugin_action_free(action);
  		}
  	}
  	g_list_free(actions);
  }	
  [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(exportToServerFinished:) userInfo:nil repeats:NO];

}



-(void) importFromFile
{
  NSLog(@"file import 2");

    //NSLog(@"IMPORING GG CONTACTS %@", GG_CONTACTS);
    // assuming data is in WindowsCP1250
    NSString *contents = [[NSMutableString alloc] initWithContentsOfFile:GG_CONTACTS encoding: NSWindowsCP1250StringEncoding error:NULL];
    NSArray *lines = [contents componentsSeparatedByString:@"\n"];
    NSString *line;
    User	* user			=	[[ApolloCore sharedInstance]  getApolloUser:account]; 
  	Buddy * theBuddy;
  	int i=0;
  	//if ([lines count]>30) i=[lines count]-30;


		//create group "Buddies"
		PurpleGroup	*group;
		PurpleBuddy	*buddy; 
		const char	*groupUTF8String, *buddyUTF8String, *aliasUTF8String;
    groupUTF8String = "Buddies"; 
    PurpleAccount * pa = [[ApolloCore sharedInstance] getPurpleAccount:user];
		if (!(group = purple_find_group(groupUTF8String))) {
		  group = purple_group_new(groupUTF8String);
		  purple_blist_add_group(group, NULL);
		  NSLog(@"SLYV group buddies created");
	  } else {
      NSLog(@"SLYV group buddies already exists");
    }
    
    for (i=0; i < [lines count]; i++)
    {
      line=[lines objectAtIndex:i];
      NSArray *columns = [line componentsSeparatedByString:@";"];
      if ([columns count]>=6) {
        //sleep(1);
        NSString *nick=[columns objectAtIndex:3];
        NSString *ggnumber=[columns objectAtIndex:6];
        if ([ggnumber length]) {
	        buddyUTF8String = [ggnumber UTF8String]; 
	        aliasUTF8String = [nick UTF8String]; 
	        buddy = purple_find_buddy(pa, buddyUTF8String);
          if (!buddy) {
            //SlyvLog(@"SLYV buddy CREATE1 %@ %@!!", ggnumber, nick);
            NSLog(@"SLYV buddy CREATE1 %@ %@!!", ggnumber, nick);
            buddy = purple_buddy_new(pa, buddyUTF8String, NULL); 
            purple_blist_add_buddy(buddy, NULL, group, NULL);
	          purple_blist_alias_buddy(buddy,aliasUTF8String); 
	          purple_account_add_buddy(pa, buddy);
          } else {
            //SlyvLog(@"SLYV buddy found %@  %@!!", ggnumber, nick);
            NSLog(@"SLYV buddy found %@  %@!!", ggnumber, nick);
          }

          //NSLog(@"CREATE BUDDY %@: %@",nick,ggnumber);
          theBuddy = [[Buddy alloc] initWithName:ggnumber andGroup:@"" andOwner:user];
        	[theBuddy setStatusMessage:@" "];
        	[theBuddy setOnline:NO];
        	[theBuddy setAlias:nick];
          [user addBuddyToBuddyList: theBuddy];
  
        }
      }
    }
  [[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "" ] withTitle:[NSString stringWithUTF8String: "Import kontaktów z pliku zakończony"]];
  [[ViewController sharedInstance] transitionToBuddyListView];
  return;

}

-(void) removeAllBuddies
{
  NSLog(@"removeAllBuddies");
  User	* user			=	[[ApolloCore sharedInstance]  getApolloUser:account]; 
  //PurpleAccount * pa = [[ApolloCore sharedInstance] getPurpleAccount:user];
  NSArray * b = [user getBuddyList];
	NSLog(@"%@ contain %i buddies.", [user getName], [b count]);
	int j=0;
	for(j; j<[b count]; j++)
	{
		Buddy * buddy = [b objectAtIndex:j];
		NSLog(@"%@ isOnline=%d removed", [buddy getName]);
		PurpleBuddy *purple_buddy = purple_find_buddy(account,  [[buddy getName] UTF8String]); 
	  if (purple_buddy) {
  	  purple_account_remove_buddy(account, purple_buddy, NULL);
      purple_blist_remove_buddy(purple_buddy);
	 	}
	}
	[user removeAllBuddies];
	purple_blist_schedule_save();
  [[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "" ] withTitle:[NSString stringWithUTF8String: "Wszystkie kontakty zostały usunięte"]];
  [[ViewController sharedInstance] transitionToBuddyListView];

  //[[ViewController sharedInstance] showMessage: [NSString stringWithUTF8String: "Wróc do listy kontaktów" ] withTitle:[NSString stringWithUTF8String: "Import kontaktów z pliku zakończony"]];
  //[[ViewController sharedInstance] transitionToBuddyListView];
}


@end
