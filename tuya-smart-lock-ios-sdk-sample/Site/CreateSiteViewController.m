//
//  CreateSiteViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/6.
//

#import "CreateSiteViewController.h"
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface CreateSiteViewController ()

@property (nonatomic, strong) IBOutlet UITextField *nameTextFiled;
@property (nonatomic, strong) IBOutlet UITextField *latitudeTextFiled;
@property (nonatomic, strong) IBOutlet UITextField *longitudeTextFiled;
@property (nonatomic, strong) IBOutlet UITextField *geoNameTextFiled;

@end

@implementation CreateSiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (IBAction)saveAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingResidenceSiteManager createSiteWithName:self.nameTextFiled.text
                                         latitude:self.latitudeTextFiled.text.doubleValue
                                        longitude:self.longitudeTextFiled.text.doubleValue
                                          geoName:self.geoNameTextFiled.text
                                          success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [NSNotificationCenter.defaultCenter postNotificationName:@"UpateSiteList" object:nil];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

@end
