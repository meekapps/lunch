//
//  DraggablePhotoView.h
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//
//  Draggable photo view.

#import <UIKit/UIKit.h>
#import "NibView.h"

@class DraggablePhotoView;
@protocol DraggablePhotoViewDelegate <NSObject>

- (void) draggablePhotoView:(DraggablePhotoView*)photoView shouldUpdateOverlayWithOpacity:(CGFloat)opacity right:(BOOL)right;

- (void) draggablePhotoViewDidCancel:(DraggablePhotoView*)photoView;

- (void) draggablePhotoViewDidSwipeLeft:(DraggablePhotoView*)photoView;

- (void) draggablePhotoViewDidSwipeRight:(DraggablePhotoView*)photoView;

@end

@interface DraggablePhotoView : NibView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (copy, nonatomic) NSString *imageUrl;
@property (weak, nonatomic) IBOutlet UILabel *advertismentLabel;
@property (unsafe_unretained, nonatomic, assign) IBOutlet id <DraggablePhotoViewDelegate> delegate;
@property (nonatomic) BOOL advertisement;

- (IBAction) handlePan:(id)sender;

- (void) resetPosition;

@end
