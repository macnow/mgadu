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
#import <UIKit/UISectionList.h>
#import <UIKit/UITable.h>

#import "User.h"

@interface BuddyListView : UIView 
{
	UIImageView * top_bar;
	UIPushButton * logout_button;
	UIPushButton * status_button;
	UIPushButton * add_button;
	UIPushButton * import_button;

	UITable * buddy_table;
	UISectionList * buddy_list;

	NSMutableArray * buddies;
	NSMutableDictionary * cells;
	CGRect frame;
	NSMutableArray * user_names;
	NSMutableArray * user_rows;

	BOOL is_away;
	BOOL is_invisible;
	int user_count;

	BOOL needs_refreshing;
}

-(id) initWithFrame:(CGRect) frame;

- (void)tableRowSelected:(NSNotification *)notification;
- (UIImageAndTextTableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col;
- (int)numberOfRowsInTable:(UITable *)table;
- (void)reloadData;
- (void)refreshTable;

@end
