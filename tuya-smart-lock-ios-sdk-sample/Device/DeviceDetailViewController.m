//
//  DeviceDetailViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/1/24.
//

#import "DeviceDetailViewController.h"
#import <ThingSmartBLEMeshKit/ThingSmartBLEMeshKit.h>
#import <ThingSmartBLEKit/ThingSmartBLEKit.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import "PasswordListViewController.h"
#import "DigitalKeyListViewController.h"
#import "LogCategoryTableViewController.h"
#import "SiteManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DeviceDetailViewController ()

@property(nonatomic, strong) IBOutlet UILabel *isOnline;
@property(nonatomic, strong) IBOutlet UILabel *nameLabel;
@property(nonatomic, strong) IBOutlet UILabel *deviceIdLabel;
@property(nonatomic, strong) IBOutlet UISwitch *unlockSwitch;
@property(nonatomic, strong) IBOutlet UILabel *quantityLabel;

@property(nonatomic, strong) IBOutlet UITableViewCell *eKeyCell;
@property(nonatomic, strong) IBOutlet UITableViewCell *passwordCell;
@property(nonatomic, strong) IBOutlet UITableViewCell *logCell;
@property(nonatomic, strong) ThingLockDeviceModel *lockModel;

@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    ThingSmartDeviceModel *deviceModel = [ThingSmartDevice deviceWithDeviceId:self.devId].deviceModel;
    
    self.nameLabel.text = deviceModel.name;
    self.deviceIdLabel.text = self.devId;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice getLockDetailWithSiteId:SiteManager.shared.siteId
                                    deviceId:self.devId
                                     success:^(ThingLockDeviceModel * _Nullable lockModel) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.lockModel = lockModel;
        [self refreshView];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];


    // Start connect to device
    if (!deviceModel.isOnline) {
        [ThingSmartBLEManager.sharedInstance startListening:YES];
    } else {
        self.isOnline.text = @"Online";
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self 
                                           selector:@selector(updateDeviceState:)
                                               name:@"kNotificationDeviceOnlineUpdate"
                                             object:nil];
    
//    ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.devId];
//    ThingDeviceConnectParams *params = [[ThingDeviceConnectParams alloc] init];
//    params.sourceType = ThingDeviceConnectSourceTypeNormal;
//    params.connectType = ThingDeviceConnectTypeNormal;
//    params.connectTimeoutMills = 10000;
//    [device connectDeviceWithParams:params success:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.devId];
//            self.isOnline.text = device.deviceModel.isOnline ? @"Online" : @"Offline";
//        });
//    } failure:^(NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.devId];
//            self.isOnline.text = device.deviceModel.isOnline ? @"Online" : @"Offline";
//        });
//    }];
    
}

- (void)refreshView {
    self.quantityLabel.text = self.lockModel.electricQuantity;
    
    BOOL eKeyEnable = [self.lockModel.supportAbilities containsObject:@"e-key"];
    BOOL passcodeEnable = [self.lockModel.supportAbilities containsObject:@"offline-passcode"] && [self.lockModel.supportAbilities containsObject:@"temporary-passcode"];
    BOOL logEnable = [self.lockModel.supportAbilities containsObject:@"log"];
    
    self.eKeyCell.userInteractionEnabled = eKeyEnable;
    self.passwordCell.userInteractionEnabled = passcodeEnable;
    self.logCell.userInteractionEnabled = logEnable;
    
    self.eKeyCell.alpha = eKeyEnable ? 1.0 : 0.5;
    self.passwordCell.alpha = passcodeEnable ? 1.0 : 0.5;
    self.logCell.alpha = logEnable ? 1.0 : 0.5;
}

- (void)updateDeviceState:(NSNotification *)not {
    ThingSmartDeviceModel *device = [ThingSmartDevice deviceWithDeviceId:self.devId].deviceModel;
    self.isOnline.text = device.isOnline ? @"Online" : @"Offline";
}

- (IBAction)switchDeviceAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice.shared unLockWithSiteId:SiteManager.shared.siteId
                                    deviceId:self.devId
                                     success:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.unlockSwitch.on = YES;
        [self refreshView];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.unlockSwitch.on = YES;
        [self refreshView];
        [self.tableView reloadData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:DigitalKeyListViewController.class]) {
        ((DigitalKeyListViewController *)segue.destinationViewController).devId = self.devId;
    } else if ([segue.destinationViewController isKindOfClass:PasswordListViewController.class]) {
        ((PasswordListViewController *)segue.destinationViewController).devId = self.devId;
    } else if ([segue.destinationViewController isKindOfClass:LogCategoryTableViewController.class]) {
        ((LogCategoryTableViewController *)segue.destinationViewController).devId = self.devId;
    }

}

#pragma mark -

//- (void)home:(ThingSmartHome *)home device:(ThingSmartDeviceModel *)device dpsUpdate:(NSDictionary *)dps {
//    self.isOnline.text = device.isOnline ? @"Online" : @"Offline";
//}
//
//- (void)onCentralDidDisconnectFromDevice:(NSString *)devId error:(NSError *)error {
//    ThingSmartDeviceModel *device = [ThingSmartDevice deviceWithDeviceId:devId].deviceModel;
//    self.isOnline.text = device.isOnline ? @"Online" : @"Offline";
//}

#pragma mark - UITableView


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.devId];
        [device resetFactory:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            [NSNotificationCenter.defaultCenter postNotificationName:@"UpateDeviceList" object:nil];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else if (indexPath.row == [tableView numberOfRowsInSection:0] - 2) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.devId;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    BOOL eKeyEnable = [self.lockModel.supportAbilities containsObject:@"e-key"];
//    BOOL passcodeEnable = [self.lockModel.supportAbilities containsObject:@"offline-passcode"] && [self.lockModel.supportAbilities containsObject:@"temporary-passcode"];
//    BOOL logEnable = [self.lockModel.supportAbilities containsObject:@"log"];
//    
//    self.eKeyCell.userInteractionEnabled = eKeyEnable;
//    self.passwordCell.userInteractionEnabled = passcodeEnable;
//    self.logCell.userInteractionEnabled = logEnable;
//    
//    self.eKeyCell.alpha = eKeyEnable ? 1.0 : 0.5;
//    self.passwordCell.alpha = passcodeEnable ? 1.0 : 0.5;
//    self.logCell.alpha = logEnable ? 1.0 : 0.5;
}

@end
