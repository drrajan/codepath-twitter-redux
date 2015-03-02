//
//  ProfileHeaderCell.h
//  codepath-twitter
//
//  Created by David Rajan on 2/26/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileHeaderCell : UITableViewCell

@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
