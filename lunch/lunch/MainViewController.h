//
//  MainViewController.h
//  lunch
//
//  Created by Mike Keller on 8/25/15.
//  Copyright (c) 2015 Meek Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularButton.h"

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet CircularButton *cancelButton, *okButton;

@end

