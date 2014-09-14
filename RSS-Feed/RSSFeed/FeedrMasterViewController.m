//
//  FeedrMasterViewController.m
//  RSSFeed
//
//  Created by Pratik Joshi on 5/27/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import "FeedrMasterViewController.h"
#import "FeedrDetailViewController.h"
#import "BrowseFeedsViewController.h"


@interface FeedrMasterViewController () {
    NSMutableArray* feeds;          //a mutable array that will contain the list of feeds downloaded
    NSXMLParser* parser;            //the object that will download and parse the RSS XML files
    NSMutableDictionary* items;     //item is a mutable dictionary that will contains the details of a feed, in our
                                    //case its title and its link
    NSMutableString* title;
    NSMutableString* link;
    NSString* element;              // to control with element is currently parsing the NSXMLParser object
    //NSMutableArray* feedButtonClicked;
    //NSURL *url;
}
@end

@implementation FeedrMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Inside FeedrMaster view controller before parsing");
    
    //feedButtonClicked = [NSMutableArray arrayWithObjects:@"http:\//techcrunch.com/feed/", @"http:\//images.apple.com/main/rss/hotnews/hotnews.rss", nil];
    feeds = [[NSMutableArray alloc]init];
    //url = [NSURL URLWithString:@"http:\//techcrunch.com/feed/"];
    //parser = [[NSXMLParser alloc]initWithContentsOfURL:[BrowseFeedsViewController returnFeed]];
    parser = [[NSXMLParser alloc]initWithContentsOfURL:self.url];
    
    /** Sets the receiver’s delegate.
     ** An object that is the new delegate. It is not retained. 
     ** The delegate must conform to the NSXMLParserDelegate Protocol protocol.
     */
    [parser setDelegate:self];
    
    /** Specifies whether the receiver reports declarations of external entities using the delegate method 
     ** parser:foundExternalEntityDeclarationWithName:publicID:systemID:.
     ** If you pass in YES, you may cause other I/O operations, either network-based or disk-based, to load the external DTD. */
    [parser setShouldResolveExternalEntities:NO];
    
    /* Starts the event-driven parsing operation. */
    [parser parse];
    
    
    
    
    /*self.navigationItem.leftBarButtonItem = self.editButtonItem;
     
     UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
     self.navigationItem.rightBarButtonItem = addButton;*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)insertNewObject:(id)sender
 {
 if (!_objects) {
 _objects = [[NSMutableArray alloc] init];
 }
 [_objects insertObject:[NSDate date] atIndex:0];
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
 [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
 }*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    
    //NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [[feeds objectAtIndex:indexPath.row]objectForKey:@"title"];
    return cell;
}

/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }*/

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 [_objects removeObjectAtIndex:indexPath.row];
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }
 }*/

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


/** Sent by a parser object to provide its delegate with a string 
 ** representing all or part of the characters of the current element.
 */
-(void)parser: (NSXMLParser*)parser foundCharacters:(NSString *)characters{
    
    if ([element isEqualToString:@"title"]){
        [title appendString:characters];
    }
    else if([element isEqualToString:@"link"]){
        [link appendString:characters];
    }
}

/** Sent by a parser object to its delegate when it encounters a start tag for a given element.
 */
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    element = elementName;
    if ([element isEqualToString:@"item"]) {
        items = [[NSMutableDictionary alloc]init];
        title = [[NSMutableString alloc]init];
        link = [[NSMutableString alloc]init];
    }
}

/** Sent by a parser object to its delegate when it encounters an end tag for a specific element
 */
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"item"]) {
        [items setObject:title forKey:@"title"];
        [items setObject:link forKey:@"link"];
        
        [feeds addObject:[items copy]];
    }
}

/* Sent by the parser object to the delegate when it has successfully completed parsing */
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //NSLog(@"Inside FeedrMaster segue");
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSURL *string = [feeds[indexPath.row]objectForKey:@"link"];
        NSLog(@"Segues URL from feedMaster - %@", string);
        [[segue destinationViewController] setUrl:string];
        
        NSString* feedTitle = [feeds[indexPath.row]objectForKey:@"title"];
        NSLog(@"Segues Title from feedMaster - %@", feedTitle);
        [[segue destinationViewController] setTitle:feedTitle];
    }
}

@end
