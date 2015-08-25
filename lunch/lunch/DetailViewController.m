//
//  DetailViewController.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.goButton.layer.cornerRadius = 5.0F;
  
  //Photo
  if (self.detail[@"pictureUrlCropped"]) {
    NSString *pictureUrlString = self.detail[@"pictureUrlCropped"];
    [self.imageView setImageWithURL:[NSURL URLWithString:pictureUrlString]];
  }
  
  //Title
  if (self.detail[@"name"]) {
    NSString *title = self.detail[@"name"];
    self.title = title;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (IBAction)goAction:(id)sender {
  if (self.detail[@"location"]) {
    id location = self.detail[@"location"];
    if (location[@"lat"] && location[@"lng"]) {
      
      NSString *latitudeString = location[@"lat"];
      NSString *longitudeString = location[@"lng"];
      
      CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitudeString doubleValue], [longitudeString doubleValue]);
     
      MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                     addressDictionary:nil];
      MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
      [mapItem setName:self.title];
      
      [mapItem openInMapsWithLaunchOptions:nil];
    }
  }
}

@end
