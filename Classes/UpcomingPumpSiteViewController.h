//
//  UpcomingPumpSiteViewController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataService;
@interface UpcomingPumpSiteViewController : UITableViewController {
    
@private
    
    NSMutableArray *reminders;
    NSDateFormatter *dateFmt;
    DataService *settings;
    
}

@property (nonatomic,strong) NSMutableArray *reminders;
@property (nonatomic,strong) NSDateFormatter *dateFmt;
@property (nonatomic,strong) DataService *settings;;

@end
