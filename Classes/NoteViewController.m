//
//  NoteViewController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteViewController.h"
#import "Event.h"

@implementation NoteViewController

@synthesize event;
@synthesize note;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.title = @"Edit Note";
    note.text = event.note;
    [note becomeFirstResponder];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:NO];
    event.note = note.text;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
