//
//  ColorSchemeDtlController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerViewController.h"
#import "ColorScheme.h"
#import "SettingsClass.h"

@protocol AddSchemeDelegate;

@interface ColorSchemeDtlController : UITableViewController <ColorPickerViewControllerDelegate> {
    
    ColorScheme             *colorScheme;
    SettingsClass           *settings;
    NSManagedObjectContext  *managedObjectContext;
    
@private
    
    NSIndexPath *selectedIndexPath;
    UITableView *schemeTableView;
    
}

@property (nonatomic,retain) IBOutlet UITableViewCell *schemeNameCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *screenBgCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *normalTextCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *highlightedTextCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *tableCellBgCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *altTableCellBgCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *buttonTextCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *buttonBgCell;


@property (nonatomic,retain) IBOutlet UITextField     *schemeName;
//these are the swatches next to the static labels.
@property (nonatomic,retain) IBOutlet UILabel         *screenBg;
@property (nonatomic,retain) IBOutlet UILabel         *normalText;
@property (nonatomic,retain) IBOutlet UILabel         *highlightedText;
@property (nonatomic,retain) IBOutlet UILabel         *tableCellBg;
@property (nonatomic,retain) IBOutlet UILabel         *altTableCellBg;
@property (nonatomic,retain) IBOutlet UILabel         *buttonText;
@property (nonatomic,retain) IBOutlet UILabel         *buttonBg;



@property (nonatomic,retain) ColorScheme    *colorScheme;
@property (nonatomic,retain) SettingsClass  *settings;
@property (nonatomic,retain) UITableView    *schemeTableView;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign) id <AddSchemeDelegate> delegate;

@end

@protocol AddSchemeDelegate <NSObject>

- (void) dismissAddScheme;

@end