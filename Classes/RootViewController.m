//
//  HomeViewController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "GraphController.h"
#import "FoodController.h"
#import "Event.h"
#import "InsulinBrand.h"
#import "KetoneValue.h"
#import "Site.h"
#import "EventFood.h"
#import "FoodItem.h"
#import "LogByMonthViewController.h"
#import "PredicateCriteriaController.h"
#import "Appirater.h"

@interface RootViewController ()
-(void) moveBannerViewOnScreen;
-(void) moveBannerViewOffScreen;
@end

@implementation RootViewController

@synthesize managedObjectContext=managedObjectContext_;
@synthesize settings;
@synthesize graphButton;
@synthesize addButton;
@synthesize foodButton;
@synthesize exportButton;
@synthesize settingsButton;
@synthesize activeDBName;
@synthesize adBanner;
@synthesize rootView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                              style: UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];
    [self.navigationController.navigationBar setTintColor:settings.kNavBarColor];
    self.navigationController.navigationController.navigationBar.translucent = YES;

}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    self.title = @"Diabetes 360";
    self.adBanner.hidden = YES;
    
#ifdef LOG_MAX_FOR_LITE
    self.title = @"Diabetes 360 Lite";
    self.adBanner.hidden = NO;
    self.foodButton.hidden = YES;
    self.exportButton.hidden = YES;
    self.graphButton.hidden = YES;
    CGRect frame = self.settingsButton.frame;
    frame.origin.x = 210;
    frame.origin.y = 10;
    self.settingsButton.frame = frame;
    
#endif
    
    
    activeDBName.text = [settings.activeDBName stringByDeletingPathExtension];
    
    
}
- (void)viewDidUnload
{
    [self setActiveDBName:nil];
    [self setAdBanner:nil];
    [self setRootView:nil];
    [self setExportButton:nil];
    [self setSettingsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - banner view delegate

-(void) moveBannerViewOnScreen {
    
    CGRect newBannerFrame = self.adBanner.frame;
    newBannerFrame.origin.y = self.view.frame.size.height - newBannerFrame.size.height;
    
    CGRect originalSibViewFrame = self.rootView.frame;
    CGFloat newSibViewHeight = self.view.frame.size.height - newBannerFrame.size.height;
    CGRect newSibViewFrame = originalSibViewFrame;
    newSibViewFrame.size.height = newSibViewHeight;
    
    [UIView setAnimationDuration:0.75f];
    [UIView beginAnimations:@"BannerViewIntro" context:NULL];
    self.rootView.frame = newSibViewFrame;
    self.adBanner.frame = newBannerFrame;
    [UIView commitAnimations];
    
}

-(void) moveBannerViewOffScreen {
    
    CGRect originalSibViewFrame = self.rootView.frame;
    CGFloat newSibViewHeight = self.view.frame.size.height;
    CGRect newSibViewFrame = originalSibViewFrame;
    newSibViewFrame.size.height = newSibViewHeight;
    
    CGRect newBannerFrame = newSibViewFrame;
    newBannerFrame.origin.y = newSibViewHeight;
    
    self.rootView.frame   = newSibViewFrame;
    self.adBanner.frame = newBannerFrame;
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{

    [self moveBannerViewOffScreen];
    
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    
    [self moveBannerViewOnScreen];
    
}

#pragma mark buttons

- (void)addEvent:(id)sender {

    
#ifdef LOG_MAX_FOR_LITE

    if ([settings refreshLogCount] >= LOG_MAX_FOR_LITE) {
        [settings showBuyFullVersion:self];
        return;
    }

#endif
    
    EventDetailTblController *addController = [[EventDetailTblController alloc] initWithNibName:@"EventDetailTblController" bundle:nil];
    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    
    newEvent.totalCarb = NULL;
    
    addController.managedObjectContext = self.managedObjectContext;

    addController.event = (Event *)newEvent;
    addController.settings = self.settings;
    addController.delegate = self;

    // Create the nav controller and add the view controllers.
    UINavigationController *theNavController = [[UINavigationController alloc]
                                                initWithRootViewController:addController];
    
    theNavController.navigationBar.tintColor = settings.kNavBarColor;
    
    [self presentModalViewController:theNavController animated:YES];
    
}

- (void)dismissAddEvent {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)showFood:(id)sender {
    
    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    
    FoodController *foodController = [[FoodController alloc] initWithNibName:@"FoodController" bundle:nil];
    foodController.managedObjectContext = self.managedObjectContext;
    newEvent.isDummy = [NSNumber numberWithBool:YES];
    foodController.event = newEvent;
    foodController.settings = self.settings;
    [self.navigationController pushViewController:foodController animated:YES];
    
}

-(IBAction) showLogs {
    
    LogByMonthViewController *logController = [[LogByMonthViewController alloc] initWithNibName:@"LogByMonthViewController" bundle:nil];
    logController.managedObjectContext = self.managedObjectContext;
    logController.settings = self.settings;
    
    [self.navigationController pushViewController:logController animated:YES];
    
}

-(IBAction)showCriteriaForExport:(id)sender {
    
    PredicateCriteriaController *controller = [[PredicateCriteriaController alloc] initWithNibName:@"PredicateCriteriaController" bundle:nil];
    controller.settings = self.settings;
    
    if ([[[(UIButton *)sender titleLabel] text] isEqualToString:@"Graph"]) {
        controller.nextController = NEXT_IS_GRAPH;
    } else {
        controller.nextController = NEXT_IS_MAIL;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    
    
    
}

-(IBAction) showSettings {
    
    
    SettingsController *settingsController = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
    settingsController.settings = self.settings;
    self.title = @"Home";
    [self.navigationController pushViewController:settingsController animated:YES];

}

@end
