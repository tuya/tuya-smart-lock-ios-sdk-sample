//
//  WeeklySelectTableViewController.h
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PeriodSelectTableViewController;

@protocol PeriodSelectTableViewControllerDelegate <NSObject>

- (void)viewController:(PeriodSelectTableViewController *)viewController didSelectPeriod:(NSArray *)period;

@end

@interface PeriodSelectTableViewController : UITableViewController

@property (nonatomic, weak) id<PeriodSelectTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray<NSNumber *> *originSelect;

@end

NS_ASSUME_NONNULL_END
