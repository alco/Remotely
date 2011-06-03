#import "RFMMultiFileRequest.h"
#import "RFMFileRequest.h"

@implementation RFMMultiFileRequest

@synthesize url;
@synthesize files;
@synthesize path;
@synthesize usingTemporaryFiles;
@synthesize delegate;

#pragma mark -

- (id)init {
	if ((self = [super init])) {
		[self setUsingTemporaryFiles:YES];
	}
	return self;
}

- (id)initWithBaseURL:(NSURL *)aUrl fileList:(NSArray *)aFiles localPath:(NSString *)aPath {
	if ([self init]) {
		[self setUrl:aUrl];
		[self setFiles:aFiles];
		[self setPath:aPath];
	}
	return self;
}

- (void)dealloc {
	[url release];
	[files release];
	[path release];
	[fileRequest_ release];
	[super dealloc];
}

#pragma mark -

- (void)startFileRequest {
	if (fileRequest_ == nil) {
		fileRequest_ = [[RFMFileRequest alloc] init];
		[fileRequest_ setUsingTemporaryFile:[self isUsingTemporaryFiles]];
		[fileRequest_ setPath:[self path]];
		[fileRequest_ setDelegate:(id<RFMFileRequestDelegate>)self];
	}
	[fileRequest_ setUrl:[[self url] URLByAppendingPathComponent:[[self files] objectAtIndex:fileIndex_]]];
	[fileRequest_ start];
}

- (void)start {
	[self startFileRequest];
}

- (void)stop {

}

#pragma mark -
#pragma mark RFMFileRequest delegate

- (void)fileRequestDidFinishLoading:(RFMFileRequest *)request {
	++fileIndex_;
	if (fileIndex_ >= [[self files] count]) {
		NSLog(@"finish loading all files");
	} else {
		[self startFileRequest];
	}
}

@end