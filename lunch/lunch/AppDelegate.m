//
//  AppDelegate.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"
#import <YahooSearchKit/YahooSearchKit.h>

static NSString *const kFlurryAnalyticsApiKey = @"ZKXMN5VTXNGWHPN7SMCW";
static NSString *const kYahooSearchApiKey = @"Jfnn0A6m";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [Flurry startSession:kFlurryAnalyticsApiKey];
  
  [YSLSetting setupWithAppId:kYahooSearchApiKey];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
