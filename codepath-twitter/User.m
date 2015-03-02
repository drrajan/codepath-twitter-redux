//
//  User.m
//  codepath-twitter
//
//  Created by David Rajan on 2/17/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";
NSString * const UserDidSwitchNotification = @"UserDidSwitchNotification";

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.userid = dictionary[@"id_str"];
        self.screenname = [NSString stringWithFormat:@"@%@", dictionary[@"screen_name"]];
        self.profileImageUrl = dictionary[@"profile_image_url"];
        if ([dictionary objectForKey:@"profile_banner_url"]) {
        //if (dictionary [@"profile_banner_url"] != (id)[NSNull null]) {
            self.profileBannerUrl = [NSString stringWithFormat:@"%@/mobile_retina", dictionary[@"profile_banner_url"]];
        } else {
            self.profileBannerUrl = nil;
        }
        
        self.profileBackgroundColor = dictionary[@"profile_background_color"];
        self.location = dictionary[@"location"];
        self.tagline = dictionary[@"description"];
        self.followersCount = [NSString stringWithFormat:@"%@", dictionary[@"followers_count"]];
        self.followingCount = [NSString stringWithFormat:@"%@", dictionary[@"friends_count"]];
        self.tweetCount = [NSString stringWithFormat:@"%@", dictionary[@"statuses_count"]];
    }
    
    return self;
}

static User *_currentUser = nil;
static NSMutableArray *_accountsArray = nil;

NSString * const kCurrentUserKey = @"kCurrentUserKey";
NSString * const kAccountsKey = @"kAccountsKey";

+ (NSArray *)accounts {
    if (_accountsArray == nil) {
        _accountsArray = [NSMutableArray array];
        NSArray *accounts = [[NSUserDefaults standardUserDefaults] arrayForKey:kAccountsKey];
        for (NSData *data in accounts) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            User *user = [[User alloc] initWithDictionary:dictionary];
            [_accountsArray addObject:user];
        }
        if ([_accountsArray count] == 0) {
            [self addAccount:[self currentUser]];
        }
    }
    return _accountsArray;
}

+ (void)addAccount:(User *)user {
    NSMutableArray *array = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAccountsKey] mutableCopy];
    
    if (array == nil) {
        array = [NSMutableArray array];
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:user.dictionary options:0 error:&error];
    if (error) {
        NSLog(@"add account error: %@", error);
    }
    [array addObject:data];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kAccountsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _accountsArray = [NSMutableArray array];
    for (NSData *data in array) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        User *user = [[User alloc] initWithDictionary:dictionary];
        [_accountsArray addObject:user];
    }
}

+ (void)removeAccount:(User *)user {
    NSInteger remove = -1;
    for (int i = 0; i < _accountsArray.count; i++) {
        if ([user.screenname isEqualToString:((User *)_accountsArray[i]).screenname]) {
            remove = i;
        }
    }
    if (remove >= 0) {
        [_accountsArray removeObjectAtIndex:remove];
    }
    
    
    for (User *u in _accountsArray) {
        if ([user.screenname isEqualToString:u.screenname]) {
            [_accountsArray removeObject:u];
        }
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (User *u in _accountsArray) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:u.dictionary options:0 error:&error];
        if (error) {
            NSLog(@"add account error: %@", error);
        }
        [array addObject:data];
    }
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kAccountsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (User *)currentUser {
    
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    return _currentUser;
}

+ (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    
    if (_currentUser != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:&error];
        if (error) {
            NSLog(@"error: %@", error);
        }
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
        
        BOOL userAdd = YES;
        for (User *user in [self accounts]) {
            if ([[self currentUser].screenname isEqualToString:user.screenname]) {
                userAdd = NO;
            }
        }
        if (userAdd) {
            [self addAccount:[self currentUser]];
        }
        
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)switchUser:(User *)theUser {
    if ([[self currentUser].screenname isEqualToString:theUser.screenname]) {
        return;
    }
    [[TwitterClient sharedInstance] loginWithScreenName:[theUser.screenname substringFromIndex:1] completion:^(User *user, NSError *error) {
        if (user != nil) {
            NSLog(@"Welcome to %@", user.name);
            [self setCurrentUser:user];
            [[NSNotificationCenter defaultCenter] postNotificationName:UserDidSwitchNotification object:nil];
        } else {
            NSLog(@"Error getting user");
        }
    }];
}

+ (void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

@end
