//
//  SiteListViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/5.
//

#import "SiteListViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import <ThingSmartResidenceKit/ThingSmartResidenceKit.h>
#import "SiteManager.h"

@interface SiteListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property( nonatomic, strong) IBOutlet UITableView *tableView;
@property( nonatomic, strong) NSArray<ThingResidenceSiteModel *> *dataArray;

@end

@implementation SiteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadData) name:@"UpateSiteList" object:nil];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!ThingSmartUser.sharedInstance.isLogin) {
        self.dataArray = @[];
        [self.tableView reloadData];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:NSBundle.mainBundle];
        [self.tabBarController presentViewController:storyboard.instantiateInitialViewController
                                            animated:YES
                                          completion:NULL];
        return;
    }
}

- (void)loadData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingResidenceSiteManager getSiteListWithSuccess:^(NSArray<ThingResidenceSiteModel *> * _Nullable list) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.dataArray = list;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)deleteSiteWithIndexPath:(NSIndexPath *)indexPath {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    long long siteId = self.dataArray[indexPath.row].siteId;
    [ThingResidenceSiteManager removeSiteWithSiteID:siteId
                                            success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self loadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row].name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SiteManager.shared.siteId = self.dataArray[indexPath.row].siteId;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingResidenceSiteManager getSiteDetailWithSiteId:SiteManager.shared.siteId
                                               success:^(ThingResidenceSiteModel * _Nullable model) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Device" bundle:NSBundle.mainBundle];
        [self.navigationController pushViewController:storyboard.instantiateInitialViewController animated:YES];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal 
                                                                               title:NSLocalizedString(@"Delete", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
      
        
        [self deleteSiteWithIndexPath:indexPath];
        
    }];
    deleteAction.backgroundColor = UIColor.redColor;
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    configuration.performsFirstActionWithFullSwipe = YES;
    return configuration;
}

@end
