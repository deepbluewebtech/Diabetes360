//
//  EventFoodController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event, EventFood, DataService;

@interface EventFoodController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
    Event *event;
    DataService *settings;
    UITableViewCell *eventFoodCell;

    UITableView         *foodTableView;
    
    UIView              *viewForSelectedCell;
    
    UIView              *navItemView;
    UILabel             *carbLabel;
    
@private
    NSMutableArray      *eventFoodDS;
    NSNumberFormatter   *numFmt;
    NSMutableArray		*servingPickerValues;
    NSArray             *servingPickerFractions;
    NSIndexPath         *selectedIndexPath;
    EventFood           *currentEventFood;
    NSSortDescriptor    *measureSortDesc;
    NSArray             *measureSortDescArray;
    NSArray             *pickerWeights;
}
@property (nonatomic, strong) NSMutableArray *eventFoodDS;
@property (nonatomic, strong) DataService *settings;
@property (nonatomic, strong) Event *event;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) NSMutableArray *servingPickerValues;
@property (nonatomic, strong) EventFood *currentEventFood;

@property (nonatomic, strong) NSArray *measureSortDescArray;
@property (nonatomic, strong) NSArray *pickerWeights;

@property (nonatomic, strong) IBOutlet UITableViewCell *eventFoodCell; 
@property (nonatomic, strong) IBOutlet UIView *viewForSelectedCell;
@property (nonatomic,strong) IBOutlet UIView *navItemView;
@property (nonatomic,strong) IBOutlet UILabel *carbLabel;

@property (nonatomic,strong) UITableView *foodTableView;

@property (nonatomic, strong)UIPickerView *measurepicker;
@end
