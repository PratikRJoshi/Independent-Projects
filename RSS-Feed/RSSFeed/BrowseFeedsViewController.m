//
//  BrowseFeedsViewController.m
//  RSSFeed
//
//  Created by Pratik Joshi on 6/3/14.
//  Copyright (c) 2014 Pratik Joshi. All rights reserved.
//

#import "BrowseFeedsViewController.h"
#import "FeedrMasterViewController.h"

@interface BrowseFeedsViewController ()
@end



@implementation BrowseFeedsViewController

static NSURL* url;

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
    NSLog(@"In BrowseFeedsViewController");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*- (IBAction)getAppleFeed:(id)sender {
    url = [NSURL URLWithString:@"htt\p://images.apple.com/main/rss/hotnews/hotnews.rss"];
}*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSLog(@"prepare for segue %@", segue.identifier);
    FeedrMasterViewController* transferView = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"techCrunchSegue"]) {
        transferView.url = [NSURL URLWithString:@"http://techcrunch.com/feed/"];
    }
    if ([segue.identifier isEqualToString:@"appleSegue"]) {
        transferView.url = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
    }
    
}

/*- (IBAction)returnFeed:(id)sender {
}*/

/*+(NSURL*)returnFeed{
    
    return url;
}*/

/*- (IBAction)getFeed:(id)sender {
    url = [BrowseFeedsViewController returnFeed];
}*/
@end
