//
//  Statistics.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeriodStatistics : NSObject {

    float HiGlucose, LoGlucose, AvgGlucose;
    float HiCarb, LoCarb, AvgCarb;
    
    NSDate *detailMonth;

}

- (void)getHiLoAvgUsing:(NSMutableArray *)theEvents;;

@property (nonatomic) float HiGlucose;
@property (nonatomic) float LoGlucose;
@property (nonatomic) float AvgGlucose;
@property (nonatomic) float HiCarb;
@property (nonatomic) float LoCarb;
@property (nonatomic) float AvgCarb;

@property (nonatomic,strong) NSDate *detailMonth;

@end
