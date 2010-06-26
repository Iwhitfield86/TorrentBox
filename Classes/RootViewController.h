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

#define ACTIONS_ROW_TRANSFER	0

#define SKIP_INVISIBLE			YES

@interface RootViewController : UITableViewController {
	
	NSString *inputFile;
	NSMutableArray *files;
}

- (void)showSettings;
- (void)hideSettings;

- (void)updateFileList;

- (void)identifyLocalFiles;
- (void)deleteFileAtPath:(NSURL *)fileUrl;

@end
