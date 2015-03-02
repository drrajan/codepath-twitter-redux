//
//  AccountCell.m
//  codepath-twitter
//
//  Created by David Rajan on 2/28/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "AccountCell.h"
#import "UIImageView+AFNetworking.h"

@interface AccountCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation AccountCell

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
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = user.screenname;
    
    NSMutableString *bg = [NSMutableString stringWithFormat:@"0x%@", user.profileBackgroundColor];
    NSLog(@"bg: %@", user.profileBackgroundColor);
    unsigned colorInt = 0;
    [[NSScanner scannerWithString:bg] scanHexInt:&colorInt];
    
    self.containerView.backgroundColor = UIColorFromRGB(colorInt);
    self.contentView.backgroundColor = UIColorFromRGB(colorInt);
    
    self.profileImageView.layer.cornerRadius = 3;
    self.profileImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.profileImageView.layer.borderWidth = 3;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.clipsToBounds = YES;
}

@end
