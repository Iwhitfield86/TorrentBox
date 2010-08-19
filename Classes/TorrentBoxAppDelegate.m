//
//  TorrentBoxAppDelegate.m
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright Brian Partridge 2010. All rights reserved.
//

#import "TorrentBoxAppDelegate.h"
#import "RootViewController.h"
#import "DBConfig.h"


@implementation TorrentBoxAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	// Register default settings
    NSDictionary *appDefaults = [NSMutableDictionary dictionary];
	[appDefaults setValue:[NSNumber numberWithBool:YES] forKey:kAutoTransferInputFilesKey];
	[appDefaults setValue:[NSNumber numberWithBool:YES] forKey:kDeleteTransferedFiles];
	[appDefaults setValue:[NSNumber numberWithBool:NO] forKey:kIndexDocumentsDirectory];
	[appDefaults setValue:[NSNumber numberWithBool:NO] forKey:kIndexInvisibleFiles];
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];							 
	
	// Prepare the Dropbox session to identify as TorrentBox
	DBSession* session = [[DBSession alloc] initWithConsumerKey:DB_CONSUMERKEY consumerSecret:DB_CONSUMERSECRET];
	[DBSession setSharedSession:session];
    [session release];
	
	// If there was an input URL, set it on the root view controller
	NSURL *inputFileUrl = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
	if (inputFileUrl != nil) {
		[(RootViewController *)[navigationController topViewController] setInputFileUrl:inputFileUrl forNewProcess:YES];
	}
	
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
	// If there was an input URL, set it on the root view controller
	if (url != nil) {
		[(RootViewController *)[navigationController topViewController] setInputFileUrl:url forNewProcess:NO];
	}
	
	return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

