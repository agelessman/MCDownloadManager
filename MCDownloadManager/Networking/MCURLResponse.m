//
//  MCURLResponse.m
//  MCDownloadManager
//
//  Created by 马超 on 16/9/21.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import "MCURLResponse.h"

@interface MCURLResponse()
@property (nonatomic, copy, readwrite, nullable) id responseObject;
@property (nonatomic, copy, readwrite) NSDictionary *requestParameter; // 这里封装的应该是请求封装，请求封装中能够拿到必要的配置信息，
@property (nonatomic, assign, readwrite, getter=isCache) BOOL cache;
@property (nonatomic, strong, readwrite, nullable) NSURLSessionDataTask *task;
@property (nonatomic, strong, readwrite, nullable) NSError *error;
@end

@implementation MCURLResponse

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.status = MCURLResponseStatusNone;
    return self;
}

- (instancetype)initWithURLSessionDataTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject {
    return [self initWithURLSessionDataTask:task responseObject:responseObject error:nil];
}

- (instancetype)initWithURLSessionDataTask:(NSURLSessionDataTask *)task error:(NSError *)error {
    return [self initWithURLSessionDataTask:task responseObject:nil error:error];
}

- (instancetype)initWithURLSessionDataTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject error:(NSError *)error {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.status = MCURLResponseStatusNone;
    if (error) {
        self.error = error;
        if (error.code == -1001) {
            self.status = MCURLResponseStatusTimeout;
        }
    }
    
    if (!responseObject) {
        self.status = MCURLResponseStatusDataInvalid;
    }
    
    if (task) {
        self.task = task;
        self.URLIdentifier = task.originalRequest.URL.absoluteString;
    }
    
    self.responseObject = responseObject;
    
    return self;
}
@end
