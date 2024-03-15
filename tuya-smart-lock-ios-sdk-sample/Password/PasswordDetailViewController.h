//
//  PasswordDetailViewController.h
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PasswordDetailViewController : UITableViewController

@property (nonatomic, strong) NSString *devId;
@property (nonatomic, strong) NSString *password_id;

@end

NS_ASSUME_NONNULL_END
