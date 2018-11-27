//
//  SiteVC.h
//  Diabetes
//
//  Created by Joe DiMaggio on 8/5/12.
//
//

#import <UIKit/UIKit.h>
@class DataService;
@interface SiteVC : UITableViewController

@property (nonatomic,strong) DataService *settings;
@end
