//
//  RoundedBorderView.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import "RoundedBorderView.h"

@implementation RoundedBorderView

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0F;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 0.5F;
  }
  return self;
}

@end
