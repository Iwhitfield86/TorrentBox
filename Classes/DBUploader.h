//
//  DBUploader.h
//  TorrentBox
//
//  Created by Brian Partridge on 7/4/10.
//  Copyright 2010 Brian Partridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DropboxSDK.h"


@protocol DBUploaderDelegate;

@interface DBUploader : NSObject <DBRestClientDelegate> {

	id <DBUploaderDelegate> delegate;
	NSArray *files;
	NSEnumerator *enumerator;
}

@property(assign) id delegate;

- (id)initWithFiles:(NSArray *)filesToUpload;
- (void)upload;
- (void)uploadNextFile:(DBRestClient *)client;

@end

@protocol DBUploaderDelegate <NSObject>

@optional
- (void)uploaderBeganTransferringFiles:(DBUploader *)uploader;
- (void)uploader:(DBUploader *)uploader beganTransferringFile:(NSString *)file;
- (void)uploader:(DBUploader *)uploader successfullyTransferredFile:(NSString *)file;
- (void)uploader:(DBUploader *)uploader failedToTransferFile:(NSString *)file withError:(NSError *)error;
- (void)uploaderSuccessfullyTransferredFiles:(DBUploader *)uploader;
- (void)uploaderHaltedFileTransfers:(DBUploader *)uploader;
@end