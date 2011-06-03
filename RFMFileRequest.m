#import "RFMFileRequest.h"

@interface RFMFileRequest()
@property (nonatomic, retain) NSFileHandle *fileHandle;
- (NSString *)tmpFilePath;
- (void)didFinishLoading;
@end

@implementation RFMFileRequest

@synthesize url;
@synthesize path;
@synthesize usingTemporaryFile;
@synthesize delegate;

@synthesize fileHandle;

#pragma mark -

- (id)init {
	if ((self = [super init])) {
		[self setUsingTemporaryFile:YES];
	}
	return self;
}

- (id)initWithURL:(NSURL *)aUrl localPath:(NSString *)aPath {
	if ([self init]) {
		[self setUrl:aUrl];
		[self setPath:aPath];
	}
	return self;
}

- (void)dealloc {
	[url release];
	[path release];
	[super dealloc];
}

#pragma mark -

- (void)start {
	[[NSFileManager defaultManager] createFileAtPath:[self tmpFilePath] contents:nil attributes:nil];

	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
	assert(handle);
	[self setFileHandle:handle];

	NSURLConnection *conn =
		[NSURLConnection connectionWithRequest:
		 [NSURLRequest requestWithURL:[self url]] delegate:self];
	[conn start];

	NSLog(@"start loading file at url %@", [self url]);
}

- (void)stop {

}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[[self fileHandle] writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[self fileHandle] closeFile];
	[self setFileHandle:nil];

	NSString *finalPath;
	NSFileManager *fm = [NSFileManager defaultManager];
	// First check if target path points at an actual file
	BOOL isDirectory;
	if ([fm fileExistsAtPath:[self path] isDirectory:&isDirectory]) {
		if (isDirectory) {
		    finalPath = [[self path] stringByAppendingPathComponent:[[[self url] absoluteString] lastPathComponent]];
			[fm removeItemAtPath:finalPath error:NULL];
		} else {
			[fm removeItemAtPath:[self path] error:NULL];
		}
	} else {
		finalPath = [self path];
	}

	NSError *error = nil;
	if (![fm moveItemAtPath:[self tmpFilePath] toPath:finalPath error:&error])
		NSLog(@"error moving tmp file to target path %@", error);

	[self didFinishLoading];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"connection error %@ for url %@", error, [self url]);
}

#pragma mark -
#pragma mark Private methods

- (NSString *)tmpFilePath {
	return [NSTemporaryDirectory() stringByAppendingPathComponent:[[[[self url] absoluteString] lastPathComponent] stringByAppendingString:@".tmp.part"]];
}

#pragma mark

- (void)didFinishLoading {
	if ([[self delegate] respondsToSelector:@selector(fileRequestDidFinishLoading:)])
		[[self delegate] fileRequestDidFinishLoading:self];
}

@end
