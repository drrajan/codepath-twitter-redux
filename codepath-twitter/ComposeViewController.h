//
//  ComposeViewController.h
//  codepath-twitter
//
//  Created by David Rajan on 2/21/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class ComposeViewController;

@protocol ComposeViewControllerDelegate <NSObject>

- (void)postStatusUpdateWithDictionary:(NSDictionary *)dictionary;

@end


@interface ComposeViewController : UIViewController

@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;
@property (nonatomic, strong) Tweet *tweet;

@end
