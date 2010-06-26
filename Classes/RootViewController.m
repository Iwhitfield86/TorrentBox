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
			break;
		case SECTION_ACTIONS:
			// ACTIONS_ROW_TRANSFER
			return 1;
			break;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.

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


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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


@end

