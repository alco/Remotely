#import "RFMFileRequest.h"

@interface RFMFileRequest()
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSFileHandle *fileHandle;
@property (nonatomic, retain) NSMutableData *data;
- (NSString *)tmpFilePath;
- (void)appendData:(NSData *)aData;
- (void)didFinishLoading;
@end

@implementation RFMFileRequest

@synthesize url;
@synthesize path;
@synthesize usingTemporaryFile;
@synthesize delegate;

@synthesize connection;
@synthesize fileHandle;
@synthesize data;

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
	[fileHandle release];
	[data release];
	[connection cancel];
	[connection release];
	[super dealloc];
}

#pragma mark -

- (void)start {
	if ([self isUsingTemporaryFile]) {
		[[NSFileManager defaultManager] createFileAtPath:[self tmpFilePath] contents:nil attributes:nil];

		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
		assert(handle);
		[self setFileHandle:handle];
	} else {
		[self setData:[NSMutableData data]];
	}

	NSURLConnection *conn =
		[NSURLConnection connectionWithRequest:
		 [NSURLRequest requestWithURL:[self url]] delegate:self];
	[conn start];
	self.connection = conn;

	NSLog(@"start loading file at url %@", [self url]);
}

- (void)stop {
	[self.connection cancel];
	self.connection = nil;
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData {
	[self appendData:aData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *finalPath;
	BOOL isDirectory;
	if ([fm fileExistsAtPath:[self path] isDirectory:&isDirectory]) {
		if (isDirectory)
			finalPath = [[self path] stringByAppendingPathComponent:[[[self url] absoluteString] lastPathComponent]];
	} else {
		finalPath = [self path];
	}

	if ([self isUsingTemporaryFile]) {
		[[self fileHandle] closeFile];
		[self setFileHandle:nil];
		[fm removeItemAtPath:finalPath error:NULL];

		NSError *error = nil;
		if (![fm moveItemAtPath:[self tmpFilePath] toPath:finalPath error:&error])
			NSLog(@"error moving tmp file to target path %@", error);
	} else {
		[[self data] writeToFile:finalPath atomically:YES];
		[self setData:nil];
	}

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

- (void)appendData:(NSData *)aData {
	if ([self isUsingTemporaryFile])
		[[self fileHandle] writeData:aData];
	else
		[[self data] appendData:aData];
}

#pragma mark

- (void)didFinishLoading {
	if ([[self delegate] respondsToSelector:@selector(fileRequestDidFinishLoading:)])
		[[self delegate] fileRequestDidFinishLoading:self];
}

@end
