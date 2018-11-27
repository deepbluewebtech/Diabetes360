//
//  BuyItVC.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 11/22/11.
//  Copyright (c) 2011 Deep Blue Web Technology. All rights reserved.
//

#import "BuyItVC.h"

@implementation BuyItVC
@synthesize buyIt;
@synthesize later;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{

    [self setBuyIt:nil];
    [self setLater:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)buyItAction:(id)sender {
    
    NSLog(@"BuyIt");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/diabetes-360/id474451989?mt=8"]];
}

- (IBAction)laterAction:(id)sender {
    NSLog(@"later");
    [self dismissModalViewControllerAnimated:YES];
}
@end
