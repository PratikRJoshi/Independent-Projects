//
//  HousingAppAppDelegate.m
//  Housing
//
//  Created by Pratik Joshi on 6/21/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import "HousingAppAppDelegate.h"

@implementation HousingAppAppDelegate

/**In this method we initialize a NSDictionary object and we set all the values returned by the completion handler 
 ** to it. Then, a new NSNotification object is posted, using the custom name SessionStateChangeNotification and the 
 ** dictionary created right before.
 */
-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI{
    [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:allowLoginUI completionHandler:^(FBSession* session, FBSessionState status, NSError* error){
        
        //Create NSDictionary object and set theparameter values
        NSDictionary* sessionStateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:session, @"session", [NSNumber numberWithInteger:status], @"state", error, @"error",  nil];
        
        //Create a new notification, add the sessionStateInfo dictionary to it and post it.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionStateChangeNotification" object:nil userInfo:sessionStateInfo];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

/** to take our measures in case the user leaves the app while the login dialog is visible either in Facebook app or in Safari. In such a case, it’s necessary to use the Facebook framework for doing some cleanup and removing any unfinished session processes.
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [self openActiveSessionWithPermissions:nil allowLoginUI:NO];
    }
    [FBAppCall handleDidBecomeActive];
}
//
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//    return [FBSession.activeSession handleOpenURL:url];
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
