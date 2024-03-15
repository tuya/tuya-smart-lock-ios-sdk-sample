//
//  CreateOnceEKeyViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/29.
//

#import "CreateOnceEKeyViewController.h"
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import "PeriodSelectTableViewController.h"
#import "SiteManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSDate+Addition.h"

@interface CreateOnceEKeyViewController ()


@property (nonatomic, strong) IBOutlet UILabel *eKeyNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *accountLabel;
@property (nonatomic, strong) IBOutlet UIDatePicker *effectiveDatePicker;
@property (nonatomic, strong) IBOutlet UIDatePicker *invalidDatePicker;

@end

@implementation CreateOnceEKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)submitAction:(id)sender {
    if (!self.accountLabel.text.length ||
        !self.eKeyNameLabel.text.length) {
        return;
    }
    
    NSTimeInterval effectiveTime = [self.effectiveDatePicker.date hourTimeStampWithOffset:0];
    NSTimeInterval invalidTime = [self.invalidDatePicker.date hourTimeStampWithOffset:0];
    

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice createOnceEKeyWithSiteId:SiteManager.shared.siteId
                                      deviceId:self.devId
                                       account:self.accountLabel.text
                                      eKeyName:self.eKeyNameLabel.text
                         effectiveTimeInterval:effectiveTime
                           invalidTimeInterval:invalidTime
                                       success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:NULL];
        [NSNotificationCenter.defaultCenter postNotificationName:@"UpateEKeyList" object:nil];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
}

#pragma mark - Table

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter account name", nil)
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:NULL];
        
        [alertC addTextFieldWithConfigurationHandler:NULL];
        
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            self.accountLabel.text = alertC.textFields.firstObject.text;
            [self.tableView reloadData];
        }];
        
        [alertC addAction:cancelAction];
        [alertC addAction:confirmAction];
        [self presentViewController:alertC animated:YES completion:nil];
    } else if (indexPath.row == 1) {
        NSString *title = NSLocalizedString(@"Enter EKey name", nil);
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:NULL];
        
        [alertC addTextFieldWithConfigurationHandler:NULL];
        
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            self.eKeyNameLabel.text = alertC.textFields.firstObject.text;
            [self.tableView reloadData];
        }];
        
        [alertC addAction:cancelAction];
        [alertC addAction:confirmAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}


@end
