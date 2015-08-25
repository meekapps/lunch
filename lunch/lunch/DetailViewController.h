//
//  DetailViewController.h
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detail;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)goAction:(id)sender;

@end
