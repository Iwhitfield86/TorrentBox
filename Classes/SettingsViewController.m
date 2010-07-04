//
//  SettingsViewController.m
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	// SECTION_DB_CRED	
	// SECTION_DB_ACTIONS
	// SECTION_SETTINGS
	// SECTION_INFO	
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	switch (section) {
		case SECTION_DB_CRED:
			// ROW_DB_CRED_EMAIL
			// ROW_DB_CRED_PASS
			return 2;
			break;
		case SECTION_DB_ACTIONS:
			// ROW_ACTIONS_AUTH
			return 1;
			break;
		case SECTION_SETTINGS:
			// ROW_SETTINGS_AUTO
			return 1;
			break;
		case SECTION_INFO:
			// ROW_INFO_VERSION
			// ROW_INFO_COPYRIGHT
			return 2;
			break;

	}
    return 0;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case SECTION_DB_CRED:
			return @"Dropbox Login";
			break;
		case SECTION_SETTINGS:
			return @"Misc";
			break;
	}
	return @"";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
    
	// Configure the cell.
	switch (indexPath.section) {
		case SECTION_DB_CRED:
			cell = [self cellFromTableView:tableView WithIdentifier:@"InputCell"];
			
			UITextField *textField = [[UITextField alloc] initWithFrame:cell.frame];
			textField.delegate = self;
			textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			textField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];

			cell.accessoryView = textField;
			
			switch (indexPath.row) {
				case ROW_DB_CRED_EMAIL:
					cell.textLabel.text = @"Email";
					break;
				case ROW_DB_CRED_PASS:
					cell.textLabel.text = @"Password";
					textField.secureTextEntry = YES;
					break;
			}
			
			[textField release];
			break;
		case SECTION_DB_ACTIONS:
			cell = [self cellFromTableView:tableView WithIdentifier:@"CenteredCell"];
			if (indexPath.row == ROW_DB_ACTIONS_AUTH) {
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.text = @"Login";
			}
			break;
		case SECTION_SETTINGS:
			cell = [self cellFromTableView:tableView WithIdentifier:@"SwitchCell"];
						
			if (indexPath.row == ROW_SETTINGS_AUTO) {
				cell.textLabel.text = @"Auto transfer new files";
				
				UISwitch *radioButton = [[UISwitch alloc] initWithFrame:CGRectZero];
				cell.accessoryView = radioButton;
				[radioButton release];
			}
			break;
		case SECTION_INFO:
			cell = [self cellFromTableView:tableView WithIdentifier:@"Cell"];
			switch (indexPath.row) {
				case ROW_INFO_VERSION:
					cell.textLabel.text = @"Version";
					cell.detailTextLabel.text = @"0.1";
					break;
				case ROW_INFO_COPYRIGHT:
					cell.textLabel.text = @"Copyright";
					cell.detailTextLabel.text = @"2010 Brian Partridge";
					break;
			}
			break;
	}
	
    return cell;
}


// Helper to simplify retrieval of a reusable cell
- (UITableViewCell *)cellFromTableView:(UITableView *)tableView WithIdentifier:(NSString *)identifier {
	
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	if ([identifier compare:@"Cell"] == NSOrderedSame) {
		style = UITableViewCellStyleValue1;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
    }
	
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	
	switch ([indexPath section]) {
		case SECTION_DB_ACTIONS:
			if (indexPath.row == ROW_DB_ACTIONS_AUTH) {
				// TODO: populate with real field values
				[self authenticateWithEmail:@"" password:@""];
			}
			break;
	}
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
#pragma mark Dropbox authentication
- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password {
	
	DBUploader *uploader = [[DBUploader alloc] init];
	uploader.delegate = self;
	
	// TODO: start spinner and login
}

- (void)uploaderDidLogin:(DBUploader *)uploader {
	
	NSLog(@"Loggedin");

	// TODO: stop spinner 
	
	[uploader release];
}

- (void)uploader:(DBUploader *)uploader loginFailedWithError:(NSError *)error {
	
	NSLog(@"Login failed");
	
	// TODO: stop spinner and alert user
	
	[uploader release];
}


@end

