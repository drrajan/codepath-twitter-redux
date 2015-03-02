//
//  MasterViewController.h
//  codepath-twitter
//
//  Created by David Rajan on 2/24/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UIViewController

@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *menuViewController;

-(id)initWithMainViewController:(UIViewController *)mainViewController menuViewController:(UIViewController *)menuViewController;

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated closeMenu:(BOOL)closeMenu;

@end

@interface UIViewController (MasterViewController)

@property (nonatomic, weak) MasterViewController *masterViewController;

@end
