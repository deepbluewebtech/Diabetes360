//
//  HomeViewController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "SettingsController.h"
#import "DataService.h"
#import "EventDetailTblController.h"

@interface RootViewController : UIViewController <AddEventDelegate, ADBannerViewDelegate> {

    DataService *settings;
    UIButton *graphButton;
    UIButton *addButton;
    UIButton *foodButton;
    
@private
    NSManagedObjectContext *managedObjectContext_;

}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) DataService *settings;
@property (nonatomic, strong) IBOutlet UIButton *graphButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
@property (nonatomic, strong) IBOutlet UIButton *foodButton;
@property (strong, nonatomic) IBOutlet UIButton *exportButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UILabel *activeDBName;
@property (strong, nonatomic) IBOutlet ADBannerView *adBanner;
@property (strong, nonatomic) IBOutlet UIView *rootView;

-(IBAction) showLogs;
-(IBAction) showSettings;
-(IBAction) showFood:(id)sender;
-(IBAction) addEvent:(id)sender;
-(IBAction) showCriteriaForExport:(id)sender;

@end