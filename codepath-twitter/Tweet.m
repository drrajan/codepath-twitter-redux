//
//  Tweet.m
//  codepath-twitter
//
//  Created by David Rajan on 2/17/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        
        if (dictionary[@"in_reply_to_status_id_str"] != (id)[NSNull null]) {
            self.tweetID = dictionary[@"in_reply_to_status_id_str"];
            self.tweetReplyScreenname = dictionary[@"in_reply_to_screen_name"];
        } else {
            self.tweetID = dictionary[@"id_str"];
            self.tweetReplyScreenname = [dictionary valueForKeyPath:@"user.screen_name"];
        }
        
        self.isRetweet = [dictionary[@"retweeted"] boolValue];
        self.isFavorite = [dictionary[@"favorited"] boolValue];
        
        if ([[dictionary valueForKeyPath:@"retweeted_status"] count] > 0) {
            self.rtName = [dictionary valueForKeyPath:@"user.name"];
            dictionary = [dictionary valueForKeyPath:@"retweeted_status"];
            self.rtScreenName = [dictionary valueForKeyPath:@"user.screen_name"];
            self.rtTweetID = dictionary[@"id_str"];
        } else {
            self.rtName = nil;
            self.rtScreenName = nil;
        }
        
        self.retweetID = dictionary[@"id_str"];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.text = dictionary[@"text"];
        self.retweetCount = [dictionary[@"retweet_count"] integerValue];
        self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
        
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        
        self.createdAt = [formatter dateFromString:createdAtString];
    }
    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    
    return tweets;
}

@end
