//
//  DBUploader.m
//  TorrentBox
//
//  Created by Brian Partridge on 7/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DBUploader.h"


@implementation DBUploader

@synthesize delegate;

- (id)init {
	
	if ((self = [super init])) {
		files = [[NSArray alloc] init];
	}
	return self;
}

- (id)initWithFiles:(NSArray *)filesToUpload {

	if ((self = [super init])) {
		files = filesToUpload;
		[files retain];
	}
	return self;
}

- (void)dealloc {
	
	[files release];
	[super dealloc];
}

- (void)upload {
	
	DBRestClient* client = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
	client.delegate = self;
		
	if ([delegate respondsToSelector:@selector(uploaderBeganTransferringFiles:)]) 
    {
        [delegate uploaderBeganTransferringFiles:self];
    }
	
	enumerator = [files objectEnumerator];
	[enumerator retain];
	[self uploadNextFile:client];
}

- (void)uploadNextFile:(DBRestClient *)client {
	
	id object;
	if (object = [enumerator nextObject]) {
		NSURL *fileUrl = (NSURL *)object;
		NSString *fileName = [[fileUrl path] lastPathComponent];
		if ([delegate respondsToSelector:@selector(uploader:beganTransferringFile:)]) 
		{
			[delegate uploader:self beganTransferringFile:[fileUrl path]];
		}
		
		[client uploadFile:fileName toPath:@"/" fromPath:[fileUrl path]];
	}
	else {
		if ([delegate respondsToSelector:@selector(uploaderSuccessfullyTransferredFiles:)]) 
		{
			[delegate uploaderSuccessfullyTransferredFiles:self];
		}
		
		[enumerator release];
		enumerator = nil;
	}
}

#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)sourcePath 
{
    NSLog(@"PASSED: file uploaded: %@", sourcePath);
	
	if ([delegate respondsToSelector:@selector(uploader:successfullyTransferredFile:)]) 
    {
        [delegate uploader:self successfullyTransferredFile:sourcePath];
    }
	
	[self uploadNextFile:client];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"ERROR file upload failed %d %@", error.code, error.userInfo);
	
	if ([delegate respondsToSelector:@selector(uploader:failedToTransferFile:withError:)]) 
    {
		// TODO: fill in the sourcePath from the error.userInfo
        [delegate uploader:self failedToTransferFile:@"" withError:error];
    }
	
	if ([delegate respondsToSelector:@selector(uploaderHaltedFileTransfers:)]) 
    {
        [delegate uploaderHaltedFileTransfers:self];
    }
}

@end
