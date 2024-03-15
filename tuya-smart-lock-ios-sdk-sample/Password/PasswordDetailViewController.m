//
//  PasswordDetailViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/7.
//

#import "PasswordDetailViewController.h"
#import "PeriodSelectTableViewController.h"
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import <YYModel/YYModel.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SiteManager.h"

@interface PasswordDetailViewController ()

@property( nonatomic, strong) IBOutlet UILabel *nameLabel;
@property( nonatomic, strong) IBOutlet UILabel *passwordLabel;
@property( nonatomic, strong) IBOutlet UILabel *typeLabel;
@property( nonatomic, strong) IBOutlet UILabel *createrLabel;

@property( nonatomic, strong) IBOutlet UIDatePicker *effectiveTimeDatePicker;
@property( nonatomic, strong) IBOutlet UIDatePicker *invalidTimeDatePicker;
@property( nonatomic, strong) IBOutlet UIDatePicker *startTimeDatePicker;
@property( nonatomic, strong) IBOutlet UIDatePicker *endTimeDatePicker;

@property( nonatomic, strong) ThingLockPasswordModel *passwordModel;

@end

@implementation PasswordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
}

- (void)loadData {
    
    NSDictionary *typeDic = @{
        @(LockPasswordLimitOnlineType): NSLocalizedString(@"Limit online password", nil),
        @(LockPasswordOnceOfflineType): NSLocalizedString(@"Once time password", nil),
        @(LockPasswordLimitOfflineType): NSLocalizedString(@"Limit offline password", nil),
        @(LockPasswordPermanentOnlineType): NSLocalizedString(@"Permanent password", nil),
    };
    
    
    long long siteId = SiteManager.shared.siteId;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockPasswordManager.shared getPasswordDetailWithSiteId:siteId
                                                    deviceId:self.devId
                                                  passwordId:self.password_id
                                                     success:^(ThingLockPasswordModel * _Nullable passwordModel) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.passwordModel = passwordModel;
        self.nameLabel.text = passwordModel.passwordName;
        self.typeLabel.text = typeDic[@(passwordModel.passwordType)];
        self.createrLabel.text = passwordModel.operatorName;
        self.passwordLabel.text = passwordModel.password;
        
        ThingLiveCycleModel *liveCycle = passwordModel.liveCycle;
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
        
        NSArray<NSString *> *startMinuteList = [liveCycle.startMinute componentsSeparatedByString:@":"];
        
        [components setHour:startMinuteList.firstObject.integerValue];
        [components setMinute:startMinuteList.lastObject.integerValue];
        components.timeZone = NSTimeZone.localTimeZone;
        NSDate *startDate = [calendar dateFromComponents:components];
        self.startTimeDatePicker.date = startDate;
        
        NSArray<NSString *> *endMinuteList = [liveCycle.endMinute componentsSeparatedByString:@":"];
        [components setHour:endMinuteList.firstObject.integerValue];
        [components setMinute:endMinuteList.lastObject.integerValue];
        NSDate *endtDate = [calendar dateFromComponents:components];
        self.endTimeDatePicker.date = endtDate;
        
        self.effectiveTimeDatePicker.date = [NSDate dateWithTimeIntervalSince1970:liveCycle.effectiveTimeInterval];
        self.invalidTimeDatePicker.date = [NSDate dateWithTimeIntervalSince1970:liveCycle.invalidTimeInterval];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *period = self.passwordModel.liveCycle.workingDay;
    
    NSMutableArray *periodList = [NSMutableArray arrayWithCapacity:period.length];
    for (NSUInteger i = 0; i < [period length]; i++) {
        NSString *digit = [period substringWithRange:NSMakeRange(i, 1)];
        [periodList addObject:@(digit.boolValue)];
    }
    
    ((PeriodSelectTableViewController *)segue.destinationViewController).originSelect = periodList.copy;
    ((PeriodSelectTableViewController *)segue.destinationViewController).tableView.allowsSelection = NO;
}

- (IBAction)deleteAction:(UIBarButtonItem *)sender {
    sender.customView.userInteractionEnabled = NO;
    long long siteId = SiteManager.shared.siteId;
    NSString *passwordId = self.passwordModel.passwordId;
    NSString *lockId = self.passwordModel.lockId;
    LockPasswordType type = self.passwordModel.passwordType;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (type == LockPasswordLimitOnlineType || type == LockPasswordPermanentOnlineType) {
        [ThingLockPasswordManager.shared removeOnlinePasswordWithSiteId:siteId
                                                            deviceId:self.devId
                                                          passwordId:passwordId
                                                              lockId:lockId
                                                             success:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            [NSNotificationCenter.defaultCenter postNotificationName:@"UpatePasswordList" object:nil];
        } failure:^(NSError *error) {
            sender.customView.userInteractionEnabled = YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else if (type == LockPasswordOnceOfflineType) {
        [ThingLockPasswordManager.shared removeOnceOfflinePasswordWithSiteId:siteId
                                                            deviceId:self.devId
                                                          passwordId:passwordId
                                                             success:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            [NSNotificationCenter.defaultCenter postNotificationName:@"UpatePasswordList" object:nil];
        } failure:^(NSError *error) {
            sender.customView.userInteractionEnabled = YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else {
        [ThingLockPasswordManager.shared removeLimitOfflinePasswordWithSiteId:siteId
                                                                  deviceId:self.devId
                                                                passwordId:passwordId
                                                                   success:^(NSString *result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            // 补充文案
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@""
                                                                            message:result
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popViewControllerAnimated:YES];
                [NSNotificationCenter.defaultCenter postNotificationName:@"UpatePasswordList" object:nil];
            }];
            
            [alertC addAction:confirmAction];
            [self presentViewController:alertC animated:YES completion:nil];
            
        } failure:^(NSError *error) {
            sender.customView.userInteractionEnabled = YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

#pragma mark - UITableView
     
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LockPasswordType type = self.passwordModel.passwordType;
    if (type == LockPasswordOnceOfflineType || type == LockPasswordPermanentOnlineType) {
        return 1;
    } else if (type == LockPasswordLimitOfflineType) {
        return 2;
    } else {
        return 3;
    }
}
     
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSString *title = NSLocalizedString(@"Enter name", nil);
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:NULL];
        
        [alertC addTextFieldWithConfigurationHandler:NULL];
        
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            self.nameLabel.text = alertC.textFields.firstObject.text;
            [self.tableView reloadData];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [ThingLockPasswordManager.shared modifyPasswordSiteId:SiteManager.shared.siteId
                                                         deviceId:self.devId
                                                       passwordId:self.passwordModel.passwordId
                                                     passwordName:self.nameLabel.text
                                                          success:^(id result) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }];
        alertC.textFields.firstObject.clearButtonMode = UITextFieldViewModeWhileEditing;
        alertC.textFields.firstObject.text = self.nameLabel.text;
        [alertC addAction:cancelAction];
        [alertC addAction:confirmAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

@end
