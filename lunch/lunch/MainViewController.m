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

@interface MainViewController ()
@property (strong, nonatomic) NSMutableArray *results;
@property (nonatomic) NSUInteger resultsIndex;
@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self loadResults];
  [self updateUi];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.draggablePhotoView resetPosition];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void) loadResults {
  self.resultsIndex = 0;
  self.results = [@[@"http://nicenicejpg.com/375/375", @"https://placekitten.com/375/375", @"http://placehold.it/375/375"] mutableCopy];
}

- (void) updateUi {
  //Update the draggable view.
  if (self.resultsIndex < self.results.count) {
    self.draggablePhotoView.imageUrl = self.results[self.resultsIndex];
    self.draggablePhotoView.hidden = NO;
    [self.draggablePhotoView resetPosition];
  } else {
    self.draggablePhotoView.hidden = YES;
  }
  
  //Has another one to show behind.
  NSUInteger nextIndex = self.resultsIndex < self.results.count - 1 ? self.resultsIndex + 1 : 0;
  NSString *behindImageUrl = self.results[nextIndex];
  [self.behindImageView setImageWithURL:[NSURL URLWithString:behindImageUrl]];
}

#pragma mark - DraggablePhotoViewDelegate

- (void) draggablePhotoViewDidSwipeLeft:(DraggablePhotoView *)photoView {
  [self handleNo];
}

- (void) draggablePhotoViewDidSwipeRight:(DraggablePhotoView *)photoView {
  [self performSegueWithIdentifier:@"ShowDetail" sender:self];
  [self handleNo];
}

#pragma mark - Actions

- (IBAction)leftButtonAction:(id)sender {
  [self handleNo];
}

- (IBAction)rightButtonAction:(id)sender {
  [self performSegueWithIdentifier:@"ShowDetail" sender:self];
  [self performSelector:@selector(handleNo) withObject:nil afterDelay:1.0F];
}

#pragma mark Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  DetailViewController *detailViewController = (DetailViewController*)segue.destinationViewController;
  detailViewController.imageUrl = self.results[self.resultsIndex];
}

#pragma mark - Private

- (void) handleNo {
  if (self.resultsIndex < self.results.count - 1) {
    self.resultsIndex++;
  } else {
    self.resultsIndex = 0;
  }
  
  [self updateUi];
}

@end
