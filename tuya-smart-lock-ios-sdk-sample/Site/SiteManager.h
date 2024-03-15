//
//  SiteManager.h
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SiteManager : NSObject

@property (nonatomic, assign) long long siteId;

+ (instancetype)shared;


@end

NS_ASSUME_NONNULL_END
