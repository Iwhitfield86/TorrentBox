//
//  SettingsViewController.h
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBUploader.h"

#define SECTION_DB_CRED			0
#define SECTION_DB_ACTIONS		1
#define SECTION_SETTINGS		2
#define SECTION_INFO			3

#define ROW_DB_CRED_EMAIL		0
#define ROW_DB_CRED_PASS		1

#define ROW_DB_ACTIONS_AUTH		0

#define ROW_SETTINGS_AUTO		0

#define ROW_INFO_VERSION		0
#define ROW_INFO_COPYRIGHT		1

@interface SettingsViewController : UITableViewController <DBUploaderDelegate>{

}

- (UITableViewCell *)cellFromTableView:(UITableView *)tableView WithIdentifier:(NSString *)identifier;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password;

@end
