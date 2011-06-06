#import "RemoteFileManager.h"
#import "RFMFileRequest.h"
#import "RFMMultiFileRequest.h"

@implementation RemoteFileManager

@synthesize delegate = delegate_;
@synthesize url = url_;

#pragma mark -

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		[self setUrl:url];
	}
	return self;
}

- (void)dealloc {
	[url_ release];
	[super dealloc];
}

#pragma mark -

- (void)loadFileAtPath:(NSString *)remotePath toLocalPath:(NSString *)localPath {
	RFMFileRequest *request = [[RFMFileRequest alloc] initWithURL:[[self url] URLByAppendingPathComponent:remotePath] localPath:localPath];
	[request setDelegate:self];
	[request start];
}

- (void)loadFilesFromList:(NSArray *)list atPath:(NSString *)path toLocalPath:(NSString *)localPath {
	RFMMultiFileRequest *multiRequest =
		[[RFMMultiFileRequest alloc] initWithBaseURL:[[self url] URLByAppendingPathComponent:path]
											fileList:list
										   localPath:localPath];
	[multiRequest setDelegate:self];
	[multiRequest start];
}

#pragma mark -

- (void)fileRequestDidFinishLoading:(RFMFileRequest *)aRequest {
	if ([[self delegate] respondsToSelector:@selector(remoteFileManager:didFinishLoadingFile:)])
		[[self delegate] remoteFileManager:self didFinishLoadingFile:aRequest];
	[aRequest release];
}

- (void)multiFileRequest:(RFMMultiFileRequest *)request didLoadItemFromURL:(NSURL *)url {
	if ([[self delegate] respondsToSelector:@selector(remoteFileManager:didLoadFile:)])
		[[self delegate] remoteFileManager:self didLoadFile:url];
}

- (void)multiFileRequestDidFinishLoading:(RFMMultiFileRequest *)request {
	if ([[self delegate] respondsToSelector:@selector(remoteFileManager:didFinishLoadingFiles:)])
		[[self delegate] remoteFileManager:self didFinishLoadingFiles:request];
	[request release];
}

@end
