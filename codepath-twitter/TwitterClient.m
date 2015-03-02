//
//  TwitterClient.m
//  codepath-twitter
//
//  Created by David Rajan on 2/17/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "TwitterClient.h"

NSString * const kTwitterConsumerKey = @"10CI2CVTMmAmk8n6KeUGAluTA";
NSString * const kTwitterConsumerSecret = @"6KYrutyc6jOqkOn3usLeDhdQPLYLfcb22Cn7TsJgXt7XFl7blo";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);

@end


@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void)loginWithScreenName:(NSString *)name completion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitter://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"got the request token!");
        
        NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?force_login=true&oauth_token=%@", requestToken.token];
        if (name != nil) {
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&screen_name=%@", name]];
        }
        
        NSURL *authURL = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:authURL];
        
    } failure:^(NSError *error) {
        NSLog(@"failed to get the request token!");
        self.loginCompletion(nil, error);
    }];
}


-(void)openURL:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        NSLog(@"got access token!");
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            NSLog(@"current user %@", user.name);
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failed getting current user");
            self.loginCompletion(nil, error);
        }];
    } failure:^(NSError *error) {
        NSLog(@"failed to get access token!");
        self.loginCompletion(nil, error);
    }];

}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *, NSError *))completion {
    [self GET:@"1.1/statuses/home_timeline.json?include_my_retweet=1" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *, NSError *))completion {
    [self GET:@"1.1/statuses/mentions_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)profileWithParams:(NSDictionary *)params completion:(void (^)(NSArray *, NSError *))completion {
    [self GET:@"1.1/statuses/user_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)postStatusWithParams:(NSDictionary *)params completion:(void (^)(Tweet *, NSError *))completion {
    [self POST:@"1.1/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        NSLog(@"success posting tweet!");
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure posting tweet!");
        completion(nil, error);
    }];
}

- (void)postRetweetWithID:(NSString *)tweetID completion:(void (^)(Tweet *, NSError *))completion {
    [self POST:[NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweetID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        NSLog(@"retweeted: %@!", tweetID);
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure retweeting: %@!", tweetID);
        completion(nil, error);
    }];
}

- (void)deleteRetweetWithID:(NSString *)tweetID completion:(void (^)(Tweet *, NSError *))completion {
    
    [self getRetweetsWithID:tweetID completion:^(NSString *retweetID, NSError *error) {
        if (!error) {
            
            [self POST:[NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", retweetID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
                NSLog(@"unretweeted: %@!", tweetID);
                completion(tweet, nil);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failure unretweeting: %@!", tweetID);
                completion(nil, error);
            }];
            
            
        } else {
            NSLog(@"could not get retweet id for %@", tweetID);
        }
    }];
    
    
    
}

- (void)postFavoriteWithID:(NSString *)tweetID withAction:(NSString *)action completion:(void (^)(Tweet *, NSError *))completion {
    [self POST:[NSString stringWithFormat:@"1.1/favorites/%@.json?id=%@", action, tweetID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        NSLog(@"favorite %@: %@!", action, tweetID);
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure favorite %@: %@!", action, tweetID);
        completion(nil, error);
    }];
}

#pragma mark private

- (void)getRetweetsWithID:(NSString *)tweetID completion:(void (^)(NSString *, NSError *))completion {
    [self GET:[NSString stringWithFormat:@"1.1/statuses/retweets/%@.json", tweetID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        User *user = [User currentUser];
        for (NSDictionary *dictionary in responseObject) {
            if ([user.userid isEqualToString:[dictionary valueForKeyPath:@"user.id_str"]]) {
                completion(dictionary[@"id_str"], nil);
                break;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure retweeting: %@!", tweetID);
        completion(nil, error);
    }];
}

@end
