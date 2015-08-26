//
//  MainViewController.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import "MainViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "RoundedBorderView.h"
#import "CircularButton.h"
#import "Flurry.h"

@interface MainViewController ()
@property (strong, nonatomic) NSArray *results;
@property (nonatomic) NSUInteger resultsIndex;
@property (nonatomic) BOOL showingError;
@property (strong, nonatomic) FlurryAdNative *nativeAd;
@property (copy, nonatomic) NSString *nativeAdImageUrl;
@property (nonatomic) BOOL shouldShowAd, didShowAd;
@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.results = nil;
  self.resultsIndex = 0;
  self.showingError = NO;
  self.statusLabel.text = @"";
  self.didShowAd = NO;
  self.nativeAdImageUrl = @"";
  
  [self updateFancinessButton];
  
  self.statusLabel.text = @"Finding you...";
  __weak MainViewController *weakSelf = self;
  __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"UpdatedLocation" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    
    //Remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
    observer = nil;
    
    [weakSelf loadResults];
  }];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.draggablePhotoView resetPosition];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void) updateFancinessButton {
  NSNumber *priceFilterNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"priceFilter"];
  self.navigationItem.rightBarButtonItem.title = [self titleForFancinessLevel:[priceFilterNumber unsignedIntegerValue]];
}

- (void) loadResults {
  AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
  self.statusLabel.text = @"Loading...";
  self.cancelButton.enabled = NO;
  self.okButton.enabled = NO;
  
  CLLocation *location = appDel.recentLocation;
  NSLog(@"current location: %@", location);
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  NSNumber *latitudeNumber = @(location.coordinate.latitude);
  NSNumber *longitudeNumber = @(location.coordinate.longitude);
  NSNumber *fanciness = [[NSUserDefaults standardUserDefaults] objectForKey:@"priceFilter"];
  
  NSString *urlString = [NSString stringWithFormat:@"https://lunchserver.herokuapp.com/search?latitude=%@&longitude=%@&maxTier=%@", latitudeNumber, longitudeNumber, fanciness];
  NSLog(@"requesting: %@", urlString);
  __weak MainViewController *weakSelf = self;
  [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString]
                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  
                                  if (error) {
                                    NSLog(@"error: %@", error);
                                    [weakSelf showErrorIfNeeded];
                                  } else {
                                    NSError *jsonError = nil;
                                    id result = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:NSJSONReadingAllowFragments
                                                                                  error:&jsonError];
                                    if (jsonError) {
                                      NSLog(@"json error: %@", jsonError);
                                      [weakSelf showErrorIfNeeded];
                                    } else {
                                      if (result[@"venues"]) {
                                        weakSelf.results = result[@"venues"];
                                        NSLog(@"result: %@", result);
                                        [weakSelf updateUi];
                                        [weakSelf fetchAd];
                                      }
                                    }
                                  }
                                });
                              }] resume];
}

- (void) showErrorIfNeeded {
  if (!self.results || [self.results count] == 0) {
    self.showingError = YES;
  } else {
    self.showingError = NO;
  }
}

- (void) setShowingError:(BOOL)showingError {
  _showingError = showingError;
  
  if (showingError) {
    self.errorRetryButton.hidden = NO;
    self.draggablePhotoView.hidden = YES;
    self.behindImageView.hidden = YES;
  } else {
    self.errorRetryButton.hidden = YES;
    self.draggablePhotoView.hidden = NO;
    self.behindImageView.hidden = NO;
  }
  
  self.statusLabel.text = @"";
}

- (void) updateUi {
  self.showingError = NO;
  self.cancelButton.enabled = YES;
  self.okButton.enabled = YES;
  
  //Update the draggable view.
  if (self.resultsIndex < self.results.count) {
    NSString *mainImageUrl = [self imageUrlFromResultAtIndex:self.resultsIndex];
    self.draggablePhotoView.imageUrl = mainImageUrl;
    self.draggablePhotoView.advertisement = NO;
    self.draggablePhotoView.hidden = NO;
    [self.draggablePhotoView resetPosition];
  } else {
    self.draggablePhotoView.hidden = YES;
  }
  
  //Has another one to show behind.
  NSUInteger nextIndex = self.resultsIndex < self.results.count - 1 ? self.resultsIndex + 1 : 0;
  NSString *behindImageUrl = [self imageUrlFromResultAtIndex:nextIndex];
  
  [self.behindImageView setImageWithURL:[NSURL URLWithString:behindImageUrl]];
}

#pragma mark - DraggablePhotoViewDelegate

- (void) draggablePhotoView:(DraggablePhotoView *)photoView shouldUpdateOverlayWithOpacity:(CGFloat)opacity right:(BOOL)right {
  self.statusLabel.hidden = NO;
  self.statusLabel.layer.opacity = opacity;

  self.statusLabel.textColor = right ? [UIColor colorWithRed:0.0F green:1.0F blue:128.0F/255.0F alpha:1.0F] : [UIColor colorWithRed:1.0F green:102.0F/255.0F blue:102.0F/255.0F alpha:1.0f];
  
  self.statusLabel.text = right ? @"Yum!" : @"Ew. Gross.";
}

- (void) draggablePhotoViewDidSwipeLeft:(DraggablePhotoView *)photoView {
  [Flurry logEvent:@"SwipedLeft"];
  [self handleNo];
  
  [self draggablePhotoView:photoView shouldUpdateOverlayWithOpacity:0.0F right:NO];
}

- (void) draggablePhotoViewDidCancel:(DraggablePhotoView *)photoView {
  self.statusLabel.hidden = YES;
}

