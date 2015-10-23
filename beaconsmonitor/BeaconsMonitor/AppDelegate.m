//
//  AppDelegate.m
//  BeaconsMonitor
//
//  Created by Pedro Jorquera on 17/10/15.
//  Copyright © 2015 Okode. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioToolbox/AudioServices.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Crashlytics class]]];

    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];

    hud.mode = MBProgressHUDModeText;
    hud.labelText = notification.alertBody;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
    
    AudioServicesPlaySystemSound(1007);
}

- (void)applicationWillResignActive:(UIApplication *)application { }

- (void)applicationDidEnterBackground:(UIApplication *)application { }

- (void)applicationWillEnterForeground:(UIApplication *)application { }

- (void)applicationDidBecomeActive:(UIApplication *)application { }

- (void)applicationWillTerminate:(UIApplication *)application { }



@end
