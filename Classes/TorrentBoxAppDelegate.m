//
//  TorrentBoxAppDelegate.m
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TorrentBoxAppDelegate.h"
#import "RootViewController.h"


@implementation TorrentBoxAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	NSURL *inputFileUrl = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
	if (inputFileUrl != nil) {
		[(RootViewController *)[navigationController topViewController] setInputFileUrl:inputFileUrl forNewProcess:YES];
	}
	
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
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

