//
//  OKFirstViewController.h
//  mapfresalud
//
//  Created by Pedro Jorquera on 10/06/14.
//  Copyright (c) 2014 Okode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKPatientViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *txtOutput;
@property (weak, nonatomic) IBOutlet UISwitch *energySwitch;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end
