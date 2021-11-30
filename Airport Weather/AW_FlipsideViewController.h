//
//  AW_FlipsideViewController.h
//  Airport Weather
//
//  Created by Joseph Sandmeyer on 5/21/13.
//  Copyright (c) 2013 Joseph Sandmeyer. All rights reserved.
//

#import "AW_CompilerFlags.h"
#import <UIKit/UIKit.h>

@class AW_FlipsideViewController;

@protocol AW_FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(AW_FlipsideViewController *)controller;
@end

@interface AW_FlipsideViewController : UIViewController

@property (weak, nonatomic) id <AW_FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
