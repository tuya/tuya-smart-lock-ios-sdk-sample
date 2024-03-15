//
//  DeviceListViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/1/23.
//

#import "DeviceListViewController.h"
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import "DeviceDetailViewController.h"
#import "SiteManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MJRefresh/MJRefresh.h>

@interface DeviceListViewController () <UITableViewDelegate, UITableViewDataSource>

@property( nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSString *> *dataArray;
@property (nonatomic, assign) NSInteger lastIndex;


@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer.hidden = YES;
    self.tableView.mj_footer = footer;
    [self loadData];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(loadData)
                                               name:@"UpateDeviceList"
                                             object:nil];
}

- (void)loadData {
    self.lastIndex = 0;
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingResidenceSiteManager getLockDeviceListWithSiteId:siteId
                                                  category:@"lock"
                                                  pageSize:20
                                                   startId:self.lastIndex
                                                   success:^(NSArray<NSString *> * _Nullable deviceIdList, NSInteger lastIndex) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:deviceIdList];
        self.lastIndex = lastIndex;
        [self.tableView reloadData];
        self.tableView.mj_footer.hidden = deviceIdList.count < 20;
        [self.tableView.mj_footer resetNoMoreData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)loadMoreData {
    long long siteId = SiteManager.shared.siteId;
    [ThingResidenceSiteManager getLockDeviceListWithSiteId:siteId
                                                  category:@"lock"
                                                  pageSize:20
                                                   startId:self.lastIndex
                                                   success:^(NSArray<NSString *> * _Nullable deviceIdList, NSInteger lastIndex) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.dataArray addObjectsFromArray:deviceIdList];
        self.lastIndex = lastIndex;
        [self.tableView reloadData];
        if (self.tableView.mj_footer.isRefreshing) {
            deviceIdList.count < 20 ? [self.tableView.mj_footer endRefreshingWithNoMoreData] : [self.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DeviceDetailViewController *detailViewController = segue.destinationViewController;
    if ([sender isKindOfClass:UITableViewCell.class]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSString *devId = self.dataArray[indexPath.row];
        detailViewController.devId = devId;
    }
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *devId = self.dataArray[indexPath.row];
    ThingSmartDeviceModel *deviceModel = [ThingSmartDevice deviceWithDeviceId:devId].deviceModel;
    cell.textLabel.text = deviceModel.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *devId = model[@"deviceId"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

@end
