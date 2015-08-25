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

@interface MainViewController ()
@property (strong, nonatomic) NSArray *results;
@property (nonatomic) NSUInteger resultsIndex;
@property (nonatomic) BOOL showingError;
@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.results = nil;
  self.resultsIndex = 0;
  self.showingError = NO;
  self.statusLabel.text = @"";
  
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
  NSString *urlString = [NSString stringWithFormat:@"https://lunchserver.herokuapp.com/search?latitude=%@&longitude=%@", latitudeNumber, longitudeNumber];
  NSLog(@"requesting: %@", urlString);
  __weak MainViewController *weakSelf = self;
  [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString]
                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  
                                  if (error) {
                                    NSLog(@"error: %@", error);
                                    [self showErrorIfNeeded];
                                  } else {
                                    NSError *jsonError = nil;
                                    id result = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:NSJSONReadingAllowFragments
                                                                                  error:&jsonError];
                                    if (jsonError) {
                                      NSLog(@"json error: %@", jsonError);
                                      [self showErrorIfNeeded];
                                    } else {
                                      if (result[@"venues"]) {
                                        weakSelf.results = result[@"venues"];
                                        NSLog(@"result: %@", result);
                                        [weakSelf updateUi];
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
  [self handleNo];
  
  [self draggablePhotoView:photoView shouldUpdateOverlayWithOpacity:0.0F right:NO];
}

- (void) draggablePhotoViewDidCancel:(DraggablePhotoView *)photoView {
  self.statusLabel.hidden = YES;
}

- (void) draggablePhotoViewDidSwipeRight:(DraggablePhotoView *)photoView {
  [self performSegueWithIdentifier:@"ShowDetail" sender:self];
  [self handleNo];
  
  [self draggablePhotoView:photoView shouldUpdateOverlayWithOpacity:0.0F right:YES];
}

#pragma mark - Actions

- (IBAction)retryAction:(id)sender {
  NSLog(@"retry");
}

- (IBAction)leftButtonAction:(id)sender {
  [self handleNo];
}

- (IBAction)rightButtonAction:(id)sender {
  [self performSegueWithIdentifier:@"ShowDetail" sender:self];
  [self performSelector:@selector(handleNo) withObject:nil afterDelay:1.0F];
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
    if (result[@"pictureUrlCropped"]) {
      return result[@"pictureUrlCropped"];
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
}

@end
