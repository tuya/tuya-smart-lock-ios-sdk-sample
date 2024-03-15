//
//  WeeklySelectTableViewController.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/2/19.
//

#import "PeriodSelectTableViewController.h"

@interface PeriodSelectTableViewController ()

@property (nonatomic, strong) NSArray<NSString *> *periodArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectArray;

@end

@implementation PeriodSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.periodArray = @[
        NSLocalizedString(@"Sunday", nil),
        NSLocalizedString(@"Monday", nil),
        NSLocalizedString(@"Tuesday", nil),
        NSLocalizedString(@"Wednesday", nil),
        NSLocalizedString(@"Thursday", nil),
        NSLocalizedString(@"Friday", nil),
        NSLocalizedString(@"Saturday", nil),
    ];
    
    self.selectArray = [NSMutableArray array];
    if (self.originSelect.count) {
        [self.selectArray addObjectsFromArray:self.originSelect];
    } else {
        [self.selectArray addObjectsFromArray:@[@NO, @NO, @NO, @NO, @NO, @NO, @NO]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.periodArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.periodArray[indexPath.row];
    cell.accessoryType = self.selectArray[indexPath.row].boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BOOL isSelect = self.selectArray[indexPath.row].boolValue;
    [self.selectArray replaceObjectAtIndex:indexPath.row withObject:@(!isSelect)];
    [tableView reloadData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewController:didSelectPeriod:)]) {
        [self.delegate viewController:self didSelectPeriod:self.selectArray.copy];
    }
    
}


@end
