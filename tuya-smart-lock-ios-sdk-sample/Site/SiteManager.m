//
//  SiteManager.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/5.
//

#import "SiteManager.h"

@implementation SiteManager

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end
