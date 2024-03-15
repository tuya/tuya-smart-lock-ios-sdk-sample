//
//  BLEDeviceActiveViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/5.
//

#import "BLEDeviceActiveViewController.h"
#import <ThingSmartBLECoreKit/ThingSmartBLECoreKit.h>
#import <ThingSmartBLEKit/ThingSmartBLEKit.h>
#import "SiteManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>

@interface BLEDeviceActiveViewController ()<UITableViewDelegate, UITableViewDataSource, ThingSmartBLEManagerDelegate, ThingSmartBLEActiveDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ThingBLEAdvModel *> *dataArray;

@end

@implementation BLEDeviceActiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
}

- (IBAction)searchAction:(id)sender {
    ThingSmartBLEManager.sharedInstance.delegate = self;
    [ThingSmartBLEManager.sharedInstance startListening:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [ThingSmartBLEManager sharedInstance].delegate = nil;
    [ThingSmartBLEManager.sharedInstance stopListening:YES];
}


- (void)didDiscoveryDeviceWithDeviceInfo:(ThingBLEAdvModel *)deviceInfo {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // 成功扫描到未激活的设备
    // 若设备已激活，则不会走此回调，且会自动进行激活连接
    NSUInteger index = [self.dataArray indexOfObjectPassingTest:^BOOL(ThingBLEAdvModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.uuid isEqualToString:deviceInfo.uuid];
    }];
    if (index != NSNotFound) {
        [self.dataArray replaceObjectAtIndex:index withObject:deviceInfo];
    } else {
        [self.dataArray addObject:deviceInfo];
    }
    [self.tableView reloadData];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    ThingBLEAdvModel *deviceInfo = self.dataArray[indexPath.row];
    cell.textLabel.text = deviceInfo.uuid;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ThingBLEAdvModel *deviceInfo = self.dataArray[indexPath.row];
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingBLELockActivator.shared activeBLELock:deviceInfo
                                         siteId:siteId
                                        success:^(ThingSmartDeviceModel * _Nonnull deviceModel) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [NSNotificationCenter.defaultCenter postNotificationName:@"UpateDeviceList" object:nil];
    } failure:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

@end

