//
//  MCURLResponse.h
//  MCDownloadManager
//
//  Created by 马超 on 16/9/21.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MCURLResponseStatus) {
    MCURLResponseStatusNone,
    MCURLResponseStatusSuccess,       // 成功
    MCURLResponseStatusDataInvalid,   // 请求成功，但服务器返回的数据不正确
    MCURLResponseStatusParameterInvalid,   // 参数错误，不会发请求
    MCURLResponseStatusTimeout,      // 请求超时
    MCURLResponseStatusNetworkNotReachable   // 网络不可达，这个会在发请求之前检测网络是不是可达的
};

// 需要一个把结果加压成何种数据的说明
@interface MCURLResponse : NSObject

// 响应的所有封装的数据，这里能拿到我们需要的最原始的数据
// 这里如果出错，最好能告诉用户出错的原因。

@property (nonatomic, assign) MCURLResponseStatus status;
@property (nonatomic, copy, readonly, nullable) id responseObject;
@property (nonatomic, copy, readonly) NSDictionary *requestParameter; // 这里封装的应该是请求封装，请求封装中能够拿到必要的配置信息，
@property (nonatomic, assign, readonly, getter=isCache) BOOL cache;
@property (nonatomic, copy, nullable) NSString *URLIdentifier;
@property (nonatomic, strong, readonly, nullable) NSURLSessionDataTask *task;
@property (nonatomic, strong, readonly, nullable) NSError *error;

//对于响应来说，初始化方法，有多少个完全取决于第三方网络框架提供的获取数据成功或失败后返回的数据

- (instancetype)init;

- (instancetype)initWithURLSessionDataTask:(NSURLSessionDataTask * _Nullable)task responseObject:(id _Nullable)responseObject;

- (instancetype)initWithURLSessionDataTask:(NSURLSessionDataTask * _Nullable)task error:(NSError * _Nullable)error;

- (instancetype)initWithURLSessionDataTask:(NSURLSessionDataTask * _Nullable)task responseObject:(id _Nullable)responseObject error:(NSError * _Nullable)error;
@end

NS_ASSUME_NONNULL_END