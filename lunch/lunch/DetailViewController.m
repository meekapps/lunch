//
//  DetailViewController.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Flurry.h"
#import "MapAnnotation.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.goButton.layer.cornerRadius = 5.0F;
  
  //Photo
  if (self.detail[@"pictureUrlRaw"]) {
    NSString *pictureUrlString = self.detail[@"pictureUrlRaw"];
    [self.imageView setImageWithURL:[NSURL URLWithString:pictureUrlString]];
  }
  
  //Title
  if (self.detail[@"name"]) {
    NSString *title = self.detail[@"name"];
    self.title = title;
  }
  
  //Detail
  if (self.detail[@"location"] && self.detail[@"name"] && self.detail[@"categoryName"]) {
    id location = self.detail[@"location"];
    if (location[@"distance"]) {
      NSString *nameString = self.detail[@"name"];
      NSString *categoryString = [self.detail[@"categoryName"] lowercaseString];
      NSString *distanceString = location[@"distance"];
      NSString *optionalPriceString = self.detail[@"price"] ? [NSString stringWithFormat:@"It's %@,", [self.detail[@"price"] lowercaseString]] : @"It";
      NSString *fullDescription = [NSString stringWithFormat:@"%@ is a %@. %@ is %@ meters away, and is open right now.", nameString, categoryString, optionalPriceString, distanceString];
      self.textView.text = fullDescription;
    }
  }
  
  //Map
  CLLocationCoordinate2D coordinate = [self placeCoordinate];
  MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)];
  [self.mapView setRegion:adjustedRegion animated:YES];
}

- (CLLocationCoordinate2D) placeCoordinate {
  if (self.detail[@"location"]) {
    id location = self.detail[@"location"];
    if (location[@"lat"] && location[@"lng"]) {
      NSString *latString = location[@"lat"];
      NSString *longString = location[@"lng"];
      CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latString doubleValue], [longString doubleValue]);
      return coordinate;
    }
  }
  return CLLocationCoordinate2DMake(0, 0);
}

- (void) mapViewDidFinishLoadingMap:(MKMapView *)mapView {
  //Add pins
  MapAnnotation *annotation = [[MapAnnotation alloc] init];
  annotation.coordinate = [self placeCoordinate];
  [self.mapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
  
  static NSString* ShopAnnotationIdentifier = @"AnnotationId";
  MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ShopAnnotationIdentifier];
  if (!pinView) {
    pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ShopAnnotationIdentifier];
    pinView.pinColor = MKPinAnnotationColorGreen;
  }
  return pinView;
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
      
      [Flurry logEvent:@"OpenedMap"];
      [mapItem openInMapsWithLaunchOptions:nil];
      
    }
  }
}

@end
