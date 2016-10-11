//
//  MCURLRequest.h
//  MCDownloadManager
//
//  Created by 马超 on 16/9/23.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCURLSessionConfiguration.h"
#import "MCURLResponse.h"

NS_ASSUME_NONNULL_BEGIN

@class MCURLRequest;
@protocol MCURLRequestDelegate <NSObject>
@optional
- (void)URLRequest:(MCURLRequest *)request didCompleteWithResponse:(MCURLResponse *)response;
@end


typedef NS_ENUM(NSUInteger, MCHTTPMethod) {
    MCHTTPMethodGET,
    MCHTTPMethodPOST,
    MCHTTPMethodPUT,
    MCHTTPMethodHEAD,
    MCHTTPMethodPATCH,
    MCHTTPMethodDELETE
};
//这个类是对请求的封装，在实际发出请求之前，按照设计，都在这个类处理
/**
 *  设计的过程是 写请求（包括配置） ->  发请求  ->  得到相应（数据）
 */
@interface MCURLRequest : NSObject

///---------------------------------------
/// Initialization
///---------------------------------------

/*
 * Customization of MCURLRequest occurs during creation of a new URLRequest.
 * If you only need to use the convenience routines with custom
 * configuration options it is not necessary to specify a delegate.
 * If you do specify a delegate, the delegate will be retained until after
 * the delegate has been sent the URLSession:didBecomeInvalidWithError: message.
 这里需要调用afn的didBecomeInvalidWithError 然后释放delegate
 */
+ (instancetype)URLRequestWithConfiguration:(MCURLSessionConfiguration *)configuration;
+ (instancetype)URLRequestWithConfiguration:(MCURLSessionConfiguration *)configuration delegate:(nullable id <MCURLRequestDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue;

@property (nonatomic, readonly, retain) NSOperationQueue *delegateQueue;
@property (nonatomic, nullable, retain) id <MCURLRequestDelegate> delegate;
@property (nonatomic, copy) MCURLSessionConfiguration *configuration;

///---------------------------------------
/// Parameters
///---------------------------------------
// 参数，有字典，url，， nsdate ，流，  反正式afn提供的。
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable) NSDictionary *parameterDict;
@property (nonatomic, assign) MCHTTPMethod HTTPMethod;
@property (nonatomic, assign, getter=isCacheResponse) BOOL cacheResponse;

// 跟上传相关
@property (nonatomic, strong, nullable) NSData *data;
@property (nonatomic, copy, nullable) NSString *fileURL;
@property (nonatomic, strong, nullable) NSInputStream *inputStream;

@property (nonatomic, copy, nullable) NSString *fileName;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *mimeType;
@property (nonatomic, assign) int64_t length;



///---------------------------------------
/// Load Datas
///---------------------------------------

- (void)fetchDataWithMethod:(MCHTTPMethod)method completionHandler:(void (^)(MCURLResponse *response))handler;
- (void)fetchDataWithMethod:(MCHTTPMethod)method progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress completionHandler:(void (^)(MCURLResponse *response))handler;

///---------------------------------------
/// Upload Datas
///---------------------------------------
- (void)uploadDataWithCompletionHandler:(void (^)(MCURLResponse *response))handler;
- (void)uploadDataWithProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress completionHandler:(void (^)(MCURLResponse *response))handler;
@end

NS_ASSUME_NONNULL_END