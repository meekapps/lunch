//
//  MainViewController.h
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggablePhotoView.h"
@class RoundedBorderView;

@class CircularButton;

@interface MainViewController : UIViewController <DraggablePhotoViewDelegate>

@property (weak, nonatomic) IBOutlet DraggablePhotoView *draggablePhotoView;
@property (weak, nonatomic) IBOutlet UIImageView *behindImageView;
@property (weak, nonatomic) IBOutlet CircularButton *cancelButton, *okButton;
@property (weak, nonatomic) IBOutlet RoundedBorderView *stackView0, *stackView1, *stackView2;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *errorRetryButton;

- (IBAction)leftButtonAction:(id)sender;
- (IBAction)rightButtonAction:(id)sender;
- (IBAction)retryAction:(id)sender;

@end

