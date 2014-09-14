//
//  BrowseTableViewController.h
//  RSSFeed
//
//  Created by Shrikanth Narayanan on 6/7/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BrowseTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray* feedNames;            //array to hold the list of feed names
@property (nonatomic, retain) NSMutableDictionary* feed_names;      //a dictionary to hold the URLs of the corresponding feed names
@property(strong, nonatomic)NSString* databasePath;                 // a string to hold the path to the database sqlite3 file
@property (nonatomic, retain) NSString* selectedCellText;           //a string that holds the content of particular table's cell which is mapped later to the URL
@property(nonatomic)sqlite3* feedDB;                                //an sqlite3 database object


@property (weak, nonatomic) IBOutlet UITableView *browseView;


-(void)loadFeedNames;                                               // a method that displays the contents in the table when the view is loaded

@end
