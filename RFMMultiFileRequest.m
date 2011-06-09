#import "RFMMultiFileRequest.h"
#import "RFMFileRequest.h"

@interface RFMMultiFileRequest()
- (void)didLoadItem;
- (void)didFinishLoading;
@end


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
	delegate = nil;
	[url release];
	[files release];
	[path release];
	[fileRequest_ stop];
	[fileRequest_ release];
	[super dealloc];
}

#pragma mark -

- (void)startFileRequest {
	if (fileRequest_ == nil) {
		fileRequest_ = [[RFMFileRequest alloc] init];
		[fileRequest_ setUsingTemporaryFile:[self isUsingTemporaryFiles]];
		[fileRequest_ setPath:[self path]];
		[fileRequest_ setDelegate:self];
	}
	[fileRequest_ setUrl:[[self url] URLByAppendingPathComponent:[[self files] objectAtIndex:fileIndex_]]];
	[fileRequest_ start];
}

- (void)start {
	if (fileIndex_ >= [[self files] count])
		return;
	[self startFileRequest];
}

- (void)stop {

}

#pragma mark -
#pragma mark RFMFileRequest delegate

- (void)fileRequestDidFinishLoading:(RFMFileRequest *)request {
	++fileIndex_;
	[self didLoadItem];
	if (fileIndex_ >= [[self files] count]) {
		[self didFinishLoading];
	} else {
		[self startFileRequest];
	}
}

#pragma mark

- (void)didLoadItem {
	if ([[self delegate] respondsToSelector:@selector(multiFileRequest:didLoadItemFromURL:)])
		[[self delegate] multiFileRequest:self didLoadItemFromURL:[fileRequest_ url]];
}

- (void)didFinishLoading {
	if ([[self delegate] respondsToSelector:@selector(multiFileRequestDidFinishLoading:)])
		[[self delegate] multiFileRequestDidFinishLoading:self];
}

@end
