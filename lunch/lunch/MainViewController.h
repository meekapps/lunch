//
//  MainViewController.h
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggablePhotoView.h"

@class CircularButton;

@interface MainViewController : UIViewController <DraggablePhotoViewDelegate>

@property (weak, nonatomic) IBOutlet DraggablePhotoView *draggablePhotoView;
@property (weak, nonatomic) IBOutlet UIImageView *behindImageView;
@property (weak, nonatomic) IBOutlet CircularButton *cancelButton, *okButton;

- (IBAction)leftButtonAction:(id)sender;
- (IBAction)rightButtonAction:(id)sender;

@end

