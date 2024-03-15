//
//  LogCategoryTableViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/4.
//

#import "LogCategoryTableViewController.h"
#import "DeviceLogListViewController.h"

@interface LogCategoryTableViewController ()

@end

@implementation LogCategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![sender isKindOfClass:UITableViewCell.class]) {
        return;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    ((DeviceLogListViewController *)segue.destinationViewController).indexPath = indexPath;
    ((DeviceLogListViewController *)segue.destinationViewController).devId = self.devId;
}

@end
