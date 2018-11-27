//
//  GraphController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "Event.h"

@class DataService;
@interface GraphController : UIViewController <CPTPlotDataSource> {

    CPTGraphHostingView *graphHost;
    UIButton *closeButton;
    NSArray *resultSet;
    DataService *settings;
    
@private

    CPTXYGraph *graph;
    NSMutableArray *dataSet;

}

@property(nonatomic,strong) IBOutlet CPTGraphHostingView *graphHost;
@property(nonatomic,strong) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIView *closeButtonView;
@property(nonatomic,strong) NSArray *resultSet;
@property(nonatomic,strong) DataService *settings;

-(IBAction)closeGraph:(id)sender;

@end
