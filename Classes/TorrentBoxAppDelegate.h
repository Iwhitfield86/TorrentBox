//
//  TorrentBoxAppDelegate.h
//  TorrentBox
//
//  Created by Brian Partridge on 6/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

// Misc Options
static NSString* kAutoTransferInputFilesKey = @"kAutoTransferInputFilesKey";
static NSString* kDeleteTransferedFiles = @"kDeleteTransferedFiles";
static NSString* kIndexDocumentsDirectory = @"kIndexDocumentsDirectory";

@interface TorrentBoxAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

