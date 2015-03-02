//
//  Tweet.h
//  codepath-twitter
//
//  Created by David Rajan on 2/17/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *tweetID;
@property (nonatomic, strong) NSString *retweetID;
@property (nonatomic, strong) NSString *tweetReplyScreenname;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, assign) NSInteger favoriteCount;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *rtTweetID;
@property (nonatomic, strong) NSString *rtName;
@property (nonatomic, strong) NSString *rtScreenName;
@property (nonatomic, strong) User *user;
@property (nonatomic, assign) BOOL isRetweet;
@property (nonatomic, assign) BOOL isFavorite;


- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end
