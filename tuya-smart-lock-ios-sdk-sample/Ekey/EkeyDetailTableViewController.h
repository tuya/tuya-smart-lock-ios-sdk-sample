//
//  EkeyDetailTableViewController.h
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EkeyDetailTableViewController : UITableViewController

@property (nonatomic, strong) NSString *devId;
@property (nonatomic, strong) NSString *eKeyId;

@end

NS_ASSUME_NONNULL_END
