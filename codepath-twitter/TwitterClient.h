//
//  TwitterClient.h
//  codepath-twitter
//
//  Created by David Rajan on 2/17/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithScreenName:(NSString *)name completion:(void (^)(User *user, NSError *error))completion;
- (void)openURL:(NSURL *)url;

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)profileWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)postStatusWithParams:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *))completion;
- (void)postRetweetWithID:(NSString *)tweetID completion:(void (^)(Tweet *tweet, NSError *))completion;
- (void)deleteRetweetWithID:(NSString *)tweetID completion:(void (^)(Tweet *tweet, NSError *))completion;
- (void)postFavoriteWithID:(NSString *)tweetID withAction:(NSString *)action completion:(void (^)(Tweet *, NSError *))completion;
@end
