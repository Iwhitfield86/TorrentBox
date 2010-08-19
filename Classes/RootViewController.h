//
//  RootViewController.h
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright Brian Partridge 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBUploader.h"
#import "MBProgressHUD.h"

#define SECTION_FILES			0
#define SECTION_ACTIONS			1

#define ROW_ACTIONS_TRANSFER	0

#define SKIP_INVISIBLE			YES

@interface RootViewController : UITableViewController <DBUploaderDelegate, DBLoginControllerDelegate>{
	
	NSURL *inputFile;			// Set by the AppDelegate when launched with a URL
	NSMutableArray *files;
	MBProgressHUD *spinner;
	BOOL actionsShown;		// Tracks whether SECTION_ACTIONS is being displayed or not
}

- (UITableViewCell *)cellFromTableView:(UITableView *)tableView WithIdentifier:(NSString *)identifier;
- (NSArray *)checkedCellsInTableView:(UITableView *)tableView section:(NSInteger)section;

- (void)didPressLoginButton;

- (void)populateView;
- (void)updateLoginButton;
- (void)updateActionsSection;
- (BOOL)shouldShowActionsSection;
- (void)deleteFile:(NSString*)filePath;
- (void)deleteFileAtIndex:(NSInteger)index;

- (void)setInputFileUrl:(NSURL *)url forNewProcess:(BOOL)newProcess;
- (void)identifyLocalFiles;
- (void)identifyFilesInDirectory:(NSString *)directoryPath;
- (NSArray *)urlsForCheckedFiles;

- (void)transferInputFile;
- (void)transferFiles;

@end
