//
//  BookmarksTableViewController.h
//  RSSFeed
//
//  Created by Shrikanth Narayanan on 6/9/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BookmarksTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSURL* bookmarkUrl;                    //the url of the bookmark which is used to fetch the feed from the rss source
@property(strong, nonatomic) NSString* databasePath;                //to hold the database path of the sqlite3 database file
@property(nonatomic) sqlite3* feedDB;                               //acts as a handle for the execution of sql statement
@property(nonatomic, retain) NSMutableArray* bookmarkNames;         //to hold all the bookmark titles
@property(nonatomic, retain) NSMutableDictionary* bookmarkValues;   //to hold the urls of feedtitles
@property(nonatomic, retain) NSString* selectedCellText;            // to get the name of bookmark in the text so as to fetch the relevant feed from the database



@property (weak, nonatomic) IBOutlet UITableView *bookmarksOutlet;  //the outlet to display programmatically the content of the bookmarks table

@end
