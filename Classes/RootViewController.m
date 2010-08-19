//
//  RootViewController.m
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright Brian Partridge 2010. All rights reserved.
//

#import "RootViewController.h"
#import "TorrentBoxAppDelegate.h"

@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Log user current options
	NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
	
	// Setup navbar buttons
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" 
																			 style:UIBarButtonItemStylePlain 
																			target:self 
																			action:@selector(didPressLoginButton)];
	[self updateLoginButton];
	
	// Lazily initialize the files array
	if (!files) {
		files = [[NSMutableArray alloc] init];
	}
	
	// Populate the view
	[self performSelector:@selector(populateView) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
	
	// Handle input files
	if (inputFile != nil ) {
		// The file should only be automatically transferred if there is a Dropbox session.
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoTransferInputFilesKey] && 
			[[DBSession sharedSession] isLinked])
		{
			[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(transferInputFile) userInfo:nil repeats:NO];
		}
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	int count = 1;	// SECTION_FILES
	if (actionsShown) {
		count++;	// SECTION_ACTIONS
	}
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	switch (section) {
		case SECTION_FILES:
			return [files count];
			break;
		case SECTION_ACTIONS:
			return 1;		// ROW_ACTIONS_TRANSFER
			break;
	}
    return 0;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case SECTION_FILES:
			if ([files count]) {
				return @"Files";
			}
			else {
				return @"No files found";
			}

	}
	return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	
	switch (section) {
		case SECTION_FILES:
			if ([files count]) {
				return @"Select files to transfer.";
			}
			else {
				return @"Go find some .torrents in Safari.";
			}
			break;
	}
	return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
    
	// Configure the cell.
	switch (indexPath.section) {
		case SECTION_FILES:
			cell = [self cellFromTableView:tableView WithIdentifier:@"CheckableCell"];
			NSURL *fileUrl = [files objectAtIndex:[indexPath row]];
			NSString *fileName = [[fileUrl path] lastPathComponent];
			cell.textLabel.text = fileName;
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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
		switch (indexPath.section) {
			case SECTION_FILES:
				[self deleteFileAtIndex:indexPath.row];
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
- (NSArray *)checkedCellsInTableView:(UITableView *)tableView section:(NSInteger)section {
	
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
	
	if (inputFile != nil) {
		[inputFile release];
		inputFile = nil;
	}
    [super dealloc];
}


#pragma mark -
#pragma mark Session management

- (void)didPressLoginButton {
	
    if (![[DBSession sharedSession] isLinked]) {
		DBLoginController* controller = [[DBLoginController new] autorelease];
		controller.delegate = self;
		[controller presentFromController:self];
    } else {
        [[DBSession sharedSession] unlink];
		[self updateLoginButton];
		[self updateActionsSection];
    }
}


#pragma mark -
#pragma mark DBLoginControllerDelegate methods

- (void)loginControllerDidLogin:(DBLoginController*)controller {
    [self updateLoginButton];
	[self updateActionsSection];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
	
}


#pragma mark -
#pragma mark UI management

- (void)populateView {

	// Index the local files
	[self identifyLocalFiles];
		
	// Only reload the files section if there are files.
	// Rows should animate in from the left.
	if ([files count]) {
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_FILES] 
					  withRowAnimation:UITableViewRowAnimationRight];
	}
	
	// Since SECTION_FILES may have changed, update SECTION_ACTIONS
	[self updateActionsSection];
}


- (void)updateLoginButton {
	
	NSString* title = [[DBSession sharedSession] isLinked] ? @"Logout" : @"Login";
    [self.navigationItem.leftBarButtonItem setTitle:title];
}


// SECTION_ACTIONS is shown dynamically based on several conditions.
// This method add or removes the section based on those conditions.
- (void)updateActionsSection {
	
	BOOL shouldShow = [self shouldShowActionsSection];
	if (actionsShown && !shouldShow) {
		
		[self.tableView beginUpdates];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:SECTION_ACTIONS] withRowAnimation:UITableViewRowAnimationRight];
		actionsShown = NO;
		[self.tableView endUpdates];
	}
	else if (!actionsShown && shouldShow) {
		
		[self.tableView beginUpdates];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:SECTION_ACTIONS] withRowAnimation:UITableViewRowAnimationLeft];
		actionsShown = YES;
		[self.tableView endUpdates];
	}
}

