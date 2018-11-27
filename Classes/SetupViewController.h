//
//  SetupViewController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"
@interface SetupViewController : UIViewController <UIWebViewDelegate>{

    DataService   *settings;
    
    UIButton        *okButton;
    UIButton        *backButton;
    UIView          *buttonView;
    UIWebView       *webView;

}

@property (nonatomic, strong) DataService *settings;

@property (nonatomic,strong) UIButton   IBOutlet *okButton;
@property (nonatomic,strong) UIButton   IBOutlet *backButton;
@property (nonatomic,strong) UIView     IBOutlet *buttonView;
@property (nonatomic,strong) UIWebView  IBOutlet *webView;

@property (strong, nonatomic) IBOutlet UIView *startBar;

-(IBAction)showSettings:(id)sender;
-(IBAction)goBack:(id)sender;

@end
