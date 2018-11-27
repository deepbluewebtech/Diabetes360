//
//  BuyItVC.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 11/22/11.
//  Copyright (c) 2011 Deep Blue Web Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyItVC : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *buyIt;
@property (strong, nonatomic) IBOutlet UIButton *later;

- (IBAction)buyItAction:(id)sender;
- (IBAction)laterAction:(id)sender;

@end
