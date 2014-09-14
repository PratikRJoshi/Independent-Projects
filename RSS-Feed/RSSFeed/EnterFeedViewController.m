//
//  EnterFeedViewController.m
//  RSSFeed
//
//  Created by Pratik Joshi on 6/3/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import "EnterFeedViewController.h"

@interface EnterFeedViewController ()
@property (weak, nonatomic) IBOutlet UITextField *feedName;
@property (weak, nonatomic) IBOutlet UITextField *feedURL;
@property (weak, nonatomic) IBOutlet UILabel *labelDisplay;


@end

@implementation EnterFeedViewController

- (IBAction)findFeed:(id)sender {
    //do something when the button is clicked
    NSString* feedNameValue = [[self feedName] text];
    NSString* feedURLValue = [[self feedURL] text];
    NSString* labelValue = [NSString stringWithFormat:@"Find %@ feed at %@?", feedNameValue, feedURLValue];
    
    
    [[self labelDisplay] setText:labelValue];
    
    //after hitting the button, make the keyboard go away
    [[self feedName] resignFirstResponder];
    [[self feedURL] resignFirstResponder];
    
}

//make the keyboard disappear on touching anywhere in the blank space on screen
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self view] endEditing:YES];
}

//after entering the text in the text field, when return is touched, make the keyboard disappear
-(BOOL)textFieldShouldReturn:(UITextField*)feedName{
    [self.feedName resignFirstResponder];
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString* docsDir;
    NSArray* dirPath;
    
    //get the directory of the documents
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPath[0];
    
    //build the path to the database file
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"feedDB.db"]];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    /** Returns a Boolean value that indicates whether a file or directory exists at a specified path.
     */
    if ([fileManager fileExistsAtPath:_databasePath] == YES) {
        const char* dbPath = [_databasePath UTF8String];
        int output = sqlite3_open(dbPath, &_feedDB);
        
        if (output == SQLITE_OK) {
            char* errorMsg;
            const char* sqlStatement = "CREATE TABLE IF NOT EXISTS FEED_TABLE(FEED_ID INTEGER PRIMARY KEY AUTOINCREMENT, FEED_NAME TEXT, FEED_URL TEXT)";
            int output = sqlite3_exec(_feedDB, sqlStatement, NULL, NULL, &errorMsg);
            
            if (output == SQLITE_OK) {
                [[self labelDisplay] setText:[NSString stringWithFormat:@"Table successfully created!"]];
            }
            else{
                [[self labelDisplay] setText:[NSString stringWithFormat:@"Some problem with table creation"]];
            }
            sqlite3_close(_feedDB);
        }
    }
    else {
        NSError* error;
        
        /** Returns the NSBundle object that corresponds to the directory where the current application executable is located.
         ** This method allocates and initializes a bundle object if one doesn’t already exist. 
         ** The new object corresponds to the directory where the application executable is located. 
         ** Be sure to check the return value to make sure you have a valid bundle. 
         ** This method may return a valid bundle object even for unbundled applications.
         */
        NSString* databasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"feedDB.db"];
        
        /*Copies the item at the specified path to a new location synchronously*/
        BOOL successfulWrite = [fileManager copyItemAtPath:databasePath toPath:_databasePath error:&error];
        
        if (!successfulWrite) {
            NSAssert1(0, @"Failed to create a writable database file with message '%@'", [error localizedDescription]);
            [[self labelDisplay] setText:[NSString stringWithFormat:@"The database file does not exist at the path"]];
        }
        else{
            [[self labelDisplay] setText:[NSString stringWithFormat:@"Table successfully created!"]];
        }
        
    }
}



//method to save data to the database
- (IBAction)saveData:(id)sender {
    
    sqlite3_stmt* statement;
    
    const char *dbPath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &_feedDB) == SQLITE_OK) {
        NSString* insertSQL = [NSString stringWithFormat:@"INSERT INTO FEED_TABLE(FEED_NAME, FEED_URL) VALUES( \"%@\", \"%@\")", _feedName.text, _feedURL.text];
        
        const char* insertStmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(_feedDB, insertStmt, -1, &statement, NULL);
        int output = sqlite3_step(statement);
        
        if (output == SQLITE_DONE) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Sucess" message:@"Your feed has been saved" delegate:Nil cancelButtonTitle:@"Cool!" otherButtonTitles:nil];
            [alert show];
        }
        else{
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Sucess" message:@"Failed to add the entered feed" delegate:Nil cancelButtonTitle:@"Darn!" otherButtonTitles:nil];
            [alert show];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(_feedDB);
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
