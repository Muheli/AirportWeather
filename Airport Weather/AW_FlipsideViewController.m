//
//  AW_FlipsideViewController.m
//  Airport Weather
//
//  Created by Joseph Sandmeyer on 5/21/13.
//  Copyright (c) 2013 Joseph Sandmeyer. All rights reserved.
//

#import "AW_FlipsideViewController.h"

@interface AW_FlipsideViewController ()

@end

@implementation AW_FlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
