//
//  FeedrMasterViewController.h
//  RSSFeed
//
//  Created by Pratik Joshi on 6/1/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedrMasterViewController : UITableViewController  <NSXMLParserDelegate>

@property(nonatomic, strong) NSString* title;       //a string to hold the title of the feed
@property(nonatomic, strong) NSURL* url;            // a string to hold the corresponding url for the feed

@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end
