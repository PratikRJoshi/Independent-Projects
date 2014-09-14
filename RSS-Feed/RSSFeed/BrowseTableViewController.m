//
//  BrowseTableViewController.m
//  RSSFeed
//
//  Created by Shrikanth Narayanan on 6/7/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import "BrowseTableViewController.h"
#import "FeedData.h"
#import "EnterFeedViewController.h"
#import "FeedrMasterViewController.h"

@interface BrowseTableViewController ()
@end

@implementation BrowseTableViewController{
    FeedData* tempFeed ;
}

-(void)loadFeedNames{
    
    NSString* docsDir;
    NSArray* dirPath;
    
    
    
    //set the feedNames array
    _feedNames = [[NSMutableArray alloc]init];
    _feed_names = [[NSMutableDictionary alloc]init];
    
    //get the directory of the documents
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPath[0];
    
    //build the path to the database file
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"feedDB.db"]];
    
    //retreive values from the database
    const char* dbPath = [self.databasePath UTF8String];
    
    sqlite3_stmt* statement;
    
    if (sqlite3_open(dbPath, &_feedDB) == SQLITE_OK) {
        NSString* query = [NSString stringWithFormat:@"SELECT FEED_NAME, FEED_URL FROM FEED_TABLE"];
//        NSLog(@"Query String generated is - %@", query);
        
        const char* query_stmt = [query UTF8String];
        
        if (sqlite3_prepare_v2(self.feedDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                tempFeed = [[FeedData alloc]init];
                if ((const char*)sqlite3_column_text(statement, 0)!=NULL) {
                    tempFeed.feedTitle = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                }
                if ((const char*)sqlite3_column_text(statement, 1)!=NULL) {
                    tempFeed.feedURL = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement, 1)];
                }
                [self.feed_names setObject:tempFeed.feedURL forKey:tempFeed.feedTitle];
                [self.feedNames addObject:tempFeed];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(self.feedDB);
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadFeedNames];
    [self.browseView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.browseView setDelegate:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//set the number of
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //return 1;
    return [self.feedNames count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return [self.feedNames count];
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    FeedData* feedCell = [self.feedNames objectAtIndex:indexPath.section];
    cell.textLabel.text = feedCell.feedTitle;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedCellText = [[[tableView cellForRowAtIndexPath:indexPath]textLabel]text];
//    if (self.navigationController.visibleViewController == self) {
//        [self performSegueWithIdentifier:@"showSelectedFeed" sender:self];
//    }
    [self performSegueWithIdentifier:@"showSelectedFeed" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //[self performSegueWithIdentifier:@"showSelectedFeed" sender:sender];
    //NSLog(@"Inside the browse segue");
    // Get the new view controller using [segue destinationViewController].
    FeedrMasterViewController* fmvc = [segue destinationViewController];
    
    // Pass the selected object to the new view controller.
    //fmvc.url = [NSURL URLWithString:tempFeed.feedURL];
    NSString* tempURL = [NSString stringWithFormat:@"%@",[_feed_names objectForKey:self.selectedCellText]];
    fmvc.url = [NSURL URLWithString:tempURL];
    
}


@end
