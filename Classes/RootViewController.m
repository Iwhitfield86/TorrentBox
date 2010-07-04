//
//  RootViewController.m
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "SettingsViewController.h"


@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"]
																			 style:UIBarButtonItemStylePlain 
																			target:self 
																			action:@selector(showSettings)];
	
	if (!files) {
		files = [[NSMutableArray alloc] init];
	}
	
	// Get the local files to populate the table view
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(identifyLocalFiles) userInfo:nil repeats:NO];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	// SECTION_FILES
	// SECTION_ACTIONS
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	switch (section) {
		case SECTION_FILES:
			if ([files count] == 0) {
				// 'No files found.' row
				return 1;
			}
			return [files count];
			break;
		case SECTION_ACTIONS:
			// ROW_ACTIONS_TRANSFER
			return 1;
			break;
	}
    return 0;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case SECTION_FILES:
			return @"Files";
	}
	return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	
	switch (section) {
		case SECTION_FILES:
			return @"Select files to transfer.";
	}
	return @"";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
    
	// Configure the cell.
	switch (indexPath.section) {
		case SECTION_FILES:
			if ([files count] == 0) {
				cell = [self cellFromTableView:tableView WithIdentifier:@"CenteredCell"];
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.text = @"No files found.";
			}
			else {
				cell = [self cellFromTableView:tableView WithIdentifier:@"CheckableCell"];
				NSURL *fileUrl = [files objectAtIndex:[indexPath row]];
				NSString *fileName = [[fileUrl path] lastPathComponent];
				cell.textLabel.text = fileName;
			}
			break;
		case SECTION_ACTIONS:
			cell = [self cellFromTableView:tableView WithIdentifier:@"CenteredCell"];
			if (indexPath.row == ROW_ACTIONS_TRANSFER) {
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.text = @"Transfer";
			}
			break;
	}
	
    return cell;
}


// Helper to simplify retrieval of a reusable cell
- (UITableViewCell *)cellFromTableView:(UITableView *)tableView WithIdentifier:(NSString *)identifier {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
	
	return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

	switch (indexPath.section) {
		case SECTION_FILES:
			return YES;
			break;
	}
    return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
		switch ([indexPath section]) {
			case SECTION_FILES:
				;
				NSURL *fileUrl = [files objectAtIndex:indexPath.row];
				
				// Delete the actual file
				NSFileManager *manager = [NSFileManager defaultManager];
				NSError *error = nil;
				if (![manager removeItemAtPath:[fileUrl path] error:&error]) {
					NSLog(@"Failed to delete %@: %@", [fileUrl path], error.description);
					break;
				}
				
				// Remove the Url from the file list
				[files removeObjectAtIndex:indexPath.row];
				
				// Remove the row from the table
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
    }
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	
	switch ([indexPath section]) {
		case SECTION_FILES:
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			
			if ([files count] == 0) {
				break;
			}
			
			if (selectedCell.accessoryType == UITableViewCellAccessoryNone) {
				selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			else if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
				selectedCell.accessoryType = UITableViewCellAccessoryNone;
			}
			
			break;
		case SECTION_ACTIONS:
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			[self transferFiles];
			break;
	}
}


// Iterate the cells in the table view to find the ones that have checkmarks
- (NSArray *)checkedRowsInTableView:(UITableView *)tableView section:(NSInteger)section {
	
	NSMutableArray *checkedCellIndexPaths = [[NSMutableArray alloc] init];
	
	NSInteger count = [tableView numberOfRowsInSection:section];
	for (int i = 0; i < count; ++i) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
			[checkedCellIndexPaths addObject:indexPath];
		}
	}
	
	return checkedCellIndexPaths;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark Settings management

- (void)showSettings {
	
	SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	settings.title = @"Settings";
	settings.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
																				  style:UIBarButtonItemStyleDone
																				 target:self 
																				 action:@selector(hideSettings)];
	
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
	[self presentModalViewController:nav animated:YES];
}

