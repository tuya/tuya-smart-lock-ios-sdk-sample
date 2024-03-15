//
//  RegisterTableViewController.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import "RegisterTableViewController.h"
#import "Alert.h"
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>

@interface RegisterTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;

@end

@implementation RegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - IBAction

- (IBAction)sendVerificationCode:(UIButton *)sender {
    [[ThingSmartUser sharedInstance] sendVerifyCodeWithUserName:self.accountTextField.text region:[[ThingSmartUser sharedInstance] getDefaultRegionWithCountryCode:self.countryCodeTextField.text] countryCode:self.countryCodeTextField.text type:1 success:^{
        [Alert showBasicAlertOnVC:self withTitle:@"Verification Code Sent Successfully" message:@"Please check your message for the code."];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"Failed to Sent Verification Code" message:error.localizedDescription];
    }];
}

- (IBAction)registerTapped:(UIButton *)sender {
    if ([self.accountTextField.text containsString:@"@"]) {
        [[ThingSmartUser sharedInstance] registerByEmail:self.countryCodeTextField.text email:self.accountTextField.text password:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registered Successfully"
                                                                                     message:@"Please navigate back to login your account."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }];
            [alertController addAction:action];
            
            [self presentViewController:alertController animated:true completion:nil];
            
            
            
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Register" message:error.localizedDescription];
        }];
    } else {
        [[ThingSmartUser sharedInstance] registerByPhone:self.countryCodeTextField.text phoneNumber:self.accountTextField.text password:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registered Successfully"
                                                                                     message:@"Please navigate back to login your account."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }];
            [alertController addAction:action];
            
            [self presentViewController:alertController animated:true completion:nil];
            
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Register" message:error.localizedDescription];
        }];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 4) {
        [self sendVerificationCode:nil];
    } else if (indexPath.section == 1) {
        [self registerTapped:nil];
    }
}
@end
