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
#import "ArchiveView.h"
#import "ViewController.h"
#import "PurpleInterface.h"
#import "EyeCandy.h" 

@implementation ArchiveView

- (id) initWithFrame:(CGRect) aframe withBuddy:(Buddy *) buddy withAccount:(PurpleAccount *) account
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
		b = buddy;
		pa = account;

    float transparent[4] = {0.0, 0.0, 0.0, 0.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    top_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 59.0f)];
    [top_bar setImage:[UIImage applicationImageNamed: @"login_topnav_background.png"]];

    cancel_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
    [cancel_button setFrame:CGRectMake(5, 7.0, 75.0, 32.0)];
    [cancel_button setImage: [UIImage applicationImageNamed: @"back_up.png"] forState: 0];
    [cancel_button setImage: [UIImage applicationImageNamed: @"back_down.png"] forState: 1];
    [cancel_button addTarget:self action:@selector(buttonEvent:) forEvents:255];


    last_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
    [last_button setFrame:CGRectMake(320.0 - (50.0+5.0), 7.0, 50.0, 32.0)];
    [last_button setImage: [UIImage applicationImageNamed: @"archive_last_up.png"] forState: 0];
    [last_button setImage: [UIImage applicationImageNamed: @"archive_last_down.png"] forState: 1];
    [last_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
   
    next_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
    [next_button setFrame:CGRectMake(320.0 - (50+5+50+5), 7.0, 50.0, 32.0)];
    [next_button setImage: [UIImage applicationImageNamed: @"archive_next_up.png"] forState: 0];
    [next_button setImage: [UIImage applicationImageNamed: @"archive_next_down.png"] forState: 1];
    [next_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
    
    prev_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
    [prev_button setFrame:CGRectMake(320.0 - (50+5+50+5+50+5), 7.0, 50.0, 32.0)];
    [prev_button setImage: [UIImage applicationImageNamed: @"archive_prev_up.png"] forState: 0];
    [prev_button setImage: [UIImage applicationImageNamed: @"archive_prev_down.png"] forState: 1];
    [prev_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

    first_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
    [first_button setFrame:CGRectMake(320.0 - (50+5+50+5+50+5+50+5), 7.0, 50.0, 32.0)];
    [first_button setImage: [UIImage applicationImageNamed: @"archive_first_up.png"] forState: 0];
    [first_button setImage: [UIImage applicationImageNamed: @"archive_first_down.png"] forState: 1];
    [first_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

    
    NSString *accountName=[NSString stringWithUTF8String:purple_account_get_username(pa)];
    archivePath=[NSString stringWithFormat: @"%@/logs/gadu-gadu/%@/%@", PATH, accountName, [b getName]];
    NSLog(@"archivePath: %@",archivePath);

  	if(dirArray) [dirArray release];

  	NSFileManager* NSFm = [NSFileManager defaultManager];
  	dirArray = [NSFm directoryContentsAtPath: archivePath];
  	[dirArray retain];
  	int n = [dirArray count];

  	/*NSString* filename;
  	int i;
    for (i = 0; i < n; ++i)
  	{
  		filename = [dirArray objectAtIndex: i];
  		NSLog(@"dirArray File: %@",filename);
  	}*/
  	curArchiveFile=[dirArray count]-1;
 		NSLog(@"curArchiveFile: %d",curArchiveFile);
  	
  	NSString* contentString = [self getArchiveContent:curArchiveFile];
  	

	
    content_text = [[UITextView alloc] initWithFrame: CGRectMake(0, 45, 320, 415)];
		[content_text setTextSize: 12];
		[content_text setEditable: NO];
		[content_text setText: contentString];

    //[content_text setHTML: [NSString stringWithFormat:@"<div><font color=\"blue\">Sample Buddy HTMK %@ %d<br>Second line</font></div>", [b getName], 0]];
    //[content_text setHTML: [NSString stringWithFormat:@"<div><font color=\"blue\">Sample Buddy HTMK<br>Second line %@</font></div>", [b name]]];
		//[content_text scrollToEnd];
		//[content_text insertText:@""];		 
     


    //[contact_view addSubview:pref_table];
    [self addSubview:top_bar];
    [self addSubview:cancel_button];
    [self addSubview:last_button];
    [self addSubview:next_button];
    [self addSubview:prev_button];
    [self addSubview:first_button];



    //[self addSubview:contact_view];
    [self addSubview:content_text];

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
			[[ViewController sharedInstance] transitionToConversationWith: b];
		}
		else {
  		if(button == next_button) {if (curArchiveFile>0) curArchiveFile--;}
  		else if(button == prev_button) {if (curArchiveFile<[dirArray count]-1) curArchiveFile++;}
  		else if(button == first_button) curArchiveFile=[dirArray count]-1;
  		else if(button == last_button) curArchiveFile=0;
			NSString* contentString = [self getArchiveContent:curArchiveFile];
			[content_text setText: contentString];
  	}

	}
}




- (void)reloadData
{
  NSLog(@"ARCHIVE reloadData");  
}

- (NSString*) getArchiveContent:(int) index
{ 
  NSLog(@"getArchiveContent, index: %d", index);
  NSString *accountName=[NSString stringWithUTF8String:purple_account_get_username(pa)];
  archivePath=[NSString stringWithFormat: @"%@/logs/gadu-gadu/%@/%@", PATH, accountName, [b getName]];
  NSLog(@"archivePath: %@",archivePath);

  NSString	*fileName = [NSString stringWithFormat: @"%@/%@", archivePath, [dirArray objectAtIndex: index]];
  NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:fileName];
	NSData *contentData = [file readDataToEndOfFile];
  return  [[NSString alloc] initWithData: contentData encoding: NSUTF8StringEncoding];
}



@end

