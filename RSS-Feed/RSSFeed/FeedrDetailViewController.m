//
//  FeedrDetailViewController.m
//  RSSFeed
//
//  Created by Pratik Joshi on 5/27/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import "FeedrDetailViewController.h"
#import "EnterFeedViewController.h"

@interface FeedrDetailViewController (){
    EvernoteNoteStore* noteStore ;
    
}
 
 @end

@implementation FeedrDetailViewController

#pragma mark - Managing the detail item

/*- (void)setDetailItem:(id)newDetailItem
 {
 if (_detailItem != newDetailItem) {
 _detailItem = newDetailItem;
 
 // Update the view.
 [self configureView];
 }
 }*/

/*- (void)configureView
 {
 // Update the user interface for the detail item.
 
 //if (self.detailItem) {
 //  self.detailDescriptionLabel.text = [self.detailItem description];
 //}
 }*/



- (IBAction)saveToEvernote:(id)sender {
    
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            // authentication failed :(
            // show an alert, etc
            // ...
        } else {
            // authentication succeeded :)
            // do something now that we're authenticated
            // ...
            UIAlertView* evernoteAlert = [[UIAlertView alloc]initWithTitle:@"EvernoteLogin" message:@"You have succesfully logged in to Evernote" delegate:nil cancelButtonTitle:@"Cool!" otherButtonTitles:nil, nil];
            [evernoteAlert show];
        }
    }];
    
    noteStore = [EvernoteNoteStore noteStore];
    
    
}

- (void) makeNoteWithTitle:(NSString*)noteTile withBody:(NSString*) noteBody withParentNotebook:(EDAMNotebook*)parentNotebook {
    NSString *noteContent = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                             "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
                             "<en-note>"
                             "%@"
                             "</en-note>",noteBody];
    
    // Parent notebook is optional; if omitted, default notebook is used
    NSString* parentNotebookGUID;
    if(parentNotebook) {
        parentNotebookGUID = parentNotebook.guid;
    }
    
    // Create note object
    EDAMNote *ourNote = [[EDAMNote alloc] initWithGuid:nil title:noteTile content:noteContent contentHash:nil contentLength:noteContent.length created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:parentNotebookGUID tagGuids:nil resources:nil attributes:nil tagNames:nil];
    
    // Attempt to create note in Evernote account
    [[EvernoteNoteStore noteStore] createNote:ourNote success:^(EDAMNote *note) {
        // Log the created note object
        NSLog(@"Note created : %@",note);
    } failure:^(NSError *error) {
        // Something was wrong with the note data
        // See EDAMErrorCode enumeration for error code explanation
        // http:\//dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
        NSLog(@"Error : %@",error);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	/** Returns a representation of the receiver using a given encoding to determine 
     ** the percent escapes necessary to convert the receiver into a legal URL string.
     */
    NSURL* myURL =  [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:myURL];
    
    /** Sets the specified HTTP header field.
     ** The NSURLConnection and NSURLSession classes are designed to handle various aspects of the HTTP protocol for you.
     */
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    
    self.request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    assert(self.request!=nil);
    self.connection = nil;
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    assert(self.connection!=nil);
    
    [self.webView loadRequest:request];
    
    //opn the database after the page loads so as to save the bookmark if needed
    NSString* docsDir;
    NSArray* dirPath;
    
    //get the directory of the documents
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPath objectAtIndex:0];
    
    //build the path ot the database file
    _dbPath = [[NSString alloc]initWithString:[docsDir stringByAppendingString:@"/feedDB.db"]];
    //_dbPath = [[NSBundle mainBundle]pathForResource:@"feedDB.db" ofType:@"sqlite"];
    NSLog(@"%@", _dbPath);
    
    //NSFileManager* fileManager = [NSFileManager defaultManager];
    
    
    
    
}

//method to save to the database
-(IBAction)saveBookmark:(id)sender{
    sqlite3_stmt* statement;
    
    const char* databasePath = [_dbPath UTF8String];
    NSLog(@"%s", databasePath);
    
//    NSDate* currentDate = [NSDate date];
//    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];
//    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY h:mm a, zzz"];
//    NSString* currentDateString = [dateFormat stringFromDate:currentDate];

    int output = sqlite3_open_v2(databasePath, &_feedDB, SQLITE_OPEN_READWRITE, Nil);
    NSLog(@"%s", sqlite3_errmsg(_feedDB));
    if (output == SQLITE_OK) {
        
        NSString* createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS BOOKMARKS_TABLE(BOOKMARK_ID INTEGER PRIMARY KEY AUTOINCREMENT, BOOKMARK_NAME TEXT, BOOKMARK_URL TEXT)"];
        char* error;
        const char* createStmt = [createTableSQL UTF8String];
        int outputCreate = sqlite3_exec(_feedDB, createStmt, NULL, NULL, &error);
        NSLog(@"%s", sqlite3_errmsg(_feedDB));
        if (outputCreate == SQLITE_OK) {
            NSLog(@"The feed title is - %@", self.feedTitle);
            NSString* insertSQL = [NSString stringWithFormat:@"INSERT INTO BOOKMARKS_TABLE(BOOKMARK_NAME, BOOKMARK_URL) VALUES(\"%@\", \"%@\")", self.feedTitle, self.url];
            
            const char* insertStmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(_feedDB, insertStmt, -1, &statement, NULL);
            int output = sqlite3_step(statement);
            NSLog(@"%s", sqlite3_errmsg(_feedDB));
            
            if(output== SQLITE_DONE){
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Sucess" message:@"Your bookmark has been saved" delegate:Nil cancelButtonTitle:@"Cool!" otherButtonTitles:nil];
                [alert show];
            }
            else{
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Failure" message:@"Your bookmark could not be saved :(" delegate:nil cancelButtonTitle:@"Darn!" otherButtonTitles:nil , nil];
                [alert show];
            }
            sqlite3_finalize(statement);
            sqlite3_close([self feedDB]);
            
        }
        else{
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Table creation error" message:@"There were some problems with the table creation" delegate:NULL cancelButtonTitle:@"Ok, I'll check" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
}


/** Sent when the connection determines that it must change URLs in order to continue loading a request.
 */
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    
    NSURLRequest* redirectedRequest = request;
    if (response) {
        response = nil;
    }
    NSLog(@"Redirected Response is - %@", response);
    return redirectedRequest;
}

/** Sent when a connection fails to load its request successfully.
 ** Once the delegate receives this message, it will receive no further messages for connection.
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@", error);
}

/** Sent when the connection has received sufficient data 
 ** to construct the URL response for its request.
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSLog(@"Response received is - %@", response);
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary* responseDictionary = [httpResponse allHeaderFields];
    
    NSString* newUrlLocation = [responseDictionary objectForKey:@"Location"];
    NSLog(@"Response Dictionary - %@", newUrlLocation);
    
    [[NSUserDefaults standardUserDefaults]setObject:newUrlLocation forKey:@"serverurl"];
    NSLog(@"New URL Location: %@", [[NSUserDefaults standardUserDefaults]objectForKey:@"serverurl"]);
}

//-(void)webViewDidStartLoad:(UIWebView *)webView{
//
//    NSURL* newUrl = [webView.request mainDocumentURL];
//    NSLog(@"The Redirected URL is - %@", newUrl);
//    
//}


- (void)didReceiveMemoryWarning
 {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 }



@end