- (void) draggablePhotoViewDidSwipeRight:(DraggablePhotoView *)photoView {
  //Showing venue
  if (self.didShowAd == NO) {
    if (self.results[self.resultsIndex]) {
      id detail = self.results[self.resultsIndex];
      if (detail[@"categoryId"]) {
        NSString *categoryId = detail[@"categoryId"];
        [Flurry logEvent:@"SwipedRight" withParameters:@{@"categoryId" : categoryId}];
      }
    }
    [self performSegueWithIdentifier:@"ShowDetail" sender:self];
    [self handleNo];
    
    [self draggablePhotoView:photoView shouldUpdateOverlayWithOpacity:0.0F right:YES];
    
  //Dragged right while ad is showing.
  } else {
    self.didShowAd = NO;
    [self handleNo];
  }
}

#pragma mark - Actions

- (IBAction)retryAction:(id)sender {
  self.errorRetryButton.hidden = YES;
  [self loadResults];
}

- (IBAction)leftButtonAction:(id)sender {
  [Flurry logEvent:@"TappedLeft"];
  [self handleNo];
}

- (IBAction)rightButtonAction:(id)sender {
  [Flurry logEvent:@"TappedRight"];
  if (!self.didShowAd) {
    [self performSegueWithIdentifier:@"ShowDetail" sender:self];
    [self performSelector:@selector(handleNo) withObject:nil afterDelay:1.0F];
    
  //Tapped right while ad is showing.
  } else {
    self.didShowAd = NO;
    [self handleNo];
  }
  
}

- (IBAction)priceFilterAction:(id)sender {
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"How fancy are feeling you today?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  
  __weak MainViewController *weakSelf = self;
  
  void (^AddFancinessAction)(NSUInteger fanciness) = ^void(NSUInteger fanciness) {
    NSString *fancinessString = [weakSelf titleForFancinessLevel:fanciness];
    UIAlertAction *fancinessAction = [UIAlertAction actionWithTitle:fancinessString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      [[NSUserDefaults standardUserDefaults] setInteger:fanciness forKey:@"priceFilter"];
      [[NSUserDefaults standardUserDefaults] synchronize];
      [weakSelf updateFancinessButton];
      [weakSelf loadResults];
    }];
    [alertController addAction:fancinessAction];
  };
  
  for (NSUInteger i = 4; i >= 1; i--) {
    AddFancinessAction(i);
  }
  
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {}];
  
  [alertController addAction:cancelAction];
  
  [self.navigationController presentViewController:alertController
                                          animated:YES
                                        completion:^{}];
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  DetailViewController *detailViewController = (DetailViewController*)segue.destinationViewController;
  detailViewController.detail = self.results[self.resultsIndex];
}

#pragma mark - Private

- (NSString*) imageUrlFromResultAtIndex:(NSUInteger)index {
  id result = self.results[index];
  if (result) {
    if (result[@"pictureUrlRaw"]) {
      return result[@"pictureUrlRaw"];
    }
  }
  return nil;
}

- (void) handleNo {
  if (self.resultsIndex < self.results.count - 1) {
    self.resultsIndex++;
  } else {
    self.resultsIndex = 0;
  }
  
  [self updateUi];
  
  if (self.nativeAdImageUrl && self.shouldShowAd) {
    self.didShowAd = YES;
    self.shouldShowAd = NO;
    
    self.draggablePhotoView.advertisement = YES;
    self.draggablePhotoView.imageUrl = self.nativeAdImageUrl;
  }
}

- (NSString*) titleForFancinessLevel:(NSUInteger)fanciness {
  NSMutableString *priceFilterString = [@"" mutableCopy];
  for (NSUInteger i = 0; i < fanciness; i++) {
    [priceFilterString appendString:@"$"];
  }
  return [priceFilterString copy];
}

#pragma mark - Flurry Ad

- (void) fetchAd {
  self.nativeAd = [[FlurryAdNative alloc] initWithSpace:@"main_ad"];
  self.nativeAd.adDelegate = self;
//  nativeAd.viewControllerForPresentation = self;
//  nativeAd.trackingView = self.draggablePhotoView;
  [self.nativeAd fetchAd];
}

- (void) adNativeDidFetchAd:(FlurryAdNative *)nativeAd {
  @try {
  if ([nativeAd isKindOfClass:[FlurryAdNative class]] == NO || !nativeAd || ![nativeAd valueForKey:@"assetList"]) return;

    NSArray *assetList = [nativeAd valueForKey:@"assetList"] ? nativeAd.assetList : nil;
    if (!assetList) return;
    for (int i = 0; i < assetList.count; i++) {
      FlurryAdNativeAsset *asset = assetList.count > i ? assetList[i] : nil;
      if (!asset)return;
      if ([asset.name isEqualToString:@"secHqImage"]) {
        NSString *adUrl = asset.value;
        self.nativeAdImageUrl = adUrl;
        self.shouldShowAd = YES;
        self.didShowAd = NO;
        [self.behindImageView setImageWithURL:[NSURL URLWithString:self.nativeAdImageUrl]];
      }
    }
  }
  @catch (NSException *exception) {
    NSLog(@"caught exception: %@", [exception description]);
  }
  @finally {
    NSLog(@"moving on then");
  }

}

- (void) adNativeWillPresent:(FlurryAdNative *)nativeAd {
  NSLog(@"will present native ad");
}

- (void) adNative:(FlurryAdNative *)nativeAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription {
  NSLog(@"ad native error: %@", errorDescription);
}


@end
