//
//  PasswordListViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/7.
//

#import "PasswordListViewController.h"
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import "PasswordDetailViewController.h"
#import "CreateLimitOnlinePasswordController.h"
#import "CreateLimitOfflinePasswordController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import "SiteManager.h"
#import <MJRefresh/MJRefresh.h>
#import "Alert.h"

@interface PasswordListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property( nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ThingLockPasswordModel *> *dataArray;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addBarItem;
@property (nonatomic, assign) NSInteger pageNo;

@end

@implementation PasswordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer.hidden = YES;
    self.tableView.mj_footer = footer;
    
    [self configMenu];
    [self loadData];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadData) name:@"UpatePasswordList" object:nil];
}

- (void)configMenu {
    // 创建菜单项
    UIAction *action1 = [UIAction actionWithTitle:NSLocalizedString(@"Permanent", nil) image:nil identifier:nil handler:^(UIAction* action) {
        [self createPermanentPassword];
    }];
    UIAction *action2 = [UIAction actionWithTitle:NSLocalizedString(@"Once", nil) image:nil identifier:nil handler:^(UIAction* action) {
        [self createOncePassword];
    }];
    
    // 创建子菜单
    UIAction *submenuAction1 = [UIAction actionWithTitle:NSLocalizedString(@"Online limit password", nil) image:nil identifier:nil handler:^(UIAction* action) {
        [self createLimitOnlinePassword];
    }];
    UIAction *submenuAction2 = [UIAction actionWithTitle:NSLocalizedString(@"Offline limit password", nil) image:nil identifier:nil handler:^(UIAction* action) {
        [self createLimitOfflinePassword];
    }];
    UIMenu *submenu = [UIMenu menuWithTitle:NSLocalizedString(@"Limit password", nil) children:@[submenuAction1, submenuAction2]];
    
    // 创建根菜单
    UIMenu *rootMenu = [UIMenu menuWithTitle:@"" children:@[submenu, action1, action2]];
    
    // 显示菜单
    self.addBarItem.menu = rootMenu;
}

- (void)loadData {
    self.pageNo = 1;
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockPasswordManager.shared getPasswordListWithSiteId:siteId
                                                      deviceId:self.devId
                                                    pageNumber:self.pageNo
                                                      pageSize:20
                                                       success:^(NSArray<ThingLockPasswordModel *> * _Nullable list, NSInteger totalSize) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:list];
        [self.tableView reloadData];
        self.tableView.mj_footer.hidden = list.count < 20;
        [self.tableView.mj_footer resetNoMoreData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)loadMoreData {
    long long siteId = SiteManager.shared.siteId;
    self.pageNo++;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockPasswordManager.shared getPasswordListWithSiteId:siteId
                                                      deviceId:self.devId
                                                    pageNumber:self.pageNo
                                                      pageSize:20
                                                       success:^(NSArray<ThingLockPasswordModel *> * _Nullable list, NSInteger totalSize) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.dataArray addObjectsFromArray:list];
        [self.tableView reloadData];
        if (self.tableView.mj_footer.isRefreshing) {
            list.count < 20 ? [self.tableView.mj_footer endRefreshingWithNoMoreData] : [self.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)createOncePassword {
    
    NSString *title = NSLocalizedString(@"Create password", nil);
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:NULL];
    
    [alertC addTextFieldWithConfigurationHandler:NULL];
    
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [ThingLockPasswordManager.shared createOnceOfflinePasswordWithSiteId:SiteManager.shared.siteId
                                                          deviceId:self.devId
                                                              name:alertC.textFields.firstObject.text
                                                           success:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self loadData];
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
    }];
    
    [alertC addAction:cancelAction];
    [alertC addAction:confirmAction];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)createPermanentPassword {
    NSString *title = NSLocalizedString(@"Input password name", nil);
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:NULL];
    
    [alertC addTextFieldWithConfigurationHandler:NULL];
    
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        
        [ThingLockPasswordManager.shared createPermanentOnlinePasswordWithSiteId:SiteManager.shared.siteId
                                                               deviceId:self.devId
                                                                   name:alertC.textFields.firstObject.text
                                                                success:^{
            [self loadData];
        } failure:^(NSError *error) {
            
        }];
    }];
    
    [alertC addAction:cancelAction];
    [alertC addAction:confirmAction];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)createLimitOnlinePassword {
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateLimitOnlinePassword"];
    ((CreateLimitOnlinePasswordController *)nav.viewControllers.firstObject).devId = self.devId;
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)createLimitOfflinePassword {
   
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateLimitOfflinePassword"];
    ((CreateLimitOfflinePasswordController *)nav.viewControllers.firstObject).devId = self.devId;
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![sender isKindOfClass:UITableViewCell.class]) {
        return;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    PasswordDetailViewController *viewController = segue.destinationViewController;
    viewController.devId = self.devId;
    viewController.password_id = self.dataArray[indexPath.row].passwordId;
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *password_name = self.dataArray[indexPath.row].passwordName;
    cell.textLabel.text = password_name;
    
    NSDictionary *typeDic = @{
        @(LockPasswordLimitOnlineType): NSLocalizedString(@"Limit online password", nil),
        @(LockPasswordOnceOfflineType): NSLocalizedString(@"Once time password", nil),
        @(LockPasswordLimitOfflineType): NSLocalizedString(@"Limit offline password", nil),
        @(LockPasswordPermanentOnlineType): NSLocalizedString(@"Permanent password", nil),
    };
    
    LockPasswordType type = self.dataArray[indexPath.row].passwordType;
    cell.detailTextLabel.text = typeDic[@(type)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
