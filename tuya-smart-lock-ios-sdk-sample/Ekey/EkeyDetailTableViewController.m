//
//  EkeyDetailTableViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/26.
//

#import "EkeyDetailTableViewController.h"
#import "PeriodSelectTableViewController.h"
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SiteManager.h"
#import "NSDate+Addition.h"

@interface EkeyDetailTableViewController ()<PeriodSelectTableViewControllerDelegate>

@property( nonatomic, strong) IBOutlet UIBarButtonItem *updateButtonItem;

@property( nonatomic, strong) IBOutlet UILabel *accountLabel;
@property( nonatomic, strong) IBOutlet UILabel *nameLabel;
@property( nonatomic, strong) IBOutlet UILabel *typeLabel;
@property( nonatomic, strong) IBOutlet UILabel *createrLabel;

@property( nonatomic, strong) IBOutlet UIDatePicker *effectiveTimeDatePicker;
@property( nonatomic, strong) IBOutlet UIDatePicker *invalidTimeDatePicker;
@property( nonatomic, strong) IBOutlet UIDatePicker *startTimeDatePicker;
@property( nonatomic, strong) IBOutlet UIDatePicker *endTimeDatePicker;

@property( nonatomic, strong) ThingEKeyModel *eKeyModel;
@property (nonatomic, strong) NSArray *periodSelectList;

@end

@implementation EkeyDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    long long siteId = SiteManager.shared.siteId;
    [ThingLockDevice getEKeyDetailWithSiteId:siteId
                                    deviceId:self.devId
                                      eKeyId:self.eKeyId
                                     success:^(ThingEKeyModel * _Nullable eKeyModel) {
        
        self.eKeyModel = eKeyModel;
        
        self.accountLabel.text = eKeyModel.account;
        self.nameLabel.text = eKeyModel.name;
        self.typeLabel.text = eKeyModel.type;
        self.createrLabel.text = eKeyModel.operatorName;
        
        ThingLiveCycleModel *liveCycle = eKeyModel.liveCycle;
        
        
        NSString *period = liveCycle.workingDay;
        
        NSMutableArray *periodList = [NSMutableArray arrayWithCapacity:period.length];
        for (NSUInteger i = 0; i < [period length]; i++) {
            NSString *digit = [period substringWithRange:NSMakeRange(i, 1)];
            [periodList addObject:@(digit.boolValue)];
        }
        self.periodSelectList = periodList.copy;
        
        
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
        
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:PeriodSelectTableViewController.class]) {
        ((PeriodSelectTableViewController *)segue.destinationViewController).delegate = self;
        ((PeriodSelectTableViewController *)segue.destinationViewController).originSelect = self.periodSelectList;
    }
}

- (IBAction)deleteAction:(UIBarButtonItem *)sender {
    sender.customView.userInteractionEnabled = NO;
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice removeEKeyWithSiteId:siteId
                                 deviceId:self.devId
                                   eKeyId:self.eKeyId
                                  success:^(id _Nullable result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [NSNotificationCenter.defaultCenter postNotificationName:@"UpateEKeyList" object:nil];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)updateAction:(UIBarButtonItem *)sender {
//    sender.customView.userInteractionEnabled = NO;
    if ([self.eKeyModel.type isEqualToString:@"periodicity"]) {
        [self updateLimitEKey];
    } else if ([self.eKeyModel.type isEqualToString:@"once"]) {
        [self updateOnceEKey];
    } else {
        [self updatePermanenttEKey];
    }
}

- (void)updateLimitEKey {
    long long siteId = SiteManager.shared.siteId;
    NSString *workingDay = [self.periodSelectList componentsJoinedByString:@""];
    NSTimeInterval effectiveTime = [self.effectiveTimeDatePicker.date hourTimeStampWithOffset:0];
    NSTimeInterval invalidTime = [self.invalidTimeDatePicker.date hourTimeStampWithOffset:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSString *startMinute = [formatter stringFromDate:self.startTimeDatePicker.date];
    NSString *endMinute = [formatter stringFromDate:self.endTimeDatePicker.date];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice updateLimitEKeyWithSiteId:siteId
                                      deviceId:self.devId
                                        eKeyId:self.eKeyModel.eKeyId
                                      eKeyName:self.nameLabel.text
                         effectiveTimeInterval:effectiveTime
                           invalidTimeInterval:invalidTime
                                    workingDay:workingDay
                                     startTime:startMinute
                                       endTime:endMinute
                                       success:^(id _Nullable result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [NSNotificationCenter.defaultCenter postNotificationName:@"UpateEKeyList" object:nil];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)updatePermanenttEKey {
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice updatePermanentEKeyWithSiteId:siteId
                                          deviceId:self.devId
                                            eKeyId:self.eKeyModel.eKeyId
                                          eKeyName:self.nameLabel.text
                                           success:^(id _Nullable result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [NSNotificationCenter.defaultCenter postNotificationName:@"UpateEKeyList" object:nil];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)updateOnceEKey {
    long long siteId = SiteManager.shared.siteId;
    NSTimeInterval effectiveTime = [self.effectiveTimeDatePicker.date hourTimeStampWithOffset:0];
    NSTimeInterval invalidTime = [self.invalidTimeDatePicker.date hourTimeStampWithOffset:0];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice updateOnceEKeyWithSiteId:siteId
                                     deviceId:self.devId
                                       eKeyId:self.eKeyModel.eKeyId
                                     eKeyName:self.nameLabel.text
                        effectiveTimeInterval:effectiveTime
                          invalidTimeInterval:invalidTime
                                      success:^(id _Nullable result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [NSNotificationCenter.defaultCenter postNotificationName:@"UpateEKeyList" object:nil];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - PeriodSelectTableViewControllerDelegate

- (void)viewController:(PeriodSelectTableViewController *)viewController didSelectPeriod:(NSArray *)period {
    self.periodSelectList = period;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.eKeyModel.type isEqualToString:@"periodicity"]) {
        return 3;
    } else if ([self.eKeyModel.type isEqualToString:@"once"]) {
        return 2;
    } else {
        return 1;
    }
}
     
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSString *title = NSLocalizedString(@"Enter EKey name", nil);
        
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
        }];
        alertC.textFields.firstObject.clearButtonMode = UITextFieldViewModeWhileEditing;
        alertC.textFields.firstObject.text = self.nameLabel.text;
        [alertC addAction:cancelAction];
        [alertC addAction:confirmAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

@end
