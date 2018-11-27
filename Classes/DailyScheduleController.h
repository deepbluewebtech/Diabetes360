//
//  DailyScheduleController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"

#import "DailySchedDtlController.h"
#import "DailySchedule.h"



@interface DailyScheduleController : UITableViewController <AddSchedItemDelegate> {
 
    DataService *settings;
    
@private
    
    NSDateFormatter *dateFmt;
    //NSManagedObjectContext *managedObjectContext;  //optimization says not used
    
}

@property (nonatomic,strong) DataService *settings;

@end
