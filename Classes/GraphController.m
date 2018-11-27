//
//  GraphController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphController.h"
#import "DataService.h"
#import "InsulinFactor.h"

@interface GraphController () 

-(void) buildDataSet;

@end

@implementation GraphController

float maxAvg = 0;
float minTargetRate;
float maxTargetRate;

@synthesize graphHost;
@synthesize closeButton;
@synthesize resultSet;
@synthesize settings;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

-(BOOL)shouldAutorotate {
    return NO;
}



#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}



-(void)viewDidLoad 
{
    [super viewDidLoad];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InsulinFactor" inManagedObjectContext:settings.managedObjectContext];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"factorValue" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"factorId = %@",@"1TR"];
    [request setPredicate:pred];
    
    NSError *error = nil;
    NSArray *result = [settings.managedObjectContext executeFetchRequest:request error:&error];
    if (error) [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ viewDidLoad",self.class]];

    maxTargetRate = [[settings glucoseConvert:[[result objectAtIndex:0] valueForKey:@"factorValue"] toExternal:YES] floatValue];
    minTargetRate = [[settings glucoseConvert:[[result lastObject] valueForKey:@"factorValue"] toExternal:YES] floatValue];
                     
    [self buildDataSet];

    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    //graph.title = @"Glucose By Hour";
    self.graphHost.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    self.graphHost.hostedGraph = graph;
	
    graph.paddingLeft = 10.0f;
	graph.paddingTop = 10.0f;
	graph.paddingRight = 10.0f;
	graph.paddingBottom = 10.0f;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
    NSNumber *xRangeLoc = [NSNumber numberWithFloat:(float)(-1.0f * 4.0f * 60.0f * 60.0f)];
    NSNumber *xRangeLen = [NSNumber numberWithFloat:(float)(31.0f * 60.0f * 60.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:xRangeLoc length:xRangeLen];  // these control what part of graph is visible on initial display
    
    NSNumber *yRangeLoc = [NSNumber numberWithFloat:(float)(-1.0f * (maxAvg * 0.30f))];
    NSNumber *yRangeLen = [NSNumber numberWithFloat:(float)(maxAvg + (maxAvg * 0.5f))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:yRangeLoc length:yRangeLen];
    
    // Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    
    NSNumber *floatNum = [NSNumber numberWithFloat:(60.0f * 60.0f * 6.0f)];
    x.majorIntervalLength = floatNum;
    x.orthogonalPosition = [NSNumber numberWithFloat:0.0f];
    x.minorTicksPerInterval = 5;
    x.title = @"Hour of Day";
    
    //   [x.labelFormatter setMaximumFractionDigits:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterNoStyle;
    dateFormatter.timeStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *myDateFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:2000];
    [comps setMonth:1];
    [comps setDay:1];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    myDateFormatter.referenceDate = [calendar dateFromComponents:comps];
    x.labelFormatter = myDateFormatter;

    CPTXYAxis *y = axisSet.yAxis;
    
    NSNumberFormatter *labelFmt = [NSNumberFormatter new];
    labelFmt.maximumFractionDigits = 0;
    y.labelFormatter = labelFmt;
    
    if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
        y.majorIntervalLength = [NSNumber numberWithFloat:5.0f];
        y.minorTicksPerInterval = 0;
        y.orthogonalPosition = [NSNumber numberWithFloat:0.0f];
    } else {
        y.majorIntervalLength = [NSNumber numberWithFloat:50.0f];
        y.minorTicksPerInterval = 0;
        y.orthogonalPosition = [NSNumber numberWithFloat:0.0f];
    }
    y.title = @"Glucose";

	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
    barPlot.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1 green:1 blue:0 alpha:0.25f]];
    barPlot.barWidth = [NSNumber numberWithFloat:((24.0f * 60.0f * 60.0f) - 500)];
    barPlot.baseValue = [NSNumber numberWithFloat:(minTargetRate - (minTargetRate * 0.1f))];
    barPlot.dataSource = self;
    [graph addPlot:barPlot];
        
	CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit = 1.0f;
	lineStyle.lineWidth = 2.0f;
	lineStyle.lineColor = [CPTColor greenColor];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.identifier = @"GreenPlot";
    boundLinePlot.dataSource = self;
	[graph addPlot:boundLinePlot];

    
	// Add plot symbols
	CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPTColor blackColor];
	CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(5.0, 5.0);
    boundLinePlot.plotSymbol = plotSymbol;

    x.visibleRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:0.0f] length:[NSNumber numberWithFloat:(24 * 60 * 60)]];
    if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
        y.visibleRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:(0.3f)] length:[NSNumber numberWithFloat:(maxAvg * 1.5f)]];
    } else {
        y.visibleRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:(0.3f)] length:[NSNumber numberWithFloat:(maxAvg * 1.5f)]];
    }

