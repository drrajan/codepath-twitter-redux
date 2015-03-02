//
//  AccountCell.h
//  codepath-twitter
//
//  Created by David Rajan on 2/28/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AccountCell : UITableViewCell

@property (nonatomic, strong) User *user;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewConstraint;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
