//
//  FoodController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/8/11.
//  Copyright 2011 Deep Blue Web Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@class EventFood, Event, FoodItem, DataService;

@interface FoodController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    
    Event *event;
    
    NSMutableArray *foodArray;
	NSMutableArray *filteredFoodArray;	// The content filtered as a result of a search.
    UIActivityIndicatorView *activityIndicator;
    
    UIView *viewForSelectedCell;
    
    DataService *settings;
    
@private
    
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    NSNumberFormatter *numFmt;
    NSTimer *filterTimer;

}

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSMutableArray *foodArray;
@property (nonatomic, strong) NSMutableArray *filteredFoodArray;
@property (nonatomic, strong) DataService *settings;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIView *viewForSelectedCell;

@property (nonatomic,strong)  NSTimer *filterTimer;

-(void) showServings;

@end
