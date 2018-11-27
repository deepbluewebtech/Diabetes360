//
//  DiabetesLoadUtility.m
//  DiabetesLoadUtility
//
//  Created by joe DiMaggio on 3/4/11.
//  Copyright Deep Blue Web Technology 2011 . All rights reserved.
//
//  This is an in-house utility to load data for the Diabetes 360 app.  It is in no way meant to be and example of brilliant coding standards and was mostly written in a rush to get usable data for the app.  Please do not evaluate the author's skill level from the code herein...
//
#import <objc/objc-auto.h>
#import <CoreData/CoreData.h>
#import <AppKit/AppKit.h>
#import "Event.h"
#import "FoodItem.h"
#import "FoodWeight.h"
#import "InsulinBrand.h"
#import "Site.h"
#import "KetoneValue.h"
#import "DailySchedule.h"
#import "InsulinFactor.h"
#import "InsulinScale.h"
#import "IOBFactor.h"
#import "ExerciseType.h"

NSManagedObjectModel *managedObjectModel();
NSManagedObjectContext *managedObjectContext();

#define LOAD_TEST_EVENTS 1  //set to load test log files; don't ship with log files.
int loadEventTestData();

int i = 0;

int main (int argc, const char * argv[]) {
	
    //objc_startCollectorThread();

    NSManagedObjectContext *context = managedObjectContext();
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];

//Insulin Factor
    [dateFmt setDateFormat:@"yyyy-MM-dd HH:mm"];
    InsulinFactor *insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
    insulinFactorObj.factorId = @"1TR";
    insulinFactorObj.factorValue = [NSNumber numberWithInt:0];
    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 00:00"];
    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
    insulinFactorObj.factorId = @"2CF";
    insulinFactorObj.factorValue = [NSNumber numberWithInt:1];
    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 00:00"];
    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
    insulinFactorObj.factorId = @"3KF";
    insulinFactorObj.factorValue = [NSNumber numberWithInt:1];
    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 00:00"];
    
    //some test data
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"1TR";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:110];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 03:00"];
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"1TR";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:150];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 10:00"];
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"1TR";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:180];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 18:00"];
//    
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"2CF";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:60];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 05:00"];
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"2CF";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:70];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 12:00"];
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"2CF";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:50];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 19:00"];
//    
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"3KF";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:7];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 10:00"];
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"3KF";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:3];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 15:00"];
//    insulinFactorObj = (InsulinFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:context];
//    insulinFactorObj.factorId = @"3KF";
//    insulinFactorObj.factorValue = [NSNumber numberWithInt:6];
//    insulinFactorObj.timeOfDayBegin = [dateFmt dateFromString:@"2000-01-01 22:00"];

    InsulinScale *insulinScaleObj = (InsulinScale *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinScale" inManagedObjectContext:context];
    insulinScaleObj.rangeMin = [NSNumber numberWithInt:200];
    insulinScaleObj.units = [NSNumber numberWithInt:0];
    insulinScaleObj = (InsulinScale *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinScale" inManagedObjectContext:context];
    insulinScaleObj.rangeMin = [NSNumber numberWithInt:300];
    insulinScaleObj.units = [NSNumber numberWithInt:0];
    insulinScaleObj = (InsulinScale *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinScale" inManagedObjectContext:context];
    insulinScaleObj.rangeMin = [NSNumber numberWithInt:400];
    insulinScaleObj.units = [NSNumber numberWithInt:0];
    insulinScaleObj = (InsulinScale *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinScale" inManagedObjectContext:context];
    insulinScaleObj.rangeMin = [NSNumber numberWithInt:500];
    insulinScaleObj.units = [NSNumber numberWithInt:0];

    
//Insulin Brands from plist
    NSLog(@"%@",[NSBundle mainBundle]);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"InsulinBrands" ofType:@"plist"];
    if (!path) {
        NSLog(@"Can't find InsulinBrands.plist");
        return 99;
    }

    NSMutableDictionary *plistRoot = [[NSMutableDictionary alloc] initWithContentsOfFile:path]; //root of plist
    NSArray *insulinFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"InsulinBrands"]];
    NSLog(@"%@",insulinFromPlist);

    InsulinBrand *insulinBrandObj = nil;

    for (NSDictionary *iBrand in insulinFromPlist) {
        NSLog(@"%@",iBrand);
        insulinBrandObj = (InsulinBrand *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinBrand" inManagedObjectContext:context];
        insulinBrandObj.brandName = [iBrand valueForKey:@"brandName"];
        insulinBrandObj.classification = [iBrand valueForKey:@"classification"];
        insulinBrandObj.prescribed = [NSNumber numberWithBool:NO];
        insulinBrandObj.doseInterval = [iBrand valueForKey:@"doseInterval"];
    }

    NSLog(@"\n\nInsulin Brands Loaded...\n\n");
    
//Sites from plist
    path = [[NSBundle mainBundle] pathForResource:@"Sites" ofType:@"plist"];
    if (!path) {
        NSLog(@"Can't find Sites.plist");
        return 99;
    }
    
    plistRoot = [plistRoot initWithContentsOfFile:path]; //root of plist
    NSArray *sitesFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"Sites"]];
    NSLog(@"sitesFromPlist=%@",sitesFromPlist);
    
    Site *siteObj = nil;
    
    for (NSDictionary *site in sitesFromPlist) {
        
        NSLog(@"%@",site);
        siteObj = (Site *)[NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:context];
        siteObj.name = [site valueForKey:@"name"];
        siteObj.active = [site valueForKey:@"active"];
        
        siteObj.useWithPump = [NSNumber numberWithBool:YES];
    }
    
    NSLog(@"\n\nSites Loaded...\n\n");
    
