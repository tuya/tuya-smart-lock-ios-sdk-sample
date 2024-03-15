//
//  DigitalKeyListViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/1/24.
//

#import "DigitalKeyListViewController.h"
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import <YYModel/YYModel.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import <ThingSmartLockSDK/ThingSmartLockSDK.h>
#import "EkeyDetailTableViewController.h"
#import "CreateLimitEKeyTableViewController.h"
#import "CreatePermanentEKeyViewController.h"
#import "CreateOnceEKeyViewController.h"
#import "SiteManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MJRefresh/MJRefresh.h>

@interface DigitalKeyListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property( nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ThingEKeyModel *> *dataArray;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addBarItem;
@property (nonatomic, assign) NSInteger pageNo;

@end

@implementation DigitalKeyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadData) name:@"UpateEKeyList" object:nil];
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer.hidden = YES;
    self.tableView.mj_footer = footer;
    [self loadData];
    
    [self configMenu];
    [self loadData];
}

- (void)loadData {
    self.pageNo = 1;
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice getEKeyListWithSiteId:siteId
                                  deviceId:self.devId
                                    pageNo:self.pageNo
                                  pageSize:20
                                   success:^(NSArray<ThingEKeyModel *> * _Nullable list, NSInteger totalPage) {
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
    self.pageNo++;
    long long siteId = SiteManager.shared.siteId;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ThingLockDevice getEKeyListWithSiteId:siteId
                                  deviceId:self.devId
                                    pageNo:self.pageNo
                                  pageSize:20
                                   success:^(NSArray<ThingEKeyModel *> * _Nullable list, NSInteger totalPage) {
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

- (void)configMenu {
    // 创建菜单项
    UIAction *action1 = [UIAction actionWithTitle:NSLocalizedString(@"Limit", nil) image:nil identifier:nil handler:^(UIAction* action) {
        [self createLimitEKey];
    }];
    UIAction *action2 = [UIAction actionWithTitle:NSLocalizedString(@"Permanent", nil) image:nil identifier:nil handler:^(UIAction* action) {
        [self createPermanentEKey];
    }];
    
    UIAction *action3 = [UIAction actionWithTitle:NSLocalizedString(@"Once", nil) image:nil identifier:nil handler:^(UIAction* action) {
        [self createOnceEKey];
    }];

    
    // 创建根菜单
    UIMenu *rootMenu = [UIMenu menuWithTitle:@"" children:@[action1, action2, action3]];
    
    // 显示菜单
    self.addBarItem.menu = rootMenu;
}

- (void)createLimitEKey {
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateLimitEKey"];
    ((CreateLimitEKeyTableViewController *)nav.viewControllers.firstObject).devId = self.devId;
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)createPermanentEKey {
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"CreatePermanentEKey"];
    ((CreatePermanentEKeyViewController *)nav.viewControllers.firstObject).devId = self.devId;
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)createOnceEKey {
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateOnceEKey"];
    ((CreateOnceEKeyViewController *)nav.viewControllers.firstObject).devId = self.devId;
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EkeyDetailTableViewController *detailViewController = segue.destinationViewController;
    if ([sender isKindOfClass:UITableViewCell.class]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSString *eKeyId = self.dataArray[indexPath.row].eKeyId;
        detailViewController.eKeyId = eKeyId;
        detailViewController.devId = self.devId;
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *name = self.dataArray[indexPath.row].name;
    cell.textLabel.text = name;
    
    NSString *account = self.dataArray[indexPath.row].account;
    cell.detailTextLabel.text = account;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
