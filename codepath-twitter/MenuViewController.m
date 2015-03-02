//
//  MenuViewController.m
//  codepath-twitter
//
//  Created by David Rajan on 2/25/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "TweetsViewController.h"
#import "MasterViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onProfileButton:(id)sender {
    UINavigationController *profileViewController = [[UINavigationController alloc] initWithRootViewController:[ProfileViewController new]];
    [self.masterViewController setMainViewController:profileViewController animated:YES closeMenu:YES];
}

- (IBAction)onTimelineButton:(id)sender {
    UINavigationController *tweetsViewController = [[UINavigationController alloc] initWithRootViewController:[TweetsViewController new]];
    [self.masterViewController setMainViewController:tweetsViewController animated:YES closeMenu:YES];
}

- (IBAction)onMentionsButton:(id)sender {
    UINavigationController *tweetsViewController = [[UINavigationController alloc] initWithRootViewController:[[TweetsViewController alloc] initWithMentions:YES]];
    [self.masterViewController setMainViewController:tweetsViewController animated:YES closeMenu:YES];
}

@end
