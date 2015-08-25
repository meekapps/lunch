//
//  PhotoView.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//
//  Draggable photo view.

#import "PhotoView.h"

@implementation PhotoView

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    UIView *topLevelView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:kNilOptions].firstObject;
    [self addSubview:topLevelView];
  }
  
  return self;
}

- (IBAction)handlePan:(id)sender {
  NSLog(@"pan");
}

@end
