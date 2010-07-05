//
//  RootViewController.h
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBUploader.h"
#import "MBProgressHUD.h"

#define SECTION_FILES			0
#define SECTION_ACTIONS			1

#define ROW_ACTIONS_TRANSFER	0

#define SKIP_INVISIBLE			YES

@interface RootViewController : UITableViewController <DBUploaderDelegate>{
	
	NSString *inputFile;
	NSMutableArray *files;
	MBProgressHUD *spinner;
}

- (UITableViewCell *)cellFromTableView:(UITableView *)tableView WithIdentifier:(NSString *)identifier;
- (NSArray *)checkedRowsInTableView:(UITableView *)tableView section:(NSInteger)section;

- (void)showSettings;
- (void)hideSettings;

- (void)updateFileList;

- (void)identifyLocalFiles;
- (NSArray *)urlsForCheckedFiles;

- (void)transferFiles;

@end
