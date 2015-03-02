//
//  User.h
//  codepath-twitter
//
//  Created by David Rajan on 2/17/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;
extern NSString * const UserDidSwitchNotification;

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *screenname;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *profileBannerUrl;
@property (nonatomic, strong) NSString *profileBackgroundColor;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *followersCount;
@property (nonatomic, strong) NSString *followingCount;
@property (nonatomic, strong) NSString *tweetCount;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;
+ (NSArray *)accounts;
+ (void)switchUser:(User *)user;
+ (void)removeAccount:(User *)user;
+ (void)logout;

@end
