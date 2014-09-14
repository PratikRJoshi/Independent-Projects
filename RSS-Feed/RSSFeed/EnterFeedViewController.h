//
//  EnterFeedViewController.h
//  RSSFeed
//
//  Created by Pratik Joshi on 6/3/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface EnterFeedViewController : UIViewController

@property(strong, nonatomic)NSString* databasePath;

/** Each open SQLite database is represented by a pointer to an instance of
 ** the opaque structure named "sqlite3".  It is useful to think of an sqlite3
 ** pointer as an object.  The [sqlite3_open()], [sqlite3_open16()], and
 ** [sqlite3_open_v2()] interfaces are its constructors, and [sqlite3_close()]
 ** is its destructor.
 */
@property(nonatomic)sqlite3* feedDB;


// the method that is used to insert data into the database
- (IBAction)saveData:(id)sender;

@end
