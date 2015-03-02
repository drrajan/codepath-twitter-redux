//
//  TweetCell.m
//  codepath-twitter
//
//  Created by David Rajan on 2/19/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+DateTools.h"

@interface TweetCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;

@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    self.tweetBodyLabel.preferredMaxLayoutWidth = self.tweetBodyLabel.frame.size.width;
    
    self.profileImageView.layer.cornerRadius = 3;
    self.profileImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:tweet.user.profileImageUrl]];
    self.nameLabel.text = tweet.user.name;
    self.twitterHandleLabel.text = tweet.user.screenname;
    self.tweetBodyLabel.text = tweet.text;
    self.createdAtLabel.text = tweet.createdAt.shortTimeAgoSinceNow;
    if (tweet.retweetCount > 0) {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", tweet.retweetCount];
    } else {
        self.retweetCountLabel.text = @"";
    }
    if (tweet.favoriteCount > 0) {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", tweet.favoriteCount];
    } else {
        self.favoriteCountLabel.text = @"";
    }
    
    
    if (tweet.rtName != nil) {
        self.retweetLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.rtName];
    } else {
        self.retweetLabel.text = @"";
    }
}

@end