//Ketones from plist
    
    path = [[NSBundle mainBundle] pathForResource:@"KetoneValues" ofType:@"plist"];
    if (!path) {
        NSLog(@"Can't find KetoneValues.plist");
        return 99;
    }
    
    plistRoot = [plistRoot initWithContentsOfFile:path]; //root of plist
    NSArray *ketoneFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"KetoneValues"]];
    NSLog(@"ketoneFromPlist=%@",ketoneFromPlist);
    
    KetoneValue *ketoneObj = nil;
    
    int i=0;
    for (NSDictionary *ketone in ketoneFromPlist) {
        NSLog(@"%@",ketone);
        ketoneObj = (KetoneValue *)[NSEntityDescription insertNewObjectForEntityForName:@"KetoneValue" inManagedObjectContext:context];
        ketoneObj.name = [ketone valueForKey:@"name"];
        ketoneObj.waterAlert = [ketone valueForKey:@"waterAlert"];
        ketoneObj.sortOrder = [NSNumber numberWithInt:i];
        i++;
    }
    
    NSLog(@"\n\nKetones Loaded...\n\n");

    NSNumberFormatter *numFmt = [[NSNumberFormatter alloc] init];

    //Insulin On Board from plist
    
    path = [[NSBundle mainBundle] pathForResource:@"IOBFactors" ofType:@"plist"];
    if (!path) {
        NSLog(@"Can't find IOBFactors.plist");
        return 99;
    }
    
    plistRoot = [plistRoot initWithContentsOfFile:path]; //root of plist
    NSArray *iobFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"IOBFactors"]];
    NSLog(@"IOBFactors=%@",iobFromPlist);
    
    IOBFactor *IOBObj = nil;
    i=0;
    for (NSDictionary *iob in iobFromPlist) {
        NSLog(@"%@",iob);
        IOBObj = (IOBFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"IOBFactor" inManagedObjectContext:context];
        IOBObj.hours           = [numFmt numberFromString:[iob valueForKey:@"hours"]];
        IOBObj.percentReduce   = [numFmt numberFromString:[iob valueForKey:@"percentReduce"]];
        i++;
    }
    NSLog(@"\n\ninsulin on board Loaded...\n\n");
    
    //Exercise Types from plist
    
    path = [[NSBundle mainBundle] pathForResource:@"ExerciseTypes" ofType:@"plist"];
    if (!path) {
        NSLog(@"Can't find ExerciseTypes.plist");
        return 99;
    }
    
    plistRoot = [plistRoot initWithContentsOfFile:path]; //root of plist
    NSArray *ExTypeFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"ExerciseTypes"]];
    NSLog(@"ExTypes=%@",ExTypeFromPlist);
    
    ExerciseType *ExTypeObj = nil;

    i=0;
    for (NSDictionary *ExType in ExTypeFromPlist) {
        NSLog(@"%@",ExType);
        ExTypeObj = (ExerciseType *)[NSEntityDescription insertNewObjectForEntityForName:@"ExerciseType" inManagedObjectContext:context];
        ExTypeObj.typeName      = [ExType valueForKey:@"exerciseType"];
        ExTypeObj.factorValue   = [numFmt numberFromString:[ExType valueForKey:@"factorValue"]];
        i++;
    }
    
    NSLog(@"\n\nExerciseType Loaded...\n\n");
    
