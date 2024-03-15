//
//  MeTableViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/6.
//

#import "MeTableViewController.h"
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SiteManager.h"

@interface MeTableViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nicknameLabel;
@property (nonatomic, strong) IBOutlet UILabel *accountLabel;

@end

@implementation MeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nicknameLabel.text = ThingSmartUser.sharedInstance.nickname;
    self.accountLabel.text = ThingSmartUser.sharedInstance.userName;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if (!ThingSmartUser.sharedInstance.isLogin) {
        self.nicknameLabel.text = @"";
        self.accountLabel.text = @"";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:NSBundle.mainBundle];
        [self.tabBarController presentViewController:storyboard.instantiateInitialViewController
                                            animated:YES
                                          completion:NULL];
        return;
    } else {
        self.nicknameLabel.text = ThingSmartUser.sharedInstance.nickname;
        self.accountLabel.text = ThingSmartUser.sharedInstance.userName;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [ThingSmartUser.sharedInstance loginOut:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tabBarController setSelectedIndex:0];
            if ([self.tabBarController.selectedViewController isKindOfClass:UINavigationController.class]) {
                [(UINavigationController *)self.tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
            }
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:NSBundle.mainBundle];
            [self.tabBarController presentViewController:storyboard.instantiateInitialViewController
                               animated:YES
                             completion:NULL];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ThingSmartUser.sharedInstance.isLogin ? 3 : 0;
}

@end
