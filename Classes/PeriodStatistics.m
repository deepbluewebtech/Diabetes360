//
//  Statistics.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PeriodStatistics.h"
#import "Event.h"

@implementation PeriodStatistics

@synthesize  HiGlucose;
@synthesize  LoGlucose;
@synthesize  AvgGlucose;
@synthesize  HiCarb;
@synthesize  LoCarb;
@synthesize  AvgCarb;

@synthesize detailMonth;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) getHiLoAvgUsing:(NSMutableArray *)theEvents {
    
    HiGlucose = 0;
    LoGlucose = (float)NSIntegerMax;
    
    HiCarb = 0;
    LoCarb = (float)NSIntegerMax;
    AvgGlucose = 0;
    AvgCarb = 0;
    float thisGlucose = 0;
    float thisCarb = 0;
    float carbCount = 0;
    float glucoseCount = 0;
    float sumGlucose = 0;
    float sumCarb = 0;
    
    for (Event *event in theEvents) {
        thisGlucose = [event.glucose floatValue];
        if (thisGlucose < LoGlucose && thisGlucose != 0) {
            LoGlucose = thisGlucose;
        }
        if (thisGlucose > HiGlucose) {
            HiGlucose = thisGlucose;
        }
        if (thisGlucose != 0) {
            sumGlucose += thisGlucose;
            glucoseCount++;
        }
        
        if (event.totalCarb) {
            thisCarb = [event.totalCarb floatValue];
            carbCount++;
            if (thisCarb < LoCarb) {
                LoCarb = thisCarb;
            }
            if (thisCarb > HiCarb) {
                HiCarb = thisCarb;
            }
            sumCarb += thisCarb;
        }
    }
    
    if (carbCount == 0) {
        AvgCarb = 0;
    } else {
        AvgCarb = sumCarb / carbCount;
    }
    
    if (LoGlucose == (float) NSIntegerMax)
        LoGlucose = 0;
    
    if (glucoseCount > 0) {
        AvgGlucose = sumGlucose / glucoseCount;
    } else {
        AvgGlucose = 0;
    }
    
}

-(NSString *) description {
    
    [super description];
    return [NSString stringWithFormat:@"Glucose: %f %f %f \nCarb:%f %f %f",AvgGlucose,HiGlucose,LoGlucose,AvgCarb,HiCarb,LoCarb];
    
}


@end
