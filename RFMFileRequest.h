#import <Foundation/Foundation.h>

@class RFMFileRequest;

@protocol RFMFileRequestDelegate<NSObject>
@optional
- (void)fileRequest:(RFMFileRequest *)request didFailWithError:(NSError *)error;
- (void)fileRequestDidFinishLoading:(RFMFileRequest *)request;
@end

@interface RFMFileRequest : NSObject

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, getter=isUsingTemporaryFile) BOOL usingTemporaryFile;	// default: YES
@property (nonatomic, assign) id<RFMFileRequestDelegate> delegate;

- (id)init;
- (id)initWithURL:(NSURL *)url localPath:(NSString *)path;

- (void)start;
- (void)stop;

@end
