//
//  ActiveDatabaseVC.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 11/11/11.
//  Copyright (c) 2011 Deep Blue Web Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataService;

@interface ActiveDatabaseVC : UITableViewController <UIAlertViewDelegate> {
    
    NSMutableArray *availableDBArray;
    DataService *settings;
    NSIndexPath *selectedRow;
    
}

@property (nonatomic,strong) DataService *settings;
@property (nonatomic,strong) NSMutableArray *availableDBArray;
@property (nonatomic,strong) NSIndexPath *selectedRow;

-(void)buildActiveDBArray;

@end
/////////////////////