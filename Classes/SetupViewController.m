//
//  SetupViewController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SetupViewController.h"
#import "SettingsController.h"
#import "RootViewController.h"

@implementation SetupViewController

@synthesize settings;
@synthesize okButton;
@synthesize backButton;
@synthesize buttonView;
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

    CGRect screenRect = [[UIScreen mainScreen] bounds];

    
    NSLog(@"height=%f",screenRect.size.height);
    CGRect frame = self.startBar.frame;
    frame.origin.y = screenRect.size.height - frame.size.height + 1;
    self.startBar.frame = frame;
    
    self.navigationController.navigationBarHidden = YES;
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WelcomeContent" ofType:@"html"];
    NSString *theHTML = [[NSString alloc] initWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    [webView loadHTMLString:theHTML baseURL:nil];
    webView.delegate = self;

}

- (void)viewDidUnload
{

    [self setStartBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        backButton.hidden = YES;
        _webView.scalesPageToFit = NO;
    } else {
        backButton. hidden = NO; 
        _webView.scalesPageToFit = YES;
    }
    
    return YES;
    
}

#pragma mark -

-(IBAction)showSettings:(id)sender {
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    SettingsController *settingsController = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
    settingsController.settings = self.settings;
    
    RootViewController *rootController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    rootController.managedObjectContext = settings.managedObjectContext;
    rootController.settings = self.settings;

    NSArray *newStack = [[NSArray alloc] initWithObjects:rootController, settingsController, nil];
    [self.navigationController setViewControllers:newStack animated:YES];
    
}

-(IBAction)goBack:(id)sender {
    NSLog(@"goback");
    [webView goBack];
}

@end