//DailySchedule from plist
    
    path = [[NSBundle mainBundle] pathForResource:@"DailySchedule" ofType:@"plist"];
    if (!path) {
        NSLog(@"Can't find DailySchedule.plist");
        return 99;
    }
    
    plistRoot = [plistRoot initWithContentsOfFile:path]; //root of plist
    NSArray *schedFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"DailySchedule"]];
    NSLog(@"schedFromPlist=%@",schedFromPlist);
    
    DailySchedule *schedObj = nil;
    
    i=0;
    for (NSDictionary *sched in schedFromPlist) {
        NSLog(@"%@",sched);
        schedObj = (DailySchedule *)[NSEntityDescription insertNewObjectForEntityForName:@"DailySchedule" inManagedObjectContext:context];
        schedObj.name           = [sched valueForKey:@"name"];
        schedObj.beginTime      = [sched valueForKey:@"beginTime"];
        schedObj.endTime        = [sched valueForKey:@"endTime"];
        schedObj.carbToIngest   = [NSNumber numberWithInt:0]; //[sched valueForKey:@"carbToIngest"];
        schedObj.reminder       = [sched valueForKey:@"reminder"];
        schedObj.insulinDose    = [NSNumber numberWithInt:0];
        schedObj.complexCarb    = [sched valueForKey:@"complexCarb"];
        schedObj.anyTime        = [NSNumber numberWithBool:NO];
        i++;
    }
    
    NSLog(@"\n\nDaily Schedule Loaded...\n\n");

//process USDA sr23_abbr into FoodItem entity  longDesc comes from FOOD_DES.TXT
	NSError *error = nil;
	NSString *abbrevUSDA = [NSString stringWithContentsOfFile:@"/Users/joedimaggio/Documents/iOS Development/USDA Nutrition/output.csv" encoding:NSASCIIStringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error loading output.csv File:\n %@",error);
        return 99;
    }
    NSCharacterSet *cSet = [NSCharacterSet characterSetWithCharactersInString:@"|"];

	NSArray *abbrevRecs = [abbrevUSDA componentsSeparatedByString:@"\n"];
	NSMutableArray *abbrev = [[NSMutableArray alloc] initWithCapacity:8000];

	for (NSString *element in abbrevRecs) {
		[abbrev addObject:[element componentsSeparatedByCharactersInSet:cSet]];
    }
	
	[abbrev removeLastObject];

	NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init]; 

    i=0;
    FoodItem *foodItem = nil;
	for (NSArray *xyz in abbrev) {
		if (i != 0) { // discard first row (the old fashoned way)
			//insert new objects
			foodItem = (FoodItem *)[NSEntityDescription insertNewObjectForEntityForName:@"FoodItem" inManagedObjectContext:context];
            if (!foodItem) {
                NSLog(@"can't create foodItem!!");
                return 99;
            }
			foodItem.ndbNumber = (NSNumber *)[fmt numberFromString:[xyz objectAtIndex:0]];
			foodItem.shortDesc = [xyz objectAtIndex:1];
			foodItem.carb = (NSDecimalNumber *)[fmt numberFromString:[xyz objectAtIndex:2]];
		}
		i++;
	}

	NSLog(@"%d iterations from input array",i);

