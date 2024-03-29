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

#import "LoginView.h"
#import "LoginCell.h"
#import "User.h"
#import "UserManager.h"
#import "BuddyListView.h"
#import "ViewController.h"
#import "EyeCandy.h" 


@implementation LoginView
/*
{
	UIImageView * top_bar;
	UIImageView * bottom_bar;
	UIPushButton * login_button;
	UIPushButton * done_button;
	UIPushButton * add_button;
	UITable * user_table;
}
*/

-(id) initWithFrame:(CGRect) aframe
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{	
		struct __GSFont * large_font = [NSClassFromString(@"WebFontCache") 
					createFontWithFamily:@"Helvetica" traits:0 size:14];
		float grey[4] = {0.47, 0.47, 0.47, 1.0};
		float dark_grey[4] = {0.34, 0.34, 0.34, 1.0};


		frame = CGRectMake(aframe.origin.x, aframe.origin.y, aframe.size.width, aframe.size.height);
		
		float transparent[4] = {0.0, 0.0, 0.0, 0.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		editing = NO;
		accounts = [[NSMutableArray alloc] init];
		
		UIImageView * bg = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, frame.size.height)];
		[bg setImage:[UIImage applicationImageNamed: @"login_background.png"]];

		top_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 59.0f)];
		[top_bar setImage:[UIImage applicationImageNamed: @"login_topnav_background.png"]];

		
		donate_label = [[UITextLabel alloc] initWithFrame: CGRectMake(10.0f, 314.0f, 300.0f, 90.0f)];
		[donate_label setText: [NSString stringWithUTF8String: "Jeśli chcesz wesprzeć finansowo autora i zmotywować go do dalszej pracy, wejdź na stronę: slyv.republika.pl. Za każdą złotówkę będę szalenie wdzięczny."]];
		[donate_label setFont:large_font];
		[donate_label setBackgroundColor: CGColorCreate(colorSpace, transparent)];
		[donate_label setColor: CGColorCreate(colorSpace, dark_grey)];
		[donate_label setWrapsText: YES];

		


		bottom_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, frame.size.height - 66.0f, 
										320.0f, 66.0f)];
		[bottom_bar setImage:[UIImage applicationImageNamed: @"login_bottomnav_background.png"]];

		
    
    
    login_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[login_button setFrame:CGRectMake(320.0 - 80.0, 7.0, 75.0, 32.0)];
		[login_button setImage: [UIImage applicationImageNamed: @"login_loginbutton_up.png"]
					forState: 0];
		[login_button setImage: [UIImage applicationImageNamed: @"login_loginbutton_down.png"]
					forState: 1];
		[login_button setImage: [UIImage applicationImageNamed: @"login_loginbutton_disabled.png"]
					forState: 2];
		[login_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
		[login_button becomeFirstResponder];



    options_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[options_button setFrame:CGRectMake(320.0 - 80.0 -7.0 - 80.0, 7.0, 75.0, 32.0)];
		[options_button setImage: [UIImage applicationImageNamed: @"options_up.png"]
					forState: 0];
		[options_button setImage: [UIImage applicationImageNamed: @"options_down.png"]
					forState: 1];
		[options_button setImage: [UIImage applicationImageNamed: @"options_disabled.png"]
					forState: 2];
		[options_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
		[options_button becomeFirstResponder];






		add_button = [[UIPushButton alloc] initWithFrame:CGRectMake((320.0/2.0), frame.size.height - (39.0f+10.0f), 
											101.0, 39.0)];
		[add_button setImage:[UIImage applicationImageNamed: @"login_addbutton_up.png"]
                                        forState: 0];
		[add_button setImage:[UIImage applicationImageNamed: @"login_addbutton_down.png"]
                                        forState: 1];
		[add_button setEnabled:YES];
		[add_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

		done_button = [[UIPushButton alloc] initWithFrame:CGRectMake(58, frame.size.height - (39.0f+10.0f), 
											102.0, 39.0)];
		[done_button setImage:[UIImage applicationImageNamed: @"login_editbutton_up.png"]
                                        forState: 0];
		[done_button setImage:[UIImage applicationImageNamed: @"login_editbutton_down.png"]
                                        forState: 1];
		[done_button setEnabled:YES];
		[done_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

		user_table = [[UITable alloc] initWithFrame: CGRectMake(0.0, 46.0, 
								320.0, frame.size.height-(46.0+64.0+100.0))];
		UITableColumn *col = [[UITableColumn alloc]
			initWithTitle: @"Account"
			identifier:@"account"
			width: 320.0 
		];
		[user_table addTableColumn: col];
		[user_table setSeparatorStyle: 0];
		[user_table setDelegate: self];
		[user_table setDataSource: self];
		[user_table setRowHeight: 58.0];
		[user_table setBackgroundColor: CGColorCreate(colorSpace, transparent)];

		[self reloadData];
		[user_table reloadData];

		[self addSubview: bg];
		[self addSubview: user_table];
		[self addSubview: top_bar];
		[self addSubview: donate_label];
		
		[self addSubview: bottom_bar];
		[self addSubview: login_button];
		[self addSubview: options_button];
		[self addSubview: add_button];
		[self addSubview: done_button];
		NSLog(@"Login View Init Complete");
	}
	return self;
}

- (void)tableRowSelected:(NSNotification *)notification
{
	if(editing)
	{
		User * u = [accounts objectAtIndex: [user_table selectedRow]];
		NSLog(@"%@/%@ clicked", [u getName], [u getProtocol]);
		[[ViewController sharedInstance] transitionToAccountEditViewWithUser:u];
	}
}

- (UIImageAndTextTableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col
{
	return (UIImageAndTextTableCell *)[cells objectAtIndex:row];
}

- (int)numberOfRowsInTable:(UITable *)table
{
	return [cells count];
}

- (void)reloadData
{
	// force the users to load
	accounts =[[[UserManager sharedInstance] getUsers] copy];
	
	// Make the cells
	cells = [[NSMutableArray alloc] init];

	int i = 0;
	for(i; i<[accounts count]; i++)
	{
		LoginCell * lc = [[LoginCell alloc] initWithUser:[accounts objectAtIndex:i]
							forLoginView:self];
		[cells addObject:lc];
	}

	[user_table reloadData];
				
	[done_button setImage:[UIImage applicationImageNamed: @"login_editbutton_up.png"]
				forState: 0];
	[done_button setImage:[UIImage applicationImageNamed: @"login_editbutton_down.png"]
				forState: 1];
	[login_button setEnabled:YES];
	[options_button setEnabled:YES];
	
	editing = NO;
}

-(void) loginButton:(id)param
{
	BOOL login_success = [[UserManager sharedInstance] loginAll];
	[_eyeCandy hideProgressHUD];
	if(login_success)
		[[ViewController sharedInstance] transitionToBuddyListView];
	else
		[[ViewController sharedInstance] showError: 
			@"You must have at lease one account set to active"];
}

- (void) buttonEvent:(UIPushButton *)button 
{
	if (![button isPressed] && [button isHighlighted])
	{
		if(button == done_button)
		{
			[self setIsEditing:editing];
		}
		else if(button == login_button)
		{
    	_eyeCandy = [[[EyeCandy alloc] init] retain];
      [_eyeCandy showProgressHUD:[NSString stringWithUTF8String: "Nawiązywanie połączenia z Internetem..." ] withWindow:[_delegate getWindow] withView:[ViewController sharedInstance] withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
      [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(loginButton:) userInfo:nil repeats:NO];
		}
		else if(button == options_button)
		{
		  NSLog(@"Transition to Prefs");
    	[[ViewController sharedInstance] transitionToPrefsView];
		}
		else if(button == add_button)
		{
			[[ViewController sharedInstance] transitionToAccountEditView];
		}
  }
}






-(void) setIsEditing:(BOOL)is_editing
{
	if(!is_editing)
	{
		[done_button setImage:[UIImage applicationImageNamed: @"login_donebutton_up.png"]
        		     	        forState: 0];
		[done_button setImage:[UIImage applicationImageNamed: @"login_donebutton_down.png"]
        		     	        forState: 1];
		[login_button setEnabled:NO];
		[options_button setEnabled:NO];
				
		editing = YES;
	}
	else
	{
		[self reloadData];
	}

	int i = 0;
	for(i; i<[cells count]; i++)
		[[cells objectAtIndex:i] setEditing:editing];
}

-(void) setDeleting:(BOOL) is_del fromCell:(LoginCell *) from_cell
{
	editing = !is_del;

	int i = 0;
	for(i; i<[cells count]; i++)
	{
		if([cells objectAtIndex:i] != from_cell)
			[[cells objectAtIndex:i] setEnabled:!from_cell];
	}
}

@end
