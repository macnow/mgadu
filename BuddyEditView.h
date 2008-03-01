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

#import "EyeCandy.h" 

@interface BuddyEditView : UIView
{
  EyeCandy *_eyeCandy; 
	id _delegate;

  PurpleAccount * account;
        UIImageView * top_bar;
        UIPushButton * cancel_button;
        UIPushButton * save_button;

        // View for editing
        UIView * contact_view;
        UIPreferencesTable * pref_table;
        UITextField * pseudo_field;
        UITextField * firstname_field;
        UITextField * lastname_field;
        UITextField * alias_field;
        UITextField * ggnumber_field;
        UITextField * email_field;
        UITextField * phone_field;
        UITextField * mobile_field;

        UIPreferencesTextTableCell * pseudo_cell;
        UIPreferencesTextTableCell * firstname_cell;
        UIPreferencesTextTableCell * lastname_cell;
        UIPreferencesTextTableCell * alias_cell;
        UIPreferencesTextTableCell * ggnumber_cell;
        UIPreferencesTextTableCell * email_cell;
        UIPreferencesTextTableCell * phone_cell;
        UIPreferencesTextTableCell * mobile_cell;
}

-(id) initWithFrame:(CGRect) aframe;
-(void) addNewBuddy;

@end
