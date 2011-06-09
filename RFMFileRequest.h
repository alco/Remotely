#import <Foundation/Foundation.h>

@class RFMFileRequest;

// Delegates are not required to conform to this protocol. It simply
// documents supported callbacks.
@protocol RFMFileRequestDelegate<NSObject>
@optional
- (void)fileRequest:(RFMFileRequest *)request didFailWithError:(NSError *)error;
- (void)fileRequestDidFinishLoading:(RFMFileRequest *)request;
@end

@interface RFMFileRequest : NSObject

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, getter=isUsingTemporaryFile) BOOL usingTemporaryFile;	// default: YES
@property (nonatomic, assign) id delegate;

- (id)init;
- (id)initWithURL:(NSURL *)url localPath:(NSString *)path;
- (id)initWithURL:(NSURL *)url localPath:(NSString *)path force:(BOOL)force;

- (void)start;
- (void)stop;

@end
