//
//  AccountsViewController.m
//  codepath-twitter
//
//  Created by David Rajan on 2/28/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "AccountsViewController.h"
#import "AccountCell.h"
#import "User.h"

@interface AccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AccountsViewController

static CGFloat origConstant;
static AccountCell *swipedCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
    
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.tableView addGestureRecognizer:pgr];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Table view methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [User accounts].count) {
        [self addAccount];
    } else {
        [self switchAccount:indexPath.row];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [User accounts].count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [User accounts].count) {
        UITableViewCell *cell = [UITableViewCell new];
        [cell setSeparatorInset:UIEdgeInsetsZero];
        cell.preservesSuperviewLayoutMargins = NO;
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
        cell.textLabel.text = @"";
        cell.textLabel.font = [UIFont fontWithName:@"icomoon" size:24.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor darkGrayColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    } else {
        AccountCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
        [cell setSeparatorInset:UIEdgeInsetsZero];
        cell.preservesSuperviewLayoutMargins = NO;
        [cell setLayoutMargins:UIEdgeInsetsZero];
        cell.user = [User accounts][indexPath.row];
        
        cell.removeButton.tag = indexPath.row;
        [cell.removeButton addTarget:self action:@selector(onRemove:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    }
}

#pragma mark Private methods

- (void)onPan:(UIPanGestureRecognizer *)pgr {
    CGPoint translation = [pgr translationInView:pgr.view];
    if (pgr.state == UIGestureRecognizerStateBegan) {
        CGPoint swipeLocation = [pgr locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        swipedCell = (AccountCell *)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        origConstant = swipedCell.viewConstraint.constant;
    } else if (pgr.state == UIGestureRecognizerStateChanged) {
        swipedCell.viewConstraint.constant = origConstant - translation.x;
    }
}

- (void)onRemove:(UIButton*)sender {
    [User removeAccount:[User accounts][sender.tag]];
    if ([User accounts].count == 0) {
        [User logout];
    }
    [self.tableView reloadData];
}

- (void)addAccount {
    [User switchUser:nil];
}

- (void)switchAccount:(NSInteger)index {
    [User switchUser:[User accounts][index]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
