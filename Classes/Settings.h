//
//  Settings.h
//  Diabetes
//
//  Created by Joe DiMaggio on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, strong) NSNumber * quickSettings;
@property (nonatomic, strong) NSNumber * pumpSiteInterval;
@property (nonatomic, strong) NSNumber * roundingAccuracy;
@property (nonatomic, strong) NSDate * pumpSiteTime;
@property (nonatomic, strong) NSNumber * ketoneThreshold;
@property (nonatomic, strong) NSNumber * useIOB;
@property (nonatomic, strong) NSNumber * glucoseUnit;
@property (nonatomic, strong) NSNumber * calcType;
@property (nonatomic, strong) NSNumber * pumpSiteAlert;
@property (nonatomic, strong) NSNumber * runInitialSetup;
@property (nonatomic, strong) NSNumber * datePickerInterval;

@end
