//
//  PhotoView.h
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//
//  Draggable photo view.

#import <UIKit/UIKit.h>

@interface PhotoView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)handlePan:(id)sender;

@end
