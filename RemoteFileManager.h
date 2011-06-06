#import <Foundation/Foundation.h>

@class RemoteFileManager;

@protocol RemoteFileManagerDelegate
@optional
- (void)remoteFileManager:(RemoteFileManager *)rfm didFinishLoadingFile:(id)result;
- (void)remoteFileManager:(RemoteFileManager *)rfm didLoadFile:(id)result;
- (void)remoteFileManager:(RemoteFileManager *)rfm didFinishLoadingFiles:(id)result;
@end

@interface RemoteFileManager : NSObject

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSURL *url;

- (id)initWithURL:(NSURL *)url;

- (void)loadFileAtPath:(NSString *)remotePath toLocalPath:(NSString *)localPath;
- (void)loadFilesFromList:(NSArray *)list atPath:(NSString *)path toLocalPath:(NSString *)localPath;

@end
