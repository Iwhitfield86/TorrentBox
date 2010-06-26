//
//  RootViewController.h
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SECTION_FILES			0
#define SECTION_ACTIONS			1

#define ROW_ACTIONS_TRANSFER	0

#define SKIP_INVISIBLE			YES

@interface RootViewController : UITableViewController {
	
	NSString *inputFile;
	NSMutableArray *files;
}

- (UITableViewCell *)cellFromTableView:(UITableView *)tableView WithIdentifier:(NSString *)identifier;

- (void)showSettings;
- (void)hideSettings;

- (void)updateFileList;

- (void)identifyLocalFiles;
- (void)deleteFileAtPath:(NSURL *)fileUrl;

- (void)transferFiles;

@end
