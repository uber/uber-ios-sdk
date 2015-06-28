//
//  UBModelViewController.m
//  UberSDK-Example
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import "UBResultsViewController.h"

@interface UBResultsViewController ()

@property (nonatomic) id result;

@property (nonatomic) NSArray *labels;
@property (nonatomic) NSArray *values;

@end


@implementation UBResultsViewController

#pragma mark - Lifecycle

- (id)initWithResult:(id)result
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _result = result;
        
        if ([_result isKindOfClass:NSArray.class]) {
            _values = [NSArray arrayWithArray:_result];
            
            _labels = [NSMutableArray arrayWithCapacity:_values.count];
            for (id result in _result) {
                [(NSMutableArray *)_labels addObject:[[result class] description]];
            }
        } else if ([_result isKindOfClass:MTLModel.class]) {
            MTLModel *model = (MTLModel *)_result;
            
            _labels = [model.dictionaryValue.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            _values = [[NSMutableArray alloc] initWithCapacity:_labels.count];
            for (NSString *key in _labels) {
                NSObject *result = [_result valueForKey:key] ? [_result valueForKey:key] : [NSNull null];
                [(NSMutableArray *)_values addObject:result];
            }
        } else {
            [NSException raise:NSInvalidArgumentException format:@"unsupported result type"];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.labels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    id value = self.values[indexPath.row];
    
    cell.textLabel.text = [self.result isKindOfClass:NSArray.class]
        ? [NSString stringWithFormat:@"%@ [%ld]", self.labels[indexPath.row], indexPath.row]
        : self.labels[indexPath.row];
    
    if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:MTLModel.class]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [self.values[indexPath.row] description];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id value = self.values[indexPath.row];
    if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:MTLModel.class]) {
        UBResultsViewController *vc = [[UBResultsViewController alloc] initWithResult:value];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
