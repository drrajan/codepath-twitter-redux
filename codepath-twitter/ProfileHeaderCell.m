//
//  ProfileHeaderCell.m
//  codepath-twitter
//
//  Created by David Rajan on 2/26/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "ProfileHeaderCell.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileHeaderCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileBannerView;

@end

@implementation ProfileHeaderCell

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setUser:(User *)user {
    _user = user;
    
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = user.screenname;
    self.locationLabel.text = user.location;
    self.descriptionLabel.text = user.tagline;
    self.tweetsLabel.text = user.tweetCount;
    self.followLabel.text = user.followingCount;
    self.followersLabel.text = user.followersCount;
    
    NSMutableString *bg = [NSMutableString stringWithFormat:@"0x%@", user.profileBackgroundColor];
    NSLog(@"bg: %@", user.profileBackgroundColor);
    unsigned colorInt = 0;
    [[NSScanner scannerWithString:bg] scanHexInt:&colorInt];
    
    //self.contentView.backgroundColor = UIColorFromRGB(colorInt);
    
    self.descriptionLabel.preferredMaxLayoutWidth = self.descriptionLabel.bounds.size.width;
    [self.profileImageView setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    [self.profileBannerView setImageWithURL:[NSURL URLWithString:user.profileBannerUrl]];
    NSLog(@"banner: %@", user.profileBannerUrl);

}

@end
