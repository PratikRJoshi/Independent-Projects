//
//  HousingAppAppDelegate.h
//  Housing
//
//  Created by Pratik Joshi on 6/21/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface HousingAppAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** Instead of directly calling the openActiveSessionWithReadPermissions:allowLoginUI:completionHandler: method of 
 ** the FBSession class, we declare it here because -
 ** 1. Later on, we’ll have to use the openActiveSessionWithReadPermissions:allowLoginUI:completionHandler: method 
 ** again to open a stored session, and it wouldn’t be a good idea to write the same code twice.
 ** 2. It is a more general solution that can be used in larger projects.
 */
-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;

@end
