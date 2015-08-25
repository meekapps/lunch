//
//  CircularButton.m
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import "CircularButton.h"

@implementation CircularButton

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.layer.cornerRadius = CGRectGetMidX(self.bounds);
    self.layer.masksToBounds = YES;
  }
  return self;
}

@end
