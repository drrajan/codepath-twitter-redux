//
//  TweetDetailViewController.m
//  codepath-twitter
//
//  Created by David Rajan on 2/21/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "TwitterClient.h"
#import "TweetDetailViewController.h"
#import "ComposeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+DateTools.h"
#import "ProfileViewController.h"

@interface TweetDetailViewController () <ComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rtHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rtImgHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rtFavHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rtFavBarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rtFavTxtHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (strong, nonatomic) UIColor *retweetColor;
@property (strong, nonatomic) UIColor *favoriteColor;
@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton *newButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 75, 24)];
    [newButton addTarget:self action:@selector(onReply:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(0,0,75,24)];
    buttonLabel.text = @"Reply ";
    buttonLabel.font = [UIFont fontWithName:@"icomoon" size:18.0f];
    buttonLabel.textColor = [UIColor whiteColor];
    [newButton addSubview:buttonLabel];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:newButton];
    self.navigationItem.rightBarButtonItem = item;
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapProfile:)];
    [self.profileImageView addGestureRecognizer:tgr];
    self.profileImageView.userInteractionEnabled = YES;
    self.profileImageView.layer.cornerRadius = 3;
    self.profileImageView.clipsToBounds = YES;
    
    self.retweetColor = [UIColor colorWithRed:119/255.0f green:178/255.0f blue:85/255.0f alpha:1.0f];
    self.favoriteColor = [UIColor colorWithRed:255/255.0f green:172/255.0f blue:51/255.0f alpha:1.0f];
    
   
    
    [self updateView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView {
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.tweet.user.profileImageUrl]];
    self.nameLabel.text = self.tweet.user.name;
    self.twitterHandleLabel.text = self.tweet.user.screenname;
    self.tweetBodyLabel.text = self.tweet.text;

    self.createdAtLabel.text = [self.tweet.createdAt formattedDateWithFormat:@"M/dd/yy, hh:mm a"];


    NSString *retweetText = @"RETWEETS";
    if (self.tweet.retweetCount == 1) {
        retweetText = @"RETWEET";
    } else if (self.tweet.retweetCount == 0) {
        retweetText = @"";
    }
    NSString *favoriteText = @"FAVORITES";
    if (self.tweet.favoriteCount == 1) {
        favoriteText = @"FAVORITE";
    } else if (self.tweet.favoriteCount == 0) {
        favoriteText = @"";
    }
    NSString *countText = @"";
    if (self.tweet.retweetCount > 0) {
        countText = [countText stringByAppendingString:[NSString stringWithFormat:@"%ld %@   ", self.tweet.retweetCount, retweetText]];
    }
    if (self.tweet.favoriteCount > 0) {
        countText = [countText stringByAppendingString:[NSString stringWithFormat:@"%ld %@", self.tweet.favoriteCount, favoriteText]];
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:countText];
    
    NSArray *words=[countText componentsSeparatedByString:@" "];
    
    for (NSString *word in words) {
        if (word.intValue > 0) {
            NSRange range=[countText rangeOfString:word];
            UIFont *boldFont = [UIFont boldSystemFontOfSize:12];
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        boldFont, NSFontAttributeName,[UIColor blackColor], NSForegroundColorAttributeName, nil];
            [string addAttributes:attributes range:range];
        }
    }
    self.countLabel.attributedText = string;
    
    if (self.tweet.isRetweet) {
        [self.retweetButton setTitleColor:self.retweetColor forState:UIControlStateNormal];
    } else {
        [self.retweetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    if (self.tweet.isFavorite) {
        [self.favoriteButton setTitleColor:self.favoriteColor forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    if (self.tweet.rtName != nil) {
        self.retweetLabel.text = [NSString stringWithFormat:@"%@ retweeted", self.tweet.rtName];
    } else {
        self.retweetLabel.text = @"";
    }
    
    if (self.tweet.isRetweet) {
        [self.retweetButton setTitleColor:self.retweetColor forState:UIControlStateNormal];
    }
    if (self.tweet.isFavorite) {
        [self.favoriteButton setTitleColor:self.favoriteColor forState:UIControlStateNormal];
    }
    
    if (self.tweet.rtName == nil) {
        self.rtHeightConstraint.constant = 0.f;
        self.rtImgHeightConstraint.constant = 0.f;
    } else {
        self.rtHeightConstraint.constant = 15.0f;
        self.rtImgHeightConstraint.constant = 16.0f;
    }
    if (self.tweet.retweetCount > 0 || self.tweet.favoriteCount > 0) {
        self.rtFavHeightConstraint.constant = 40.0f;
        self.rtFavBarHeightConstraint.constant = 1.0f;
        self.rtFavTxtHeightConstraint.constant = 16.0f;
    } else {
        self.rtFavHeightConstraint.constant = 0.f;
        self.rtFavBarHeightConstraint.constant = 0.f;
        self.rtFavTxtHeightConstraint.constant = 0.f;
    }
}

#pragma mark Compose View methods

-(void)postStatusUpdateWithDictionary:(NSDictionary *)dictionary {
    [[TwitterClient sharedInstance] postStatusWithParams:dictionary completion:^(Tweet *tweet, NSError *error) {
        NSLog(@"posted tweet: %@", tweet.text);
    }];
}

#pragma mark Private methods

- (void)onTapProfile:(UITapGestureRecognizer *)gesture {
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithUser:self.tweet.user];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (IBAction)onReply:(UIButton *)sender {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    vc.tweet = self.tweet;
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)onRetweet:(UIButton *)sender {
    if (self.tweet.isRetweet) {
        [[TwitterClient sharedInstance] deleteRetweetWithID:self.tweet.retweetID completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                NSLog(@"unretweeted: %@", tweet.text);
                self.tweet.isRetweet = NO;
                --self.tweet.retweetCount;
            }
        }];
    } else {
        [[TwitterClient sharedInstance] postRetweetWithID:self.tweet.retweetID completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                NSLog(@"retweeted: %@", tweet.text);
                self.tweet.isRetweet = YES;
                self.tweet.retweetCount++;
            }
        }];
    }
    [self updateView];
}

- (IBAction)onFavorite:(UIButton *)sender {
    if (self.tweet.isFavorite) {
        [[TwitterClient sharedInstance] postFavoriteWithID:self.tweet.retweetID withAction:@"destroy" completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                NSLog(@"unfavorited: %@", tweet.text);
                self.tweet.isFavorite = NO;
                --self.tweet.favoriteCount;
            }
        }];
    } else {
        [[TwitterClient sharedInstance] postFavoriteWithID:self.tweet.retweetID withAction:@"create" completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                NSLog(@"favorited: %@", tweet.text);
                self.tweet.isFavorite = YES;
                self.tweet.favoriteCount++;
            }
        }];
    }
    [self updateView];
}




@end
