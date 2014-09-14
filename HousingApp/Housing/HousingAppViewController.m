//
//  HousingAppViewController.m
//  Housing
//
//  Created by Pratik Joshi on 6/21/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import "HousingAppViewController.h"
#import "HousingAppAppDelegate.h"

@interface HousingAppViewController ()

-(void)hideUserInfo:(BOOL)shouldHide;
-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification;

@property (nonatomic, strong) HousingAppAppDelegate* appDelegate;

@end

@implementation HousingAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /* This will turn the dark status bar into a light one. */
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /** To make the image view rounded, with a white border around it. In order to do that, we must access the 
     ** CALayer layer property of it, and set three specific properties of the layer object. However the CALayer
     ** class is not part of the UIKit framework, therefore we must import the QuartzCore framework.
     */
    self.profilePicture.layer.masksToBounds = YES;
    self.profilePicture.layer.cornerRadius = 30.0;
    self.profilePicture.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profilePicture.layer.borderWidth = 1.0;
    
    [self hideUserInfo:YES];
    
    /* The activity indicator will be handled separately from the rest of the subviews */
    self.activityIndicator.hidden = YES;
    
    self.appDelegate = (HousingAppAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    /** With this statement, we force our class to observe for the notification specified by the given name, 
     ** and when it arrives we will call the handleFBSessionStateChangeWithNotification: method.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFBSessionStateChangeWithNotification:) name:@"SessionStateChangeNotification" object:nil];
}

/** From the notification parameter object, we’ll extract the dictionary.
 ** We’ll assign to local variables the session state value and the error object which we’ll take from the dictionary.
 ** We’ll show the appropriate status message, along with the activity indicator.
 ** If no error occurred, then if the session is open we’ll make a call to Facebook Graph API to get all the info we want. If the session is closed or failed, we’ll update the UI.
 ** If an error occurred, we’ll output the error description and perform any UI-related tasks.
 */
-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification{
    // Get the session, state and error values from the notification's userInfo dictionary.
    NSDictionary *userInfo = [notification userInfo];
    
    FBSessionState sessionState = [[userInfo objectForKey:@"state"] integerValue];
    NSError *error = [userInfo objectForKey:@"error"];
    
    self.loginStatus.text = @"Logging you in...";
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    
    // Handle the session state.
    // Usually, the only interesting states are the opened session, the closed session and the failed login.
    if (!error) {
        /** In case that there's not any error, then check if the session opened or closed.
         ** Getting user’s data is easy. 
         ** It takes only a call to the startWithGraphPath:parameters:HTTPMethod:completionHandler: method of the FBRequestConnection class. 
         ** As you conclude from the method’s name, it makes a HTTP request to the appropriate API and sends all the provided parameters, 
         ** which are given as a dictionary object. This method is a general one and can be used for several kinds of requests.
         */
        if (sessionState == FBSessionStateOpen) {
            /** The session is open. Get the user information and update the UI.
             ** Notice that for the profile picture we use the picture.type(normal) value, asking from Facebook to return the normal size picture. There are four picture types that can be used:
                1. Small
                2. Normal
                3. Large
                4. Square
             ** The completion handler of the startWithGraphPath:parameters:HTTPMethod:completionHandler: method contains three parameters:
                1. A FBRequestConnection object. We won’t need it here.
                2. An id object that contains the actual data. In our case, this is going to be a NSDictionary object.
                3. An error pointer.
                4. If no error occurred during the request, then we’ll get the user data from the returned dictionary 
                    and we’ll assign it as a value to the appropriate subview. Also, we’ll get the picture from the returned URL, 
                    and after all UI controls have taken their values, we’ll just unhide them. In case of an error, we’ll only output its description.
             */
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:@{@"fields": @"first_name, last_name, picture.type(normal), email"}
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          NSLog(@"%@", result);
                                          // Set the use full name.
                                          self.userName.text = [NSString stringWithFormat:@"%@ %@",
                                         [result objectForKey:@"first_name"],
                                         [result objectForKey:@"last_name"]];
                
                                          // Set the e-mail address.
                                          self.useEmail.text = [result objectForKey:@"email"];
                
                                          // Get the user's profile picture.
                                          NSURL *pictureURL = [NSURL URLWithString:[[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
                                          self.profilePicture.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
                
                                          // Make the user info visible.
                                          [self hideUserInfo:NO];
                
                                          // Stop the activity indicator from animating and hide the status label.
                                          self.loginStatus.hidden = YES;
                                          [self.activityIndicator stopAnimating];
                                          self.activityIndicator.hidden = YES;
                                      }
                                      else{
                                          NSLog(@"%@", [error localizedDescription]);
                                      }
                                  }];
            [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
            
        }
        else if (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed){
            // A session was closed or the login was failed or canceled. Update the UI accordingly.
            [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
            self.loginStatus.text = @"You are not logged in.";
            self.activityIndicator.hidden = YES;
        }
    }
    else{
        // In case an error has occured, then just log the error and update the UI accordingly.
        NSLog(@"Error: %@", [error localizedDescription]);
        
        [self hideUserInfo:YES];
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        
    }
}


-(void)hideUserInfo:(BOOL)shouldHide{
    self.profilePicture.hidden = shouldHide;
    self.userName.hidden = shouldHide;
    self.useEmail.hidden = shouldHide;
}

-(void)toggleLoginState:(id)sender{
    /** The current session, also named active session, is accessed just like this: [FBSession activeSession].
     ** Using the state property of the active session, we determine if there is an open session or not. 
     ** The two open session states are shown above.
     */
    
    if (([FBSession activeSession].state != FBSessionStateOpen) && ([FBSession activeSession].state!=FBSessionStateOpenTokenExtended)) {
        /** When the user taps on the Login custom button, the openActiveSessionWithPermissions:allowLoginUI: public method of the AppDelegate is first called, which invokes in turn the
         ** openActiveSessionWithReadPermissions:allowLoginUI:completionHandler: of the FBSession class. Once the whole login process is over, we inform the ViewController using a notification, 
         ** where we’ll handle the various session states in a while.
         */
        [self.appDelegate openActiveSessionWithPermissions:@[@"public_profile", @"email"] allowLoginUI:YES];
    }
    else{
        // Close an existing session.
        [[FBSession activeSession] closeAndClearTokenInformation];
        // Update the UI.
        [self hideUserInfo:YES];
        self.loginStatus.hidden = NO;
        self.loginStatus.text = @"You are not logged in.";
    }
}

/** This method is called after the login credentials entry and app authorization have finished in Facebook app or Safari.
 ** The [FBAppCall handleOpenURL:url sourceApplication:sourceApplication]
 ** manages the results of all the actions taken outside the app (successful login/authorization or cancelation), and properly directs the login flow back in our app again.
 */
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