// Calculates whether SECTION_ACTIONS should be displayed.
- (BOOL)shouldShowActionsSection {
	
	if ([files count] && [[DBSession sharedSession] isLinked]) {
		
		return YES;
	}
	return NO;
}

// Deletes the specified file from the filesystem and updates the table view.
- (void)deleteFile:(NSString*)filePath {
	
	for (int i = 0; i < [files count]; ++i) {

		if ([filePath isEqualToString:[(NSURL *)[files objectAtIndex:i] path]]) {
			
			[self deleteFileAtIndex:i];
			break;
		}
	}
}

// Deletes the file at 'index' from the filesystem and updates the table view.
- (void)deleteFileAtIndex:(NSInteger)index {
	
	NSURL *fileUrl = [files objectAtIndex:index];
	
	// Delete the actual file
	NSError *error = nil;
	if (![[NSFileManager defaultManager] removeItemAtPath:[fileUrl path] error:&error]) {
		NSLog(@"Error deleting %@: %@", [fileUrl path], error.description);
		return;
	}
	
	// Remove the file from the index
	[files removeObjectAtIndex:index];
	
	// Remove the row from the table
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:SECTION_FILES]] 
						  withRowAnimation:UITableViewRowAnimationRight];
	
	// Since SECTION_FILES changed, update SECTION_ACTIONS
	[self updateActionsSection];
	
	// If all files have been removed, reload SECTION_FILES to ensure the correct header and footer are shown
	if (![files count]) {
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_FILES] withRowAnimation:UITableViewRowAnimationNone];
	}
}

#pragma mark -
#pragma mark File management

- (void)setInputFileUrl:(NSURL *)url forNewProcess:(BOOL)newProcess {
	
	[inputFile release];
	inputFile = nil;
	inputFile = [url retain];
}

- (void)identifyLocalFiles {
	
	[files removeAllObjects];
	
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
}

// Return the Urls of the files checked in the table view
- (NSArray *)urlsForCheckedFiles {
	
	NSMutableArray *fileUrls = [[NSMutableArray alloc] init];
	
	NSArray *checkedFiles = [self checkedCellsInTableView:self.tableView section:SECTION_FILES];
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

- (void)transferInputFile {
	
	if (inputFile != nil) {
		
		NSArray *fileUrls = [NSArray arrayWithObject:inputFile];
		DBUploader *uploader = [[DBUploader alloc] initWithFiles:fileUrls];
		uploader.delegate = self;
		[uploader upload];
	}
}

- (void)transferFiles {
	
	NSArray *fileUrls = [self urlsForCheckedFiles];
	if ([fileUrls count] == 0) {
		return;
	}
	
	DBUploader *uploader = [[DBUploader alloc] initWithFiles:fileUrls];
	uploader.delegate = self;
	[uploader upload];
}


#pragma mark -
#pragma mark DBUploaderDelegate methods

- (void)uploaderBeganTransferringFiles:(DBUploader *)uploader {
	
	if (spinner == nil) {
		spinner = [[MBProgressHUD alloc] initWithView:self.view];
		spinner.mode = MBProgressHUDModeIndeterminate;
		[self.view addSubview:spinner];
	}
	spinner.minShowTime = 2;
	spinner.labelText = @"";
	spinner.detailsLabelText = @"";
	[spinner show:YES];
}

- (void)uploader:(DBUploader *)uploader beganTransferringFile:(NSString *)file {
	
	spinner.labelText = [file lastPathComponent];
	spinner.detailsLabelText = @"";
}

- (void)uploader:(DBUploader *)uploader successfullyTransferredFile:(NSString *)file {
	
	spinner.labelText = @"";
	spinner.detailsLabelText = @"";
	
	[self deleteFile:file];
}

- (void)uploader:(DBUploader *)uploader failedToTransferFile:(NSString *)file withError:(NSError *)error {
	
	spinner.labelText = [file lastPathComponent];
	spinner.detailsLabelText = @"Failed";
}

- (void)uploaderSuccessfullyTransferredFiles:(DBUploader *)uploader {
	
	spinner.labelText = @"Complete";
	spinner.detailsLabelText = @"";
	[spinner hide:YES];
	[spinner removeFromSuperview];
	[spinner release];
	spinner = nil;
}

- (void)uploaderHaltedFileTransfers:(DBUploader *)uploader {
	
	spinner.labelText = @"Error";
	spinner.detailsLabelText = @"";
	[spinner hide:YES];
	[spinner removeFromSuperview];
	[spinner release];
	spinner = nil;
}

@end

