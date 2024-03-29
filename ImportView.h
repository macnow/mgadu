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
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIBox.h>
#import <UIKit/UITextView.h>
#import <UIKit/UISwitchControl.h>

#include <libpurple/internal.h>
#include <libpurple/account.h>
#include <libpurple/conversation.h>
#include <libpurple/core.h>
#include <libpurple/debug.h>
#include <libpurple/eventloop.h>
#include <libpurple/ft.h>
#include <libpurple/log.h>
#include <libpurple/notify.h>
#include <libpurple/prefs.h>
#include <libpurple/prpl.h>
#include <libpurple/pounce.h>
#include <libpurple/savedstatuses.h>
#include <libpurple/sound.h>
#include <libpurple/status.h>
#include <libpurple/util.h>
#include <libpurple/whiteboard.h>
#include <libpurple/defines.h>

#import "AccountTypeSelector.h"
#import "User.h"
#import "EyeCandy.h" 

@interface ImportView : UIView
{
  EyeCandy *_eyeCandy; 
	id _delegate;

  PurpleAccount * account;
	UIPreferencesTable * pref_table;
  
  UIImageView * top_bar;
	UIPushButton * cancel_button;
	UIBox * bg_box;

	UIPreferencesTableCell * server_import_button;
	UIPreferencesTableCell * server_export_button;
	
	UIPreferencesTableCell * file_import_button;
	UIPreferencesTableCell * file_about_text;
	UIPreferencesTableCell * remove_all_button;
	
}

-(id) initWithFrame:(CGRect) aframe;
-(void) exportToServer:(id)param;
-(void) importFromServer:(id)param;
-(void) importFromServerFinished:(id)param;

-(void) importFromFile;
-(void) removeAllBuddies;
 


@end
