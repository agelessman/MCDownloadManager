//
//  MCURLRequest.m
//  MCDownloadManager
//
//  Created by 马超 on 16/9/23.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import "MCURLRequest.h"

@interface MCURLRequest ()
@property (nonatomic, retain) NSOperationQueue *delegateQueue;

@end
@implementation MCURLRequest

#pragma mark - Initialization
- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    self.HTTPMethod = MCHTTPMethodGET;
    self.cacheResponse = NO;

    MCURLSessionConfiguration *configuration = [MCURLSessionConfiguration defaultURLSessionConfiguration];
    self.configuration = configuration;
    
    self.delegateQueue = [[NSOperationQueue alloc] init];

    return self;
}

+ (instancetype)URLRequestWithConfiguration:(MCURLSessionConfiguration *)configuration {
    
    MCURLRequest *request = [self init];
    if (configuration) {
        request.configuration = configuration;
    }
    return request;
}

+(instancetype)URLRequestWithConfiguration:(MCURLSessionConfiguration *)configuration delegate:(id<MCURLRequestDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    
    MCURLRequest *request = [self init];
    if (configuration) {
        request.configuration = configuration;
    }
    if (queue) {
        request.delegateQueue = queue;
    }
    return request;
}

#pragma mark - Public Methods
- (void)fetchDataWithMethod:(MCHTTPMethod)method completionHandler:(void (^)(MCURLResponse * _Nonnull))handler {
    
}
- (void)fetchDataWithMethod:(MCHTTPMethod)method progress:(void (^)(NSProgress * _Nonnull))downloadProgress completionHandler:(void (^)(MCURLResponse * _Nonnull))handler {
    
}

- (void)uploadDataWithCompletionHandler:(void (^)(MCURLResponse * _Nonnull))handler {
    
}
- (void)uploadDataWithProgress:(void (^)(NSProgress * _Nonnull))uploadProgress completionHandler:(void (^)(MCURLResponse * _Nonnull))handler {
    
}
@end
