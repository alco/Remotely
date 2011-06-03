#import <Foundation/Foundation.h>

@class RFMFileRequest;
@class RFMMultiFileRequest;

// Delegates are not required to conform to this protocol. It simply
// documents supported callbacks.
@protocol RFMMultiFileRequestDelegate<NSObject>
@optional
- (void)multiFileRequest:(RFMMultiFileRequest *)request
		didFailWithError:(NSError *)error
					 url:(NSURL *)url;

- (void)multiFileRequest:(RFMMultiFileRequest *)request
	  didLoadItemFromURL:(NSURL *)url;

- (void)multiFileRequestDidFinishLoading:(RFMMultiFileRequest *)request;
@end

@interface RFMMultiFileRequest : NSObject {
	NSUInteger fileIndex_;
	RFMFileRequest *fileRequest_;
}

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, getter=isUsingTemporaryFiles) BOOL usingTemporaryFiles;	// default: YES
@property (nonatomic, assign) id delegate;

- (id)init;
- (id)initWithBaseURL:(NSURL *)url fileList:(NSArray *)files localPath:(NSString *)path;

- (void)start;
- (void)stop;

@end
