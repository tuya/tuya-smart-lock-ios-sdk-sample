//
//  AppDelegate.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/1/23.
//

#import "AppDelegate.h"
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

NSString *const TY_APP_KEY = @"";
NSString *const TY_SECRET_KEY = @"";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    ThingSmartSDK.sharedInstance.debugMode = YES;
    [ThingSmartSDK.sharedInstance startWithAppKey:TY_APP_KEY secretKey:TY_SECRET_KEY];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
