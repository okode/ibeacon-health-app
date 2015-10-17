//
//  ViewController.h
//  BeaconsMonitor
//
//  Created by Pedro Jorquera on 17/10/15.
//  Copyright © 2015 Okode. All rights reserved.
//

@import CoreLocation;
@import CoreBluetooth;

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate,
UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *beaconTableView;

@end


