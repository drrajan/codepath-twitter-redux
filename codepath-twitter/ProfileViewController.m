//
//  ProfileViewController.m
//  codepath-twitter
//
//  Created by David Rajan on 2/25/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileHeaderCell.h"
#import "ComposeViewController.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "AccountsViewController.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIColor *retweetColor;
@property (strong, nonatomic) UIColor *favoriteColor;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) ProfileHeaderCell *headerView;

@end

@implementation ProfileViewController

- (id)initWithUser:(User *)user {
    self = [super init];
    if (self) {
        if (user == nil) {
            self.user = [User currentUser];
        } else {
            self.user = user;
        }
    }
    return self;
}

- (id)init {
    return [self initWithUser:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Profile";
        
    self.retweetColor = [UIColor colorWithRed:119/255.0f green:178/255.0f blue:85/255.0f alpha:1.0f];
    self.favoriteColor = [UIColor colorWithRed:255/255.0f green:172/255.0f blue:51/255.0f alpha:1.0f];
    
    UIButton *newButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [newButton addTarget:self action:@selector(onNewButton) forControlEvents:UIControlEventTouchUpInside];
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(0,0,24,24)];
    buttonLabel.text = @"";
    buttonLabel.font = [UIFont fontWithName:@"icomoon" size:24.0f];
    buttonLabel.textColor = [UIColor whiteColor];
    [newButton addSubview:buttonLabel];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:newButton];
    self.navigationItem.rightBarButtonItem = item;

    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileHeaderCell" bundle:nil] forCellReuseIdentifier:@"ProfileHeaderCell"];
    
    self.headerView = [self.tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderCell"];
    self.headerView.user = self.user;
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];
    CGFloat height = [self.headerView.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + self.headerView.contentView.frame.origin.y;
    
    CGRect headerFrame = self.headerView.frame;
    headerFrame.size.height = height;
    self.headerView.frame = headerFrame;
    [self.tableView setTableHeaderView:self.headerView];
    
    [self refresh:nil withParams:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
         NSLog(@"long press");
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1];
        [self.navigationController pushViewController:[AccountsViewController new] animated:YES];
    }
}

- (void)refresh:(id)sender withParams:(NSDictionary *)params {
    NSLog(@"Refreshing");
    NSMutableDictionary *dictionary;
    if (params) {
        dictionary = [params mutableCopy];
    } else {
        dictionary = [NSMutableDictionary dictionary];
    }
    [dictionary setValue:self.user.screenname forKey:@"screen_name"];
    
    [[TwitterClient sharedInstance] profileWithParams:dictionary completion:^(NSArray *tweets, NSError *error) {
        self.tweets = tweets;
        [self.tableView reloadData];
    }];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    cell.preservesSuperviewLayoutMargins = NO;
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    Tweet *tweet = self.tweets[indexPath.row];
    if (tweet.rtName == nil) {
        cell.rtHeightConstraint.constant = 0.f;
        cell.rtImgHeightConstraint.constant = 0.f;
    } else {
        cell.rtHeightConstraint.constant = 14.5f;
        cell.rtImgHeightConstraint.constant = 16.0f;
    }
    
    cell.tweet = tweet;
    
    if (tweet.isRetweet) {
        [cell.retweetButton setTitleColor:self.retweetColor forState:UIControlStateNormal];
    } else {
        [cell.retweetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    if (tweet.isFavorite) {
        [cell.favoriteButton setTitleColor:self.favoriteColor forState:UIControlStateNormal];
    } else {
        [cell.favoriteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapProfile:)];
    cell.profileImageView.tag = indexPath.row;
    cell.profileImageView.userInteractionEnabled = YES;
    [cell.profileImageView addGestureRecognizer:tgr];
    
    cell.replyButton.tag = indexPath.row;
    cell.retweetButton.tag = indexPath.row;
    cell.favoriteButton.tag = indexPath.row;
    [cell.replyButton addTarget:self action:@selector(onReply:) forControlEvents:UIControlEventTouchUpInside];
    [cell.retweetButton addTarget:self action:@selector(onRetweet:) forControlEvents:UIControlEventTouchUpInside];
    [cell.favoriteButton addTarget:self action:@selector(onFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
//    if (indexPath.row == self.tweets.count -1) {
//        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//        [dictionary setValue:tweet.retweetID forKey:@"max_id"];
//        [self refresh:nil withParams:dictionary];
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView xheightForHeaderInSection:(NSInteger)section {
    return 250;
}

- (UIView *)tableView:(UITableView *)tableView xviewForHeaderInSection:(NSInteger)section {
    ProfileHeaderCell *headerView = [tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderCell"];
    headerView.user = self.user;
    
    
    
    return headerView;
}

#pragma mark Compose View methods

- (void)postStatusUpdateWithDictionary:(NSDictionary *)dictionary {
    [[TwitterClient sharedInstance] postStatusWithParams:dictionary completion:^(Tweet *tweet, NSError *error) {
        NSLog(@"posted tweet: %@", tweet.text);
        NSMutableArray *tmpArray = [NSMutableArray arrayWithObject:tweet];
        [tmpArray addObjectsFromArray:self.tweets];
        self.tweets = tmpArray;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }];
}

#pragma mark Private methods

- (void)onTapProfile:(UITapGestureRecognizer *)gesture {
    Tweet *tweet = self.tweets[[gesture view].tag];
    User *user = tweet.user;
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)composeTweetWithReply:(Tweet *)reply {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    vc.tweet = reply;
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onNewButton {
    [self composeTweetWithReply:nil];
}

- (void)onReply:(UIButton*)sender {
    [self composeTweetWithReply:self.tweets[sender.tag]];
}

- (void)onRetweet:(UIButton*)sender {
    Tweet *currTweet = self.tweets[sender.tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    
    if (currTweet.isRetweet) {
        [[TwitterClient sharedInstance] deleteRetweetWithID:currTweet.retweetID completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                NSLog(@"unretweeted: %@", tweet.text);
                --currTweet.retweetCount;
                currTweet.isRetweet = NO;
                [self updateCellAtIndexPath:indexPath];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] postRetweetWithID:currTweet.retweetID completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                NSLog(@"retweeted: %@", tweet.text);
                currTweet.retweetCount++;
                currTweet.isRetweet = YES;
                [self updateCellAtIndexPath:indexPath];
            }
        }];
    }
}

- (void)onFavorite:(UIButton*)sender {
    Tweet *currTweet = self.tweets[sender.tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    
    if (currTweet.isFavorite) {
        [[TwitterClient sharedInstance] postFavoriteWithID:currTweet.retweetID withAction:@"destroy" completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                NSLog(@"unfavorited: %@", tweet.text);
                currTweet.isFavorite = NO;
                --currTweet.favoriteCount;
                [self updateCellAtIndexPath:indexPath];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] postFavoriteWithID:currTweet.retweetID withAction:@"create" completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                NSLog(@"favorited: %@", tweet.text);
                currTweet.isFavorite = YES;
                currTweet.favoriteCount++;
                [self updateCellAtIndexPath:indexPath];
            }
        }];
    }
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