//Food Weights from USDA file
//-----------------------------------------------
    error = nil;
	NSString *weightUSDA = [NSString stringWithContentsOfFile:@"/Users/joedimaggio/Documents/iOS Development/USDA Nutrition/sr23/weight.txt" encoding:NSASCIIStringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error loading USDA sr23 weight File:\n %@",[error userInfo]);
        return 99;
    }

    
 	NSArray *weightRecs = [weightUSDA componentsSeparatedByString:@"\r\n"];
	NSMutableArray *weightArray = [[NSMutableArray alloc] initWithCapacity:14000];
    cSet = [NSCharacterSet characterSetWithCharactersInString:@"~^"];

    NSDictionary *dict = nil;
    NSArray *tempArray;
    NSString *ndbNumberKey = @"ndbNumberKey";
    NSString *multiplierKey = @"multiplierKey";
    NSString *measureKey = @"measureKey";
    NSString *weightKey = @"weightKey";
    
	for (NSString *element in weightRecs) {
        tempArray = [element componentsSeparatedByCharactersInSet:cSet];
        if ([tempArray count] > 1) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:[tempArray objectAtIndex:1], ndbNumberKey, 
                    [tempArray objectAtIndex:4], multiplierKey,
                    [tempArray objectAtIndex:6], measureKey, 
                    [tempArray objectAtIndex:8], weightKey, nil];
        }
		[weightArray addObject:dict];
	}

    [weightArray removeLastObject];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndbNumberKey" ascending:YES];
    NSArray *sortedWeightArray = [weightArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];

   
    //  read weights into array and sort by ndbNumber    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FoodItem" inManagedObjectContext:context];
    [request setEntity:entity];
	
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"ndbNumber" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    error = nil;
    NSArray *foodItems = [context executeFetchRequest:request error:&error];
	
    if ((error != nil) || (foodItems == nil)) {
        NSLog(@"Error while fetching\n%@",
			  ([error localizedDescription] != nil)
			  ? [error localizedDescription] : @"Unknown Error");
        NSLog(@"%@",[error userInfo]);

        exit(1);
    }	

    //  link them to their foods using control break type of processing
    int f = 0;
    int w = 0;
    int fLimit = [foodItems count];
    int wLimit = [sortedWeightArray count];
    int foodItemNDB, weightNDB;
    float weightMultiplier, weight; 
    float adjWeight = 0;
    NSString *measure;
    FoodWeight *foodWeight = nil;
    FoodItem *thisFoodItem = nil;
    
    do {  // this stops at end of the array that is shorter which is fine for this usage. Logic should ideally test for end of either array so both are processed completely.
        thisFoodItem     = [foodItems objectAtIndex:f];
        foodItemNDB      = [[thisFoodItem ndbNumber] intValue];
        weightNDB        = [[fmt numberFromString:[[sortedWeightArray objectAtIndex:w] valueForKey:@"ndbNumberKey"]] intValue];
        weightMultiplier = [[fmt numberFromString:[[sortedWeightArray objectAtIndex:w] valueForKey:@"multiplierKey"]] floatValue];
        weight           = [[fmt numberFromString:[[sortedWeightArray objectAtIndex:w] valueForKey:@"weightKey"]] floatValue];
        measure          = [[sortedWeightArray objectAtIndex:w] valueForKey:@"measureKey"];
        if (foodItemNDB == weightNDB && f < fLimit && w < wLimit) {
            foodWeight = (FoodWeight *)[NSEntityDescription insertNewObjectForEntityForName:@"FoodWeight" inManagedObjectContext:context];
            [thisFoodItem addFoodWeightsObject:foodWeight];
            if (!foodWeight) {
                NSLog(@"cant create foodWeight!!");
                return 99;
            }
            foodWeight.measure = measure;
            adjWeight = weight / weightMultiplier;
            foodWeight.weight = [NSNumber numberWithFloat:adjWeight];
            //NSLog(@"%d %f %@ %f %f",weightNDB,weightMultiplier,measure,weight,adjWeight);
            //NSLog(@"equal");
            w++;
        } else if (foodItemNDB < weightNDB) {
            //NSLog(@"food < weight");
            //this adds a standard 100g weight as the last weight mainly for those foods with no weight info in the input file (there are many)
            foodWeight = (FoodWeight *)[NSEntityDescription insertNewObjectForEntityForName:@"FoodWeight" inManagedObjectContext:context];
            [thisFoodItem addFoodWeightsObject:foodWeight];
            if (!foodWeight) {
                NSLog(@"cant create foodWeight!!");
                return 99;
            }
            foodWeight.measure = @"100g";
            foodWeight.weight = [NSNumber numberWithInt:100];
            f++;
        } else if (foodItemNDB > weightNDB) {
            //NSLog(@"food > weight");
            w++;
        }
        //NSLog(@"%d %d",foodItemNDB,weightNDB);
    } while (f < fLimit && w < wLimit);
    //NSLog(@"f=%d w=%d",f,w);
       
