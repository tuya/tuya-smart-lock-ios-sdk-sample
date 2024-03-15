//
//  LoginTableViewController.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import "LoginTableViewController.h"
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import "Alert.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LoginTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
//@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.countryCodeTextField.text = @"86";

}

#pragma mark - IBAction

- (IBAction)login:(UIButton *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if ([self.accountTextField.text containsString:@"@"]) {
        [ThingSmartUser.sharedInstance loginByEmail:self.countryCodeTextField.text
                                              email:self.accountTextField.text
                                           password:self.passwordTextField.text
                                            success:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                [NSNotificationCenter.defaultCenter postNotificationName:@"UpateSiteList" object:nil];
            }];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else {
        [ThingSmartUser.sharedInstance loginByPhone:self.countryCodeTextField.text
                                        phoneNumber:self.accountTextField.text
                                           password:self.passwordTextField.text
                                            success:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                [NSNotificationCenter.defaultCenter postNotificationName:@"UpateSiteList" object:nil];
            }];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self login:nil];
    } else if (indexPath.section == 2) {
//        [self.forgetPasswordButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
