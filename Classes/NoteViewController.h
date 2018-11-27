//
//  NoteViewController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Event;

@interface NoteViewController : UIViewController <UITextViewDelegate> {
    
    UITextView *note;
    Event *event;
}

@property (nonatomic,strong)  IBOutlet UITextView *note;
@property (nonatomic,strong) Event *event;

@end
