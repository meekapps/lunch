//
//  DraggablePhotoView.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//
//  Draggable photo view.

#import "DraggablePhotoView.h"
#import "UIImageView+AFNetworking.h"

static CGFloat const kDragThreshold = 100.0F;
static CGFloat const kScaleStrength = 4.0F;
static CGFloat const kScaleMax = 0.93F;
static CGFloat const kRotationMax = 1.0F;
static CGFloat const kRotationStrength = 320.0F;
static CGFloat const kRotationAngle = M_PI / 8.0F;

static NSTimeInterval const kFinishAnimationDuration = 0.3;

@interface DraggablePhotoView()
@property (nonatomic) CGPoint startingPoint, translation;
@end

@implementation DraggablePhotoView

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.startingPoint = self.center;
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0F;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 0.5F;
    self.clipsToBounds = YES;
    self.advertisement = NO;
  }
  return self;
}

- (void) setImageUrl:(NSString *)imageUrl {
  _imageUrl = imageUrl;
  
  [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
}

- (void) setAdvertisement:(BOOL)advertisement {
  _advertisement = advertisement;
  
  self.advertismentLabel.hidden = !advertisement;
}

- (IBAction)handlePan:(UIPanGestureRecognizer*)panRecognizer {
  self.translation = [panRecognizer translationInView:self];
  
  switch (panRecognizer.state) {
    case UIGestureRecognizerStateBegan: {
      self.startingPoint = self.layer.position;
      break;
    }
      
    case UIGestureRecognizerStateChanged: {
      
      [self updateWillSwipeDelegate];
      
      CGFloat rotationStrength = MIN(self.translation.x / kRotationStrength, kRotationMax);
      
      CGFloat rotationAngle = (kRotationAngle * rotationStrength);
      
      CGFloat scale = MAX(1 - fabs(rotationStrength) / kScaleStrength, kScaleMax);
      
      self.layer.position = CGPointMake(self.startingPoint.x + self.translation.x, self.startingPoint.y + self.translation.y);
      
      CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngle);
      CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
      
      self.layer.transform = CATransform3DMakeAffineTransform(scaleTransform);
      
      break;
    }
      
    case UIGestureRecognizerStateEnded: {
      [self finishPan];
      break;
    }
    
    case UIGestureRecognizerStatePossible: //Fall through
    case UIGestureRecognizerStateCancelled: //Fall through
    case UIGestureRecognizerStateFailed: //Fall through
    default:
      //do nothing
      break;
  }
}

- (void) updateWillSwipeDelegate {
  
  CGFloat opacity = MIN(fabs(self.translation.x)/100.0F, 1.0F);
  BOOL right = self.translation.x > 0.0F;
  
  if ([self.delegate respondsToSelector:@selector(draggablePhotoView:shouldUpdateOverlayWithOpacity:right:)]) {
    [self.delegate draggablePhotoView:self shouldUpdateOverlayWithOpacity:opacity right:right];
  }
}

- (void) finishPan {
  if (self.translation.x > kDragThreshold) {
    [self rightAction];
    
  } else if (self.translation.x < -kDragThreshold) {
    [self leftAction];
    
  //Not over swipe threshold.
  } else {
    [UIView animateWithDuration:0.3
                     animations:^{
                       [self resetPosition];
                       if ([self.delegate respondsToSelector:@selector(draggablePhotoViewDidCancel:)]) {
                         [self.delegate draggablePhotoViewDidCancel:self];
                       }
                     }];
  }
}


- (void)rightAction {
  CGPoint finishPoint = CGPointMake(self.bounds.size.width * 2.0F, 2.0F * self.translation.y + self.startingPoint.y);
  [UIView animateWithDuration:kFinishAnimationDuration
                   animations:^{
                     self.layer.position = finishPoint;
                   } completion:^(BOOL complete){
                     if ([self.delegate respondsToSelector:@selector(draggablePhotoViewDidSwipeRight:)]) {
                       [self.delegate draggablePhotoViewDidSwipeRight:self];
                     }
                   }];
}

- (void)leftAction {
  CGPoint finishPoint = CGPointMake(-self.bounds.size.width * 2.0F, 2.0F * self.translation.y + self.startingPoint.y);
  [UIView animateWithDuration:kFinishAnimationDuration
                   animations:^{
                     self.center = finishPoint;
                   } completion:^(BOOL complete){
                     if ([self.delegate respondsToSelector:@selector(draggablePhotoViewDidSwipeLeft:)]) {
                       [self.delegate draggablePhotoViewDidSwipeLeft:self];
                     }
                   }];
}

- (void) resetPosition {
  self.layer.position = self.startingPoint;
  self.layer.transform = CATransform3DIdentity;
}


@end
