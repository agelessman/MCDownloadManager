//
//  MCURLSessionConfiguration.h
//  MCDownloadManager
//
//  Created by 马超 on 16/9/23.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCURLSessionConfiguration : NSObject
+ (MCURLSessionConfiguration *)defaultURLSessionConfiguration;
+ (MCURLSessionConfiguration *)ephemeralURLSessionConfiguration;
+ (MCURLSessionConfiguration *)backgroundURLSessionConfigurationWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END