//    NSLog(@"%f %f %f %f",closeButton.frame.size.width,closeButton.frame.size.height,closeButton.frame.origin.x,closeButton.frame.origin.y);
//    CGRect frame = closeButton.frame;
//    frame.origin.y = 438;
//    closeButton.frame = frame;
//    NSLog(@"%f %f %f %f\n\n",closeButton.frame.size.width,closeButton.frame.size.height,closeButton.frame.origin.x,closeButton.frame.origin.y);
    [graphHost addSubview:closeButton];  // this is not putting button where I'd expect.  Leaving for now.  It's at top left though frame shows much different.
    
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    
    if ([plot isMemberOfClass:[CPTScatterPlot class]]) {
        return [dataSet count];
    } else if ([plot isMemberOfClass:[CPTBarPlot class]]) {
        return 1;
    } else {
        return 0;
    }
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{

    if ([plot isMemberOfClass:[CPTBarPlot class]]) {
        if (fieldEnum == CPTBarPlotFieldBarTip) {
            return [NSNumber numberWithFloat:maxTargetRate + (maxTargetRate * 0.1f)];
        } else if (fieldEnum == CPTBarPlotFieldBarLocation) {
            return [NSNumber numberWithInt:(24 * 60 * 60 / 2) + 240];
        }
    } else {

        NSNumber *num;
        if (fieldEnum == CPTScatterPlotFieldX) {
            unsigned long x = index * 3600;
            num = [NSNumber numberWithUnsignedInteger:x];
        } else {
            int sum = [[[dataSet objectAtIndex:index] valueForKey:@"sum"] intValue];
            int count = [[[dataSet objectAtIndex:index] valueForKey:@"count"] intValue];
            if (count > 0) {
                num = [NSNumber numberWithInt:sum/count];
            } else {
                num = 0;
            }
        }
        //NSLog(@"%d",[num intValue]);
        return num;
        
    }
    
    return [NSNumber numberWithInt:0];
    
}

-(IBAction)closeGraph:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)buildDataSet {

    dataSet = [[NSMutableArray alloc] initWithCapacity:24];
    for (int i=0; i<24; i++) {
        [dataSet addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"sum",[NSNumber numberWithInt:0],@"count", nil]];
    }
    
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *eventHour;
    NSMutableDictionary *bucket;

    float sum, count;
    maxAvg = 0;
    for (Event *event in resultSet) {
        if ([event.glucose floatValue] == 0) {
            continue;
        }
        eventHour = [cal components:(NSHourCalendarUnit) fromDate:event.eventDate];
        bucket = [dataSet objectAtIndex:[eventHour hour]];
        count = [[bucket valueForKey:@"count"] floatValue];
        count++;
        [bucket setValue:[NSNumber numberWithFloat:count] forKey:@"count"];
        sum = [[bucket valueForKey:@"sum"] floatValue];
        sum += [[settings glucoseConvert:event.glucose toExternal:YES] floatValue];
        [bucket setValue:[NSNumber numberWithFloat:sum] forKey:@"sum"];
    }
    
    for (int i=0; i < [dataSet count]; i++) {
        sum = [[[dataSet objectAtIndex:i] valueForKey:@"sum"] floatValue];
        count = [[[dataSet objectAtIndex:i] valueForKey:@"count"] floatValue];
        if (maxAvg <= (sum / count)) maxAvg = sum / count;
    }
    
}

@end