//    NSColor *color = [NSColor redColor];
//    NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
//    NSLog(@"%@",colorAsData);
//    color = [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
//    NSLog(@"%@",color);
    

    if (LOAD_TEST_EVENTS) {
        int z = 0;
        NSString *fileLocation;
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata.csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(2).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(3).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(4).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(5).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(6).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(7).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(8).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(9).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
        
        fileLocation = @"/Users/joedimaggio/Documents/iOS Development/Diabetes/TestData/randomdata(10).csv";
        z = loadEventTestData(fileLocation, context);
        if (z) return z;
    }
  
    if (![context save:&error]) {
        NSLog(@"Error while saving\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        NSLog(@"%@",[error userInfo]);
        exit(99);
    }
	
	if (error != nil) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
 
    return 0;
}

int loadEventTestData(NSString *fileLocation, NSManagedObjectContext *context) {
    
    NSLog(@"loading random event files");

	NSError *error = nil;
	NSString *randomEventString = [NSString stringWithContentsOfFile:fileLocation encoding:NSASCIIStringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error loading randomdata File:\n %@",error);
        return 99;
    }
    
    NSCharacterSet *fldSep = [NSCharacterSet characterSetWithCharactersInString:@"|"];
    
	NSArray *randomEventRecs = [randomEventString componentsSeparatedByString:@"\n"];
	NSMutableArray *randomEventAttr = [[NSMutableArray alloc] initWithCapacity:8000]; //Nested array: inner array of attributes
    
	for (NSString *rec in randomEventRecs) {
		[randomEventAttr addObject:[rec componentsSeparatedByCharactersInSet:fldSep]];
    }
	
	[randomEventAttr removeLastObject];
	[randomEventAttr removeLastObject];
    [randomEventAttr removeObjectAtIndex:0]; //column headers
    
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init]; 
    
    i=0;
    Event *event = nil;
	for (NSArray *eventIn in randomEventAttr) {
        //insert new objects
        event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
        if (!event) {
            NSLog(@"cant create event!");
            return 99;
        }
        event.eventDate = [NSDate dateWithTimeIntervalSince1970:[[fmt numberFromString:[eventIn objectAtIndex:0]] doubleValue]];
        [dateFmt setDateFormat:@"yyyy-MM-dd"];
        event.fmtDate = [dateFmt stringFromDate:event.eventDate];
        [dateFmt setDateFormat:@"yyyy-MM"];
        event.fmtMonth = [dateFmt stringFromDate:event.eventDate];
        event.glucose = [fmt numberFromString:[eventIn objectAtIndex:1]];
        event.totalCarb = [fmt numberFromString:[eventIn objectAtIndex:2]];
        event.calcType = [NSNumber numberWithInt:0];
        event.targetRate = [NSNumber numberWithInt:120];
        event.corrFactor = [NSNumber numberWithInt:40];
        event.carbFactor = [NSNumber numberWithInt:8];
        event.exerciseFactor = [NSNumber numberWithFloat:1.0f];
        float TR = [event.targetRate floatValue];
        float bs = [event.glucose floatValue];
        float c  = [event.totalCarb floatValue];
        float CF = [event.corrFactor floatValue];
        float KF = [event.carbFactor floatValue];
        float units = ((bs - TR) / CF) + (c / KF);
        event.insulinAmt = [NSNumber numberWithFloat:units];
	}

    return 0;

}

NSManagedObjectModel *managedObjectModel() {
    
    static NSManagedObjectModel *model = nil;
    
    if (model != nil) {
        return model;
    }
    
	
    //this and the one below for the context need to read the arguments and build the path as in CoreDateUtility.  path stuff wasn't behaving so hard coded to get through...just needed a default database for Diabetes app.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Diabetes" ofType:@"momd"];
	NSURL *modelURL = [NSURL fileURLWithPath:path];
    
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    //NSLog(@"\n\n %@ \n\n",model);
    return model;
}

NSManagedObjectContext *managedObjectContext() {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Diabetes" ofType:@"sqlite"];
    NSError *error = nil;
    if (path) { // if database exists, delete it; we are creating a new one
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"Couldn't delete existing database");
        }
    } else {
        path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Diabetes.sqlite"];
    }
	
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    context = [[NSManagedObjectContext alloc] init];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel()];
    [context setPersistentStoreCoordinator: coordinator];
    
    NSString *STORE_TYPE = NSSQLiteStoreType;
	
	NSURL *url = [NSURL fileURLWithPath:path];
    
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
    
    if (newStore == nil) {
        NSLog(@"Store Configuration Failure\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
        NSLog(@"%@",[error userInfo]);
    }
    
    return context;
}
