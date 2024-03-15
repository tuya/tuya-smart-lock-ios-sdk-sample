//
//  DeviceLogListViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/4.
//

#import "DeviceLogListViewController.h"
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <MJRefresh/MJRefresh.h>
#import "SiteManager.h"

@interface DeviceLogListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property( nonatomic, strong) IBOutlet UITableView *tableView;
@property( nonatomic, strong) NSMutableArray<ThingLockActionModel *> *dataArray;
@property( nonatomic, strong) NSString *sortValues;

@end

@implementation DeviceLogListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer.hidden = YES;
    self.tableView.mj_footer = footer;
    [self loadData];
    
}

- (void)loadMoreData {
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.indexPath.row == 0) {
        // Opening records
        [ThingLockDevice getOpenRecordsWithSiteId:siteId
                                         deviceId:self.devId
                                       sortValues:self.sortValues
                                         pageSize:20
                                          success:^(NSArray<ThingLockActionModel *> * _Nullable list, NSString * _Nullable sortValues) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.dataArray addObjectsFromArray:list];
            self.sortValues = sortValues;
            [self.tableView reloadData];
            if (self.tableView.mj_footer.isRefreshing) {
                list.count < 20 ? [self.tableView.mj_footer endRefreshingWithNoMoreData] : [self.tableView.mj_footer endRefreshing];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
    } else if (self.indexPath.row == 1) {
        // Operation records
        [ThingLockDevice getOperateRecordsWithSiteId:siteId
                                            deviceId:self.devId
                                       sortValues:self.sortValues
                                         pageSize:20
                                          success:^(NSArray<ThingLockActionModel *> * _Nullable list, NSString * _Nullable sortValues) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.dataArray addObjectsFromArray:list];
            self.sortValues = sortValues;
            [self.tableView reloadData];
            if (self.tableView.mj_footer.isRefreshing) {
                list.count < 20 ? [self.tableView.mj_footer endRefreshingWithNoMoreData] : [self.tableView.mj_footer endRefreshing];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else {
        // Alarm records
        [ThingLockDevice getAlarmRecordsWithSiteId:siteId
                                         deviceId:self.devId
                                       sortValues:self.sortValues
                                         pageSize:20
                                          success:^(NSArray<ThingLockActionModel *> * _Nullable list, NSString * _Nullable sortValues) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.dataArray addObjectsFromArray:list];
            self.sortValues = sortValues;
            [self.tableView reloadData];
            if (self.tableView.mj_footer.isRefreshing) {
                list.count < 20 ? [self.tableView.mj_footer endRefreshingWithNoMoreData] : [self.tableView.mj_footer endRefreshing];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

- (void)loadData {
    self.sortValues = @"";
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.indexPath.row == 0) {
        // Opening records
        [ThingLockDevice getOpenRecordsWithSiteId:siteId
                                         deviceId:self.devId
                                       sortValues:self.sortValues
                                         pageSize:20
                                          success:^(NSArray<ThingLockActionModel *> * _Nullable list, NSString * _Nullable sortValues) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.dataArray addObjectsFromArray:list];
            self.sortValues = sortValues;
            [self.tableView reloadData];
            self.tableView.mj_footer.hidden = list.count < 20;
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
    } else if (self.indexPath.row == 1) {
        // Operation records
        [ThingLockDevice getOperateRecordsWithSiteId:siteId
                                            deviceId:self.devId
                                       sortValues:self.sortValues
                                         pageSize:20
                                          success:^(NSArray<ThingLockActionModel *> * _Nullable list, NSString * _Nullable sortValues) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.dataArray addObjectsFromArray:list];
            self.sortValues = sortValues;
            [self.tableView reloadData];
            self.tableView.mj_footer.hidden = list.count < 20;
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else {
        // Alarm records
        [ThingLockDevice getAlarmRecordsWithSiteId:siteId
                                         deviceId:self.devId
                                       sortValues:self.sortValues
                                         pageSize:20
                                          success:^(NSArray<ThingLockActionModel *> * _Nullable list, NSString * _Nullable sortValues) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.dataArray addObjectsFromArray:list];
            self.sortValues = sortValues;
            [self.tableView reloadData];
            self.tableView.mj_footer.hidden = list.count < 20;
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row].type;
    NSTimeInterval timeInterval = self.dataArray[indexPath.row].time/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    cell.detailTextLabel.text = [formatter stringFromDate:date];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
@end
