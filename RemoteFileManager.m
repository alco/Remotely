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
		requests_ = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[url_ release];
	[requests_ release];
	[super dealloc];
}

#pragma mark -

- (void)loadFileAtPath:(NSString *)remotePath toLocalPath:(NSString *)localPath {
	[self loadFileAtPath:remotePath toLocalPath:localPath force:NO];
}

- (void)loadFileAtPath:(NSString *)remotePath toLocalPath:(NSString *)localPath force:(BOOL)force
{
	RFMFileRequest *request = [[RFMFileRequest alloc] initWithURL:[[self url] URLByAppendingPathComponent:remotePath] localPath:localPath force:force];
	[request setDelegate:self];
	[request start];
	[requests_ addObject:request];
	[request release];
}

- (void)loadFilesFromList:(NSArray *)list atPath:(NSString *)path toLocalPath:(NSString *)localPath {
	RFMMultiFileRequest *multiRequest =
		[[RFMMultiFileRequest alloc] initWithBaseURL:[[self url] URLByAppendingPathComponent:path]
											fileList:list
										   localPath:localPath];
	[multiRequest setDelegate:self];
	[multiRequest start];
	[requests_ addObject:multiRequest];
	[multiRequest release];
}

#pragma mark -

- (void)fileRequestDidFinishLoading:(RFMFileRequest *)aRequest {
	if ([[self delegate] respondsToSelector:@selector(remoteFileManager:didFinishLoadingFile:)])
		[[self delegate] remoteFileManager:self didFinishLoadingFile:aRequest];
	[requests_ removeObject:aRequest];
}

- (void)multiFileRequest:(RFMMultiFileRequest *)request didLoadItemFromURL:(NSURL *)url {
	if ([[self delegate] respondsToSelector:@selector(remoteFileManager:didLoadFile:)])
		[[self delegate] remoteFileManager:self didLoadFile:url];
}

- (void)multiFileRequestDidFinishLoading:(RFMMultiFileRequest *)request {
	if ([[self delegate] respondsToSelector:@selector(remoteFileManager:didFinishLoadingFiles:)])
		[[self delegate] remoteFileManager:self didFinishLoadingFiles:request];
	[requests_ removeObject:request];
}

@end
