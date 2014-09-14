//
//  FeedrDetailViewController.h
//  RSSFeed
//
//  Created by Pratik Joshi on 6/1/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "EnterFeedViewController.h"
#import "EvernoteSDK.h"

@interface FeedrDetailViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIWebViewDelegate>
//@interface FeedrDetailViewController : UIViewController <UIWebViewDelegate>

@property (copy, nonatomic) NSString *url;
@property (nonatomic, retain) NSURLRequest* request;
@property (nonatomic, strong, readwrite) NSURLConnection* connection;       //a connection object to handle the redirection of the URL
@property (nonatomic, strong) NSString* dbPath;
@property (nonatomic) sqlite3* feedDB;
@property (nonatomic) NSString* feedTitle;

- (IBAction)saveBookmark:(id)sender;

- (IBAction)saveToEvernote:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
