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
	
	if ([delegate respondsToSelector:@selector(uploaderBeganTransferringFiles:)]) 
    {
        [delegate uploaderBeganTransferringFiles:self];
    }
	
	enumerator = [files objectEnumerator];
	[self uploadNextFile];
}

- (void)uploadNextFile {
	
	id object;
	if (object = [enumerator nextObject]) {
		NSURL *fileUrl = (NSURL *)object;
		if ([delegate respondsToSelector:@selector(uploader:beganTransferringFile:)]) 
		{
			[delegate uploader:self beganTransferringFile:[fileUrl absoluteString]];
		}
		
		// TODO: upload the file
	}
	else {
		[enumerator release];
		enumerator = nil;
	}
}

#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClientDidLogin:(DBRestClient*)client
{
    NSLog(@"PASSED: client login worked.");
	
	if ([delegate respondsToSelector:@selector(uploaderDidLogin:)]) 
    {
        [delegate uploaderDidLogin:self];
    }
}

- (void)restClient:(DBRestClient*)client loginFailedWithError:(NSError*)error
{
    NSLog(@"ERROR client login failed %d %@", error.code, error.userInfo);
	
	if ([delegate respondsToSelector:@selector(uploader:loginFailedWithError:)]) 
    {
        [delegate uploader:self loginFailedWithError:error];
    }
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)sourcePath 
{
    NSLog(@"PASSED: file uploaded: %@", sourcePath);
	
	if ([delegate respondsToSelector:@selector(uploader:successfullyTransferredFile:)]) 
    {
        [delegate uploader:self successfullyTransferredFile:sourcePath];
    }
	
	[self uploadNextFile];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"ERROR file upload failed %d %@", error.code, error.userInfo);
	
	if ([delegate respondsToSelector:@selector(uploader:failedToTransferFile:withError:)]) 
    {
		// TODO: fill in the sourcePath from the error.userInfo
        [delegate uploader:self failedToTransferFile:@"" withError:error];
    }
}

@end
