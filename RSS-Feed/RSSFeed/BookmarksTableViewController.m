//
//  BookmarksTableViewController.m
//  RSSFeed
//
//  Created by Shrikanth Narayanan on 6/9/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "FeedrMasterViewController.h"
#import "FeedData.h"

@interface BookmarksTableViewController (){
    
    FeedData* bookmark;
    
    //a mutable array to hold the bookmarks
    NSMutableArray* bookmarkHolder;
}

@end

@implementation BookmarksTableViewController


-(void)loadBookmarks{
    NSArray* dirPath;       //array to hold the various directories in the default path which is /Users/(username)/Library/Application Support/iPhone Simulator/7.0.3/Applications/D0A73C9E-C886-431C-B708-9C18E0049BD1/Documents
    NSString* docsDir;      // holds the path to the documents directoryh which is the first element in the above array
    
    //initialize the bookmark variables
    _bookmarkNames = [[NSMutableArray alloc]init];
    _bookmarkValues = [[NSMutableDictionary alloc]init];
    
    /** Creates a list of directory search paths.
     ** Creates a list of path strings for the specified directories in the specified domains. 
     ** The list is in the order in which you should search the directories. If expandTilde is YES, tildes are expanded as described in stringByExpandingTildeInPath.
     ** stringByExpandingTildeInPath - Returns a new string made by expanding the initial component of the receiver to its full path value.*/
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPath[0];
    
    //build the path to the database file
    _databasePath = [[NSString alloc]initWithString:[docsDir stringByAppendingPathComponent:@"feedDB.db"]];
    
    //retreive values from the database
    const char* dPath = [self.databasePath UTF8String];
    
    /** An instance of this object represents a single SQL statement.
     ** This object is variously known as a "prepared statement" or a
     ** "compiled SQL statement" or simply as a "statement".*/
    sqlite3_stmt* statement;
    
    /** sqlite3_open() and sqlite3_open_v2() - These routines open an SQLite database file as specified by the filename argument.
     ** The filename argument is interpreted as UTF-8 for sqlite3_open() and sqlite3_open_v2()
     ** A [database connection] handle is usually
     ** returned in *ppDb, even if an error occurs.  The only exception is that
     ** if SQLite is unable to allocate memory to hold the [sqlite3] object,
     ** a NULL will be written into *ppDb instead of a pointer to the [sqlite3]
     ** object.
     ** If the database is opened (and/or created) successfully, then
     ** [SQLITE_OK] is returned.  Otherwise an [error code] is returned. The
     ** [sqlite3_errmsg()] or [sqlite3_errmsg16()] routines can be used to obtain
     ** an English language description of the error following a failure of any
     ** of the sqlite3_open() routines. 
    */
    if (sqlite3_open(dPath, &_feedDB) == SQLITE_OK) {
        NSString* query = [NSString stringWithFormat:@"SELECT BOOKMARK_URL FROM BOOKMARKS_TABLE"];
        
        const char* query_stmt = [query UTF8String];
        
        /** To execute an SQL query, it must first be compiled into a byte-code
         ** program using one of these routines.
         ** The first argument, "db", is a [database connection] obtained from a
         ** prior successful call to [sqlite3_open()], [sqlite3_open_v2()] or
         ** [sqlite3_open16()].  The database connection must not have been closed.
         ** The second argument, "zSql", is the statement to be compiled, encoded
         ** as either UTF-8 or UTF-16. If the nByte argument is less than zero, then zSql is read up to the
         ** first zero terminator. If nByte is non-negative, then it is the maximum
         ** number of  bytes read from zSql.
         ** The third argument, *ppStmt, is left pointing to a compiled [prepared statement] that can be
         ** executed using [sqlite3_step()]. If there is an error, *ppStmt is set
         ** to NULL.
         ** The fourth argument, *pzTail, if not NULL then *pzTail is made to point to the first byte
         ** past the end of the first SQL statement in zSql.
         */
        if (sqlite3_prepare_v2(self.feedDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            /** After a [prepared statement] has been prepared using either
             ** [sqlite3_prepare_v2()] or [sqlite3_prepare16_v2()] or one of the legacy
             ** interfaces [sqlite3_prepare()] or [sqlite3_prepare16()], this function
             ** must be called one or more times to evaluate the statement.
             ** SQLITE_ROW indicates sqlite3_step() has another row ready.
             */
            while (sqlite3_step(statement) == SQLITE_ROW) {
                bookmark = [[FeedData alloc]init];
                /**
                 */
                if ((const char*)sqlite3_column_text(statement, 0)!=NULL) {
                    bookmark.feedURL = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                }
                else{
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Bookmark could not be retreived" delegate:Nil cancelButtonTitle:@"Damn!" otherButtonTitles:Nil, nil];
                    [alert show];
                }
                [self.bookmarkValues setObject:bookmark.feedURL forKey:@"xkcd"];
                [self.bookmarkNames addObject:bookmark];
            }
            /** The sqlite3_finalize() function is called to delete a [prepared statement].
             ** If the most recent evaluation of the statement encountered no errors
             ** or if the statement is never been evaluated, then sqlite3_finalize() returns
             ** SQLITE_OK.
             */
            sqlite3_finalize(statement);
        }
        sqlite3_close(self.feedDB);
    }
}


    /** Initializes a table-view controller to manage a table view of a given style.
     ** If you use the standard init method to initialize a UITableViewController object, a table view in the plain style is created
     */
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

    /** Notifies the view controller that its view is about to be added to a view hierarchy.
     ** This method is called before the receiver’s view is about to be added to a view hierarchy and before any animations are configured for showing the view.
     */
-(void)viewWillAppear:(BOOL)animated{
    [self loadBookmarks];
    [self.bookmarksOutlet reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.bookmarksOutlet setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.bookmarkNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return bookmarkHolder.count;
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookmarksCell" forIndexPath:indexPath];
    
    // Configure the cell...
    FeedData* feedCell = [self.bookmarkNames objectAtIndex:indexPath.section];
    cell.textLabel.text = feedCell.feedURL;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedCellText = [[[tableView cellForRowAtIndexPath:indexPath]textLabel]text];
    [self performSegueWithIdentifier:@"showBookmark" sender:Nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
//    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    NSString* cellURL = cell.textLabel.text;
//   [segue destinationViewController]objectForKey:;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
