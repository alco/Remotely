#import "RFMFileRequest.h"

@interface RFMFileRequest()
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic) BOOL force;
@property (nonatomic, retain) NSFileHandle *fileHandle;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic) BOOL dontWriteToDestination;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
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
@synthesize force;
@synthesize fileHandle;
@synthesize data;
@synthesize dontWriteToDestination;
@synthesize dateFormatter;

#pragma mark -

- (id)init {
	if ((self = [super init])) {
		[self setUsingTemporaryFile:YES];
	}
	return self;
}

- (id)initWithURL:(NSURL *)aUrl localPath:(NSString *)aPath {
	return [self initWithURL:aUrl localPath:aPath force:NO];
}

- (id)initWithURL:(NSURL *)aUrl localPath:(NSString *)aPath force:(BOOL)aForce {
	if ([self init]) {
		[self setUrl:aUrl];
		[self setPath:aPath];
		[self setForce:aForce];
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
	[dateFormatter release];
	[super dealloc];
}

#pragma mark -

- (void)start {
	self.dontWriteToDestination = NO;

	if ([self isUsingTemporaryFile]) {
		[[NSFileManager defaultManager] createFileAtPath:[self tmpFilePath] contents:nil attributes:nil];

		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
		assert(handle);
		[self setFileHandle:handle];
	} else {
		[self setData:[NSMutableData data]];
	}

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self url]];

	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *finalPath = [self path];
	BOOL isDirectory;
	if ([fm fileExistsAtPath:[self path] isDirectory:&isDirectory]) {
		if (isDirectory)
			finalPath = [[self path] stringByAppendingPathComponent:[[[self url] absoluteString] lastPathComponent]];
	}

	NSDictionary *attributes = [fm attributesOfItemAtPath:finalPath error:NULL];
	NSDate *date = [attributes fileModificationDate];
	if (date && !force) {
		if (dateFormatter == nil) {
			NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
			NSLocale *enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
			[fmt setLocale:enUSPOSIXLocale];
			[fmt setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
			[fmt setDateFormat:@"ccc, dd MMM yyyy HH:mm:ss"];
			self.dateFormatter = fmt;
			[fmt release];
		}

		NSString *dateString = [NSString stringWithFormat:@"%@ GMT", [self.dateFormatter stringFromDate:date]];
		[request addValue:dateString forHTTPHeaderField:@"If-Modified-Since"];
	}

	NSURLConnection *conn =
		[NSURLConnection connectionWithRequest:request delegate:self];
	[conn start];
	[request release];
	self.connection = conn;

	//NSLog(@"start loading file at url %@", [self url]);
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		if ([(NSHTTPURLResponse *)response statusCode] != 200) {
			//NSLog(@"response code = %u", [(NSHTTPURLResponse *)response statusCode]);
			self.dontWriteToDestination = YES;
		}
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([self dontWriteToDestination]) {
		[self didFinishLoading];
		return;
	}

	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *finalPath = [self path];
	BOOL isDirectory;
	if ([fm fileExistsAtPath:[self path] isDirectory:&isDirectory]) {
		if (isDirectory)
			finalPath = [[self path] stringByAppendingPathComponent:[[[self url] absoluteString] lastPathComponent]];
	}

	if ([self isUsingTemporaryFile]) {
		[[self fileHandle] closeFile];
		[self setFileHandle:nil];
		[fm removeItemAtPath:finalPath error:NULL];

		NSError *error = nil;
		if (![fm moveItemAtPath:[self tmpFilePath] toPath:finalPath error:&error])
			;// NSLog(@"error moving tmp file to target path %@", error);
	} else {
		[[self data] writeToFile:finalPath atomically:YES];
		[self setData:nil];
	}

	[self didFinishLoading];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// NSLog(@"connection error %@ for url %@", error, [self url]);
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
