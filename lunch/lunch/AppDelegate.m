//
//  AppDelegate.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"

static NSString *const kFlurryAnalyticsApiKey = @"ZKXMN5VTXNGWHPN7SMCW";
static NSString *const kYahooSearchApiKey = @"Jfnn0A6m";

@interface AppDelegate ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [Flurry startSession:kFlurryAnalyticsApiKey];
  
  NSDictionary *defaults = @{@"priceFilter" : @(2)};
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  
  [self startScanningLocation];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [self stopScanningLocation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [self stopScanningLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  [self startScanningLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [self startScanningLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [self stopScanningLocation];
}

#pragma mark - Location

- (void) startScanningLocation {
  if (!self.locationManager) {
    self.locationManager = [[CLLocationManager alloc] init];
  }
  
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self.locationManager startUpdatingLocation];
  } else {
    [self.locationManager requestWhenInUseAuthorization];
  }
}

- (void) stopScanningLocation {
  [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self.locationManager startUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.recentLocation = manager.location;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatedLocation" object:nil userInfo:nil];
}

@end
