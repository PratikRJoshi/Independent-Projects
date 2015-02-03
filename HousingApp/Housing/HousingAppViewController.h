//
//  HousingAppViewController.h
//  Housing
//
//  Created by Pratik Joshi on 6/21/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK.h"
#import <QuartzCore/QuartzCore.h>

@interface HousingAppViewController : UIViewController<FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *useEmail;
@property (weak, nonatomic) IBOutlet UILabel *loginStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

-(IBAction)toggleLoginState:(id)sender;
@end
