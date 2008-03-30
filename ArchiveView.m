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
    [cancel_button setImage: [UIImage applicationImageNamed: @"back_up.png"]
                            forState: 0];
    [cancel_button setImage: [UIImage applicationImageNamed: @"back_down.png"]
                            forState: 1];
    [cancel_button addTarget:self action:@selector(buttonEvent:) forEvents:255];


    //PurpleLog * archive=purple_account_get_log(pa, false);
    //char * str=purple_log_read();[archive UTF8String]);
    //int logSize=purple_log_get_size(archive);
    
    
    NSString *accountName=[NSString stringWithUTF8String:purple_account_get_username(pa)];
    NSLog(@"accountName: %@",accountName);
    
    archivePath=[NSString stringWithFormat: @"%@/logs/gadu-gadu/%@/%@", PATH, accountName, [b getName]];
    NSLog(@"archivePath: %@",archivePath);

  	NSFileManager* NSFm = [NSFileManager defaultManager];
  	dirArray = [NSFm directoryContentsAtPath: archivePath];
  	//int n = [dirArray count];

  	/*NSString* filename;
  	int i;
    for (i = 0; i < n; ++i)
  	{
  		filename = [dirArray objectAtIndex: i];
  		NSLog(@"dirArray File: %@",filename);
  	}*/
  	curArchiveFile=[dirArray count]-1;
  	
  	NSString	*fileName = [NSString stringWithFormat: @"%@/%@", archivePath, [dirArray objectAtIndex: curArchiveFile]];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:fileName];
  	NSData *contentData = [file readDataToEndOfFile];
  	NSString* contentString = [[NSString alloc] initWithData: contentData encoding: NSUTF8StringEncoding]; 
  	



    /*NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* dirEnumerator = [fm enumeratorAtPath: archivePath];
  	NSString* filename;
  	while (filename = [dirEnumerator nextObject])
  	{
  		[dirEnumerator skipDescendents];
      NSLog(@"enumerator File: %@",filename);
  		
  	}*/
	
	
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
	}
}




- (void)reloadData
{
  NSLog(@"ARCHIVE reloadData");  
}

- (NSString*) loadArchiveFile:(NSString *) filename
{ 
  FILE *file;
  char buffer[262144], buf[1024];
  file = fopen(filename, "r");
  if (file) {
    buffer[0] = 0;
    while((fgets(buf, sizeof(buf), file))!=NULL) {
      strlcat(buffer, buf, sizeof(buffer));
    }
    fclose(file);
    return [[ NSString alloc ] initWithCString: buffer];
  } else {
    return nil;
  }

}



@end