- (void)hideSettings {
	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UI management

- (void)updateFileList {

	[self.tableView reloadData];
}

#pragma mark -
#pragma mark File management

- (void)identifyLocalFiles {
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSArray *documentPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([documentPaths count] == 0) { return; }
	
	NSString *documentPath = [documentPaths objectAtIndex:0];
	if (documentPath == nil) { return; }
	NSLog(@"Document directory: %@", documentPath);
	
	if (![manager fileExistsAtPath:documentPath]) { return; }
	
	NSString *inboxPath = [documentPath stringByAppendingPathComponent:@"Inbox"];
	if (inboxPath == nil) { return; }
	NSLog(@"Inbox directory: %@", inboxPath);
	
	if (![manager fileExistsAtPath:inboxPath]) { return; }
	
	NSError *error = nil;
	NSArray *inboxFiles = [manager contentsOfDirectoryAtPath:inboxPath error:&error];
	if (inboxFiles == nil || error != nil) {
		NSLog(@"Error: %@", [error description]);
	}
	
	for (int i=0; i < [inboxFiles count]; ++i) {
		NSString *fileName = [inboxFiles objectAtIndex:i];
		
		if (SKIP_INVISIBLE && [fileName hasPrefix:@"."]) {
			continue;
		}
		
		if (fileName != nil) {
			NSURL *fileUrl = [NSURL fileURLWithPath:[inboxPath stringByAppendingPathComponent:fileName]];
			NSLog(@"File: %@", [fileUrl path]);
			[files addObject:fileUrl];
		}
	}
	
	[self updateFileList];
}

- (void)deleteFileAtPath:(NSURL *)fileUrl {
	
	NSLog(@"Deleting: %@", [fileUrl path]);
	
	NSFileManager *manager = [NSFileManager defaultManager];	
	NSError *error = nil;
	if (![manager removeItemAtPath:[fileUrl path] error:&error]) {
		NSLog(@"Error: %@", [error description]);
	}
}

// Return the Urls of the files checked in the table view
- (NSArray *)urlsForCheckedFiles {
	
	NSMutableArray *fileUrls = [[NSMutableArray alloc] init];
	
	NSArray *checkedFiles = [self checkedRowsInTableView:self.tableView section:SECTION_FILES];
	NSEnumerator *enumerator = [checkedFiles objectEnumerator];
	id object;
	while (object = [enumerator nextObject]) {
		[fileUrls addObject:[files objectAtIndex:[(NSIndexPath *)object row]]];
	}
	[checkedFiles release];
	
	return fileUrls;
}


#pragma mark -
#pragma mark File transfer management

- (void)transferFiles {
	
	DBUploader *uploader = [[DBUploader alloc] initWithFiles:[self urlsForCheckedFiles]];
	uploader.delegate = self;
	[uploader upload];
}

- (void)uploaderBeganTransferringFiles:(DBUploader *)uploader {
	
	// TODO: start spinner
	NSLog(@"Started");
}

- (void)uploader:(DBUploader *)uploader beganTransferringFile:(NSString *)file {
	
	// TODO: set filename on spinner
	NSLog(@"Started %@", file);
}

- (void)uploader:(DBUploader *)uploader successfullyTransferredFile:(NSString *)file {
	
	// TODO: remove filename from spinner
	NSLog(@"Finished %@", file);
}

- (void)uploader:(DBUploader *)uploader failedToTransferFile:(NSString *)file withError:(NSError *)error {
	
	// TODO: remove filename from spinner
	NSLog(@"Failed %@", file);
}

- (void)uploaderSuccessfullyTransferredFiles:(DBUploader *)uploader {
	
	// TODO: display 'success' then stop/clear spinner
	NSLog(@"Finished");
}

- (void)uploaderHaltedFileTransfers:(DBUploader *)uploader {
	
	// TODO: display 'error' then stop/clear spinner
	NSLog(@"Halted");
}

@end

