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
#import "BuddyListView.h"
#import "BuddyCell.h"
#import "User.h"
#import "UserManager.h"
#import "ViewController.h"
#import "ProtocolManager.h"
#import "Event.h"

#include "CONST.h"

@implementation BuddyListView
/*
{
	UIImageView * top_bar;
	UIImageView * bottom_bar;
	UIPushButton * login_button;
	UIPushButton * edit_button;
	UIPushButton * done_button;
	UIPushButton * add_button;
	UITable * user_table;
}
*/

-(id) initWithFrame:(CGRect) aframe
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
		is_away = NO;
		is_invisible = NO;
		user_count = 0;

		frame = CGRectMake(aframe.origin.x, aframe.origin.y, aframe.size.width, aframe.size.height);
		
		float transparent[4] = {0.0, 0.0, 0.0, 0.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		cells = [[NSMutableDictionary alloc] init];
		buddies = [[NSMutableArray alloc] init];
		user_names = [[NSMutableArray alloc] init];
		user_rows = [[NSMutableArray alloc] init];
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, frame.size.height)];
		[bg setImage:[UIImage applicationImageNamed: @"login_background.png"]];

		top_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
		[top_bar setImage:[UIImage applicationImageNamed: @"buddy_topnav_background2.png"]];

		logout_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[logout_button setFrame:CGRectMake(5.0, 7.0, 66.0, 32.0)];
		[logout_button setImage: [UIImage applicationImageNamed: @"buddy_logoutbutton_up.png"]
					forState: 0];
		[logout_button setImage: [UIImage applicationImageNamed: @"buddy_logoutbutton_down.png"]
					forState: 1];
		[logout_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
		[logout_button becomeFirstResponder];



		add_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[add_button setFrame:CGRectMake((320.0 - ( 7.0 + 7.0 + 64.0 )), 7.0f, 32.0f, 32.0f)];
		[add_button setImage:[UIImage applicationImageNamed: @"buddy_addbutton_up.png"]
                                        forState: 0];
		[add_button setImage:[UIImage applicationImageNamed: @"buddy_addbutton_down.png"]
                                        forState: 1];
		[add_button setEnabled:YES];
		[add_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
		


		edit_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[edit_button setFrame:CGRectMake((320.0 - ( 7.0 + 7.0 + 7.0 + 96.0 )), 7.0f, 32.0f, 32.0f)];
		[edit_button setImage: [UIImage applicationImageNamed: @"buddy_editbutton_up.png"]
					forState: 0];
		[edit_button setImage: [UIImage applicationImageNamed: @"buddy_editbutton_down.png"]
					forState: 1];
		[edit_button addTarget:self action:@selector(buttonEvent:) forEvents:255];




		import_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[import_button setFrame:CGRectMake((320.0 - ( 7.0 + 7.0 + 7.0 + 7.0 + 128.0 )), 7.0f, 32.0f, 32.0f)];
		[import_button setImage:[UIImage applicationImageNamed: @"buddies_import_up.png"]
                                        forState: 0];
		[import_button setImage:[UIImage applicationImageNamed: @"buddies_import_down.png"]
                                        forState: 1];
		[import_button setEnabled:YES];
		[import_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
		
		
		

		status_button = [[UIPushButton alloc] initWithFrame:CGRectMake((320.0 - (7.0+32.0)), 7.0f, 
											32.0, 32.0)];
		//status_button = [[UIPushButton alloc] initWithFrame:CGRectMake((320.0 - (2*7.0+2*32.0)), 7.0f, 
		//								32.0, 32.0)];
		[status_button setImage:[UIImage applicationImageNamed: @"buddy_onlinebutton_up.png"]
                                        forState: 0];
		[status_button setImage:[UIImage applicationImageNamed: @"buddy_onlinebutton_down.png"]
                                        forState: 1];
		[status_button setEnabled:YES];
		[status_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

		buddy_list = [[UISectionList alloc] initWithFrame: CGRectMake(0.0, 46.0, 
							320.0, frame.size.height-(46.0))
							showSectionIndex:NO];
		[buddy_list setDataSource:self];
		[buddy_list reloadData];

		buddy_table = [buddy_list table];
		UITableColumn *col = [[UITableColumn alloc]
			initWithTitle: @"Buddy"
			identifier:@"buddy"
			width: 320.0 
		];
		[buddy_table addTableColumn: col];
		[buddy_table setSeparatorStyle: 1];
		[buddy_table setDelegate: self];
		//[buddy_table setDataSource: self];
		[buddy_table setRowHeight: 39.0];

		[self addSubview: bg];
		[self addSubview: buddy_list];
		[self addSubview: top_bar];
		[self addSubview: logout_button];
		[self addSubview: edit_button];
		[self addSubview: add_button];
		[self addSubview: import_button];
		[self addSubview: status_button];

		[self reloadData];
		[self refreshTable];

		[[ProtocolManager sharedInstance] registerForAllEvents:self];

		NSLog(@"Buddy View Init Complete");
	}
	return self;
}


- (int)numberOfSectionsInSectionList:(UISectionList *)aSectionList 
{
	return [user_names count];
}
        
- (NSString *)sectionList:(UISectionList *)aSectionList titleForSection:(int)section 
{
        return [user_names objectAtIndex:section];
}       
        
- (int)sectionList:(UISectionList *)aSectionList rowForSection:(int)section 
{
        return [[user_rows objectAtIndex:section] intValue];
}

- (void)tableRowSelected:(NSNotification *)notification
{
	Buddy * b = [buddies objectAtIndex: [buddy_table selectedRow]];
	if(editing)
	{
		PurpleAccount * pa;
  		NSArray * users = [[UserManager sharedInstance]	getUsers];
    		int i = 0;
    		for(i; i<[users count]; i++)
    		{
	   		User * u = [users objectAtIndex:i];
    			if([u isActive])
			{
			          pa = [[ApolloCore sharedInstance] getPurpleAccount:u];
			          break;
        		}
	  	}
		[[ViewController sharedInstance] transitionToBuddyEditView:b:pa];
		NSLog(@"%@ clicked, Editing", [b getName]);
	}
	else
	{
		[[ViewController sharedInstance] transitionToConversationWith:b];
		NSLog(@"%@ clicked, Transitioning", [b getName]);
	}

	[self refreshTable];
}

- (UIImageAndTextTableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col
{
	Buddy * b = [buddies objectAtIndex:row];

	/*NSString * key = [NSString stringWithFormat:@"%@/%@/%@",
				[b getName], 
				[[b getOwner] getName], 
				[[b getOwner] getProtocol]];*/
				
	NSString * key = [b getID];
				
	BuddyCell * cell = [cells objectForKey: key];

	if(cell == nil)
	{
		cell = [[BuddyCell alloc] initWithBuddy:b];
		[cells setObject:cell forKey:key];
	}

	[cell reloadData];

	return cell;
}

- (int)numberOfRowsInTable:(UITable *)table
{
	return [buddies count];
}

- (void)refreshTable
{
	[buddy_list reloadData];
}

- (void)reloadData
{
	NSLog(@"SLYV Reloading buddy list");
	[buddies removeAllObjects];
	[user_names removeAllObjects];
	[user_rows removeAllObjects];
	user_count = 0;
	NSArray * users = [[UserManager sharedInstance]	getUsers];
	int row_count = 0;

	int i = 0;
	for(i; i<[users count]; i++)
	{
		User * u = [users objectAtIndex:i];

    NSArray * b = [u getBuddyList];
		if([u isActive])
		{
			user_count ++;
			[user_names addObject:[u getID]];
			[user_rows addObject: [NSNumber numberWithInt:row_count]];
			//NSLog(@"%@ contain %i buddies.", [u getName], [b count]);

			int j=0;
			for(j; j<[b count]; j++)
			{
				row_count ++;
				Buddy * buddy = [b objectAtIndex:j];
				//NSLog(@"%@ isOnline=%d conversationExists=%d", [buddy getName], [buddy isOnline], [[ViewController sharedInstance] conversationWithBuddyExists: buddy]);
				//if([buddy isOnline] || [[ViewController sharedInstance] conversationWithBuddyExists: buddy]) {
				  if ([buddy isOnline])
					 [buddies addObject:buddy];
				//}
			}
			j=0;
			for(j; j<[b count]; j++)
			{
				row_count ++;
				Buddy * buddy = [b objectAtIndex:j];
				//NSLog(@"%@ isOnline=%d conversationExists=%d", [buddy getName], [buddy isOnline], [[ViewController sharedInstance] conversationWithBuddyExists: buddy]);
				//if([buddy isOnline] || [[ViewController sharedInstance] conversationWithBuddyExists: buddy]) {
				  if (![buddy isOnline])
					 [buddies addObject:buddy];
				//}
			}
		}

	}

	[self refreshTable];
}



- (void) buttonEvent:(UIPushButton *)button 
{
	if (![button isPressed] && [button isHighlighted])
	{
		if(button == logout_button)
		{
			BOOL success = [[UserManager sharedInstance] logoutAll];
			[[ViewController sharedInstance] transitionToLoginView];
		}
		else if(button == edit_button)
		{
			[self setIsEditing:editing];
		}
		else if(button == status_button)
		{
			if(is_away)
			{
				[status_button setImage:[UIImage 
					applicationImageNamed: @"buddy_onlinebutton_up.png"]
                                        forState: 0];
				[status_button setImage:[UIImage 
					applicationImageNamed: @"buddy_onlinebutton_down.png"]
                                        forState: 1];
				is_away = NO;
			}
			else if(is_invisible)
			{
				[status_button setImage:[UIImage 
					applicationImageNamed: @"buddy_awaybutton_up.png"]
                                        forState: 0];
				[status_button setImage:[UIImage 
					applicationImageNamed: @"buddy_awaybutton_down.png"]
                                        forState: 1];
				is_away = YES;
				is_invisible = NO;
			}
			else
			{
				[status_button setImage:[UIImage 
					applicationImageNamed: @"buddy_invisiblebutton_up.png"]
                                        forState: 0];
				[status_button setImage:[UIImage 
					applicationImageNamed: @"buddy_invisiblebutton_down.png"]
                                        forState: 1];
				is_invisible = YES;
			}
      			
			NSArray * users = [[UserManager sharedInstance] getUsers];
			int i = 0;
			for(i; i<[users count]; i++)
			{
				[[users objectAtIndex:i] setAway: is_away];
				[[users objectAtIndex:i] setInvisible: is_invisible];
			}
		}
		else if(button == add_button)
		{
			PurpleAccount * pa;
  			NSArray * users = [[UserManager sharedInstance]	getUsers];
    			int i = 0;
    			for(i; i<[users count]; i++)
    			{
		    		User * u = [users objectAtIndex:i];
    				if([u isActive])
				{
				          pa = [[ApolloCore sharedInstance] getPurpleAccount:u];
				          break;
        			}
		  	}
			[[ViewController sharedInstance] transitionToBuddyAddView:pa];
		}
		else if(button == import_button)
		{
		  PurpleAccount * pa;
  		NSArray * users = [[UserManager sharedInstance]	getUsers];
  		
    	int i = 0;
    	for(i; i<[users count]; i++)
    	{
    		User * u = [users objectAtIndex:i];
    		if([u isActive]) {
          pa = [[ApolloCore sharedInstance] getPurpleAccount:u];
          break;
        }
		  }
				
			[[ViewController sharedInstance] transitionToImportView: pa];
		}
	}
}
-(void) setIsEditing:(BOOL)is_editing
{
        if(!is_editing)
        {
                [edit_button setImage:[UIImage applicationImageNamed: @"buddy_editbutton_down.png"] forState: 0];
                [edit_button setImage:[UIImage applicationImageNamed: @"buddy_editbutton_up.png"] forState: 1];
                [logout_button setEnabled:NO];
                [import_button setEnabled:NO];
                [add_button setEnabled:NO];
                [status_button setEnabled:NO];
                editing = YES;
        }
        else
        {
        	[edit_button setImage:[UIImage applicationImageNamed: @"buddy_editbutton_up.png"] forState: 0];
       		[edit_button setImage:[UIImage applicationImageNamed: @"buddy_editbutton_down.png"] forState: 1];
                [logout_button setEnabled:YES];
                [import_button setEnabled:YES];
                [add_button setEnabled:YES];
                [status_button setEnabled:YES];
        	editing = NO;
                [self reloadData];
        }

	NSEnumerator * enumerator = [cells objectEnumerator];
	NSObject * obj;
	while ((obj = [enumerator nextObject]) != nil)
	{
		[obj setEditing:editing];
	}
}


-(void) respondToEvent:(Event *) event
{
  NSLog(@"buddylistview RESPOND TO EVENT");
	switch([event getType])
	{
		case BUDDY_LOGIN:
			[self reloadData];
		case BUDDY_LOGOUT:
			[self reloadData];
			break;
		case BUDDY_AWAY:
			[self refreshTable];
		case BUDDY_BACK:
			[self refreshTable];
		case BUDDY_IDLE:
			[self refreshTable];
			break;
		case BUDDY_MESSAGE:							
			[self reloadData];
			[self refreshTable];
			break;
		case BUDDY_STATUS:
			[self refreshTable];
			[self reloadData];
			break;
		case DISCONNECT:
			[cells release];
			cells = [[NSMutableDictionary alloc] init];
			[buddies release];
			buddies = [[NSMutableArray alloc]init];
//			[self reloadData];
//			[self refreshTable];					
			break;
		default:
			break;
	}
}

@end
