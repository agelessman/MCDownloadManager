//
//  MCDownloadManager.h
//  MCDownloadManager
//
//  Created by 马超 on 16/9/5.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>

#else
#import "AFNetworking.h"
#endif

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const MCDownloadCacheFolderName;
@class MCDownloadReceipt;
/** The download state */
typedef NS_ENUM(NSUInteger, MCDownloadState) {
    MCDownloadStateNone,           /** default */
    MCDownloadStateWillResume,     /** waiting */
    MCDownloadStateDownloading,    /** downloading */
    MCDownloadStateSuspened,       /** suspened */
    MCDownloadStateCompleted,      /** download completed */
    MCDownloadStateFailed          /** download failed */
};

/** The download prioritization */
typedef NS_ENUM(NSInteger, MCDownloadPrioritization) {
    MCDownloadPrioritizationFIFO,  /** first in first out */
    MCDownloadPrioritizationLIFO   /** last in first out */
};

typedef void (^MCSucessBlock)(NSURLRequest * _Nullable, NSHTTPURLResponse * _Nullable, NSURL * _Nonnull);
typedef void (^MCFailureBlock)(NSURLRequest * _Nullable, NSHTTPURLResponse * _Nullable,  NSError * _Nonnull);
typedef void (^MCProgressBlock)(NSProgress * _Nonnull,MCDownloadReceipt *);

/**
 *  The receipt of a downloader,we can get all the informationg by the receipt.
 */
@interface MCDownloadReceipt : NSObject <NSCoding>

/**
 * Download State
 */
@property (nonatomic, assign, readonly) MCDownloadState state;

@property (nonatomic, copy, readonly, nonnull) NSString *url;
@property (nonatomic, copy, readonly, nonnull) NSString *filePath;
@property (nonatomic, copy, readonly, nullable) NSString *filename;
@property (nonatomic, copy, readonly, nullable) NSString *truename;
@property (nonatomic, copy, readonly) NSString *speed;  // KB/s

@property (assign, nonatomic, readonly) long long totalBytesWritten;
@property (assign, nonatomic, readonly) long long totalBytesExpectedToWrite;

@property (nonatomic, copy, readonly, nonnull) NSProgress *progress;

@property (nonatomic, strong, readonly, nullable) NSError *error;

@property (nonatomic,copy)MCSucessBlock successBlock;
@property (nonatomic,copy)MCFailureBlock failureBlock;
@property (nonatomic,copy)MCProgressBlock progressBlock;
@end


@protocol MCDownloadControlDelegate <NSObject>

- (void)suspendWithURL:(NSString * _Nonnull)url;
- (void)suspendWithDownloadReceipt:(MCDownloadReceipt * _Nonnull)receipt;

- (void)removeWithURL:(NSString * _Nonnull)url;
- (void)removeWithDownloadReceipt:(MCDownloadReceipt * _Nonnull)receipt;

@end


@interface MCDownloadManager : NSObject <MCDownloadControlDelegate>

/**
 Defines the order prioritization of incoming download requests being inserted into the queue. `MCDownloadPrioritizationFIFO` by default.
 */
@property (nonatomic, assign) MCDownloadPrioritization downloadPrioritizaton;

/**
 The shared default instance of `MCDownloadManager` initialized with default values.
 */
+ (instancetype)defaultInstance;

/**
 Default initializer
 
 @return An instance of `MCDownloadManager` initialized with default values.
 */
- (instancetype)init;

/**
 Initializes the `MCDownloadManager` instance with the given session manager, download prioritization, maximum active download count.
 
 @param sessionManager The session manager to use to download file.
 @param downloadPrioritization The download prioritization of the download queue.
 @param maximumActiveDownloads  The maximum number of active downloads allowed at any given time. Recommend `4`.
 
 @return The new `MCDownloadManager` instance.
 */
- (instancetype)initWithSession:(NSURLSession *)session
                downloadPrioritization:(MCDownloadPrioritization)downloadPrioritization
                maximumActiveDownloads:(NSInteger)maximumActiveDownloads;

///-----------------------------
/// @name Running Download Tasks
///-----------------------------

/**
 Creates an `MCDownloadReceipt` with the specified request.
 
 @param url The URL  for the request.
 @param downloadProgressBlock A block object to be executed when the download progress is updated. Note this block is called on the session queue, not the main queue.
 @param destination A block object to be executed in order to determine the destination of the downloaded file. This block takes two arguments, the target path & the server response, and returns the desired file URL of the resulting download. The temporary file used during the download will be automatically deleted after being moved to the returned URL.
 
 @warning If using a background `NSURLSessionConfiguration` on iOS, these blocks will be lost when the app is terminated. Background sessions may prefer to use `-setDownloadTaskDidFinishDownloadingBlock:` to specify the URL for saving the downloaded file, rather than the destination block of this method.
 */
- (MCDownloadReceipt *)downloadFileWithURL:(NSString * _Nullable)url
                                             progress:(nullable void (^)(NSProgress *downloadProgress, MCDownloadReceipt *receipt))downloadProgressBlock
                                          destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                          success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse  * _Nullable response, NSURL *filePath))success
                                          failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure;


- (MCDownloadReceipt * _Nullable)downloadReceiptForURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
