//
//  MCWiFiManager.h
//  MCDownloadManager
//
//  Created by 马超 on 16/9/14.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCWiFi : NSObject
@property (nonatomic, copy, readonly, nullable)NSString *wifiName;
@property (nonatomic, copy, readonly, nullable)NSString *wifiBSSID;

- (instancetype)initWithName:(NSString *)name BSSID:(NSString *)bssid;
@end


@interface MCWiFiManager : NSObject

/**
 The shared default instance of `MCWiFiManager` initialized with default values.
 */
+ (instancetype)defaultInstance;

/**
 Default initializer
 
 @return An instance of `MCWiFiManager` initialized with default values.
 */
- (instancetype)init;


- (void)scanNetworksWithCompletionHandler:(void(^_Nullable)(NSArray <MCWiFi *>* _Nullable networks, MCWiFi *_Nullable currentWiFi, NSError *_Nullable error))handler;


- (NSString *)getGatewayIpForCurrentWiFi;

/**
 *  Get the local info for currentWifi except for GatewayIp
 *
 *  @return NSDictionary
 *  {
     broadcast = "192.168.8.233";
     interface = en0;
     localIp = "192.168.5.140";
     netmask = "255.255.255.0";
     }
 */
- (NSDictionary *)getLocalInfoForCurrentWiFi;
@end

NS_ASSUME_NONNULL_END