//
//  CreateLimitOfflinePasswordController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/19.
//

#import "CreateLimitOfflinePasswordController.h"
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import "SiteManager.h"
#import "Alert.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSDate+Addition.h"

@interface CreateLimitOfflinePasswordController ()

@property (nonatomic, strong) IBOutlet UILabel *passwordNameLabel;
@property (nonatomic, strong) IBOutlet UIDatePicker *effectiveDatePicker;
@property (nonatomic, strong) IBOutlet UIDatePicker *invalidDatePicker;

@end

@implementation CreateLimitOfflinePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (IBAction)submitAction:(id)sender {
    if (!self.passwordNameLabel.text.length) {
        return;
    }
    
    NSTimeInterval effectiveTime = [self.effectiveDatePicker.date hourTimeStampWithOffset:0];
    NSTimeInterval invalidTime = [self.invalidDatePicker.date hourTimeStampWithOffset:0];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockPasswordManager.shared createLimitOfflinePasswordWithSiteId:SiteManager.shared.siteId
                                                              deviceId:self.devId
                                                                  name:self.passwordNameLabel.text
                                                 effectiveTimeInterval:effectiveTime
                                                   invalidTimeInterval:invalidTime
                                                               success:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:NULL];
        [NSNotificationCenter.defaultCenter postNotificationName:@"UpatePasswordList" object:nil];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error.code == ThingLockErrorAccountErrorCode) {
            [Alert showBasicAlertOnVC:self withTitle:@"Account error" message:@""];
        } else if (error.code == ThingLockErrorSiteErrorCode) {
            [Alert showBasicAlertOnVC:self withTitle:@"Site error" message:@""];
        } else if (error.code == ThingLockErrorPasswordNameErrorCode) {
            [Alert showBasicAlertOnVC:self withTitle:@"Name error" message:@""];
        } else if (error.code == ThingLockErrorEffectiveTimeErrorCode) {
            [Alert showBasicAlertOnVC:self withTitle:@"Effective error" message:@""];
        } else if (error.code == ThingLockErrorInvalidTimeTimeErrorCode) {
            [Alert showBasicAlertOnVC:self withTitle:@"Invalid error" message:@""];
        } else if (error.code == ThingLockErrorWorkDayErrorCode) {
            [Alert showBasicAlertOnVC:self withTitle:@"Work day error" message:@""];
        } else if (error.code == ThingLockErrorStartTimeErrorCode) {
            [Alert showBasicAlertOnVC:self withTitle:@"Start time error" message:@""];
        } else if (error.code == ThingLockErrorEndTimeErrorCode) {
            [Alert showBasicAlertOnVC:self withTitle:@"End time error" message:@""];
        }
    }];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        NSString *title = NSLocalizedString(@"Enter password name", nil);
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:NULL];
        
        [alertC addTextFieldWithConfigurationHandler:NULL];
        
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            self.passwordNameLabel.text = alertC.textFields.firstObject.text;
            [self.tableView reloadData];
        }];
        
        [alertC addAction:cancelAction];
        [alertC addAction:confirmAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}



@end
