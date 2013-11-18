//
//  AccountViewController.m
//  ChatterCheckin2
//
//  Created by John Gifford on 11/4/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#import "AccountViewController.h"
#import "LoadingViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAccounts:)];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshAccounts:)];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(refreshAccountsWithStatus:)];
    longPress.delegate      =   self;
    longPress.minimumPressDuration = 0.7;
    
    UILabel *refresh = [[UILabel alloc]initWithFrame:CGRectMake(0,0,60,30)];
    [refresh setText:@"Refresh"];
    [refresh setTextColor:[UIColor colorWithRed:166.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [refresh setTextAlignment:NSTextAlignmentRight];
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0,0,60,30)];
    [buttonView addSubview:refresh];
    
    [buttonView addGestureRecognizer:tap];
    [buttonView addGestureRecognizer:longPress];
    [self.navigationItem.rightBarButtonItem setCustomView:buttonView];
    
    longPress = nil;
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:166.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    _accounts = [[NSMutableArray alloc]initWithCapacity:0];
    [_accounts addObject:@"Adam Warlock"];
    [_accounts addObject:@"Adri Nital"];
    [_accounts addObject:@"Arthur Maddicks"];
    [_accounts addObject:@"Barnell Bohusk"];
    [_accounts addObject:@"Benjamin Parker"];
    [_accounts addObject:@"Brian Braddock"];
    [_accounts addObject:@"Bruce Banner"];
    [_accounts addObject:@"Carol Danvers"];
}


- (void)refreshAccounts:(id)sender
{
    _showProgress = NO;
    [self loadUsers];
}

-(void)refreshAccountsWithStatus:(id)sender
{
    _showProgress = YES;
    [self loadUsers];
}

- (void)loadUsers {
    if (_counter <= 198) {
        [[LoadingViewController sharedController]completeSegment:0];
        [[LoadingViewController sharedController]addLoadingView:self.navigationController.view withLabel:@"Loading..."];
        if (_showProgress) {
            [[LoadingViewController sharedController]updateProgress:[NSString stringWithFormat:@"Users %i of 198", _counter]];
            [[LoadingViewController sharedController]showTotalProgress];
        } else {
            [[LoadingViewController sharedController]updateProgress:@"Fetching Data..."];
        }
        _userTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueLoading:) userInfo:nil repeats:NO];
        
    } else {
        _userTimer = nil;
        _counter = 1;
        [self loadAccounts];
    }
}

- (void)loadAccounts {
    if (_counter <= 218) {
        if (_showProgress) {
            [[LoadingViewController sharedController]updateProgress:[NSString stringWithFormat:@"Account %i of 218", _counter]];
            [[LoadingViewController sharedController]showTotalProgress];
            [[LoadingViewController sharedController]completeSegment:1];
        } else {
            [[LoadingViewController sharedController]updateProgress:@"Fetching Data..."];
        }
        
        _accountTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueLoading:) userInfo:nil repeats:NO];
        
    } else {
        _accountTimer = nil;
        _counter = 1;
        [self loadContacts];
    }
}

- (void)loadContacts {
    if (_counter <= 252) {
        if (_showProgress) {
            [[LoadingViewController sharedController]updateProgress:[NSString stringWithFormat:@"Contact %i of 252", _counter]];
            [[LoadingViewController sharedController]showTotalProgress];
            [[LoadingViewController sharedController]completeSegment:2];
            
        } else {
            [[LoadingViewController sharedController]updateProgress:@"Fetching Data..."];
        }
        _contactTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueLoading:) userInfo:nil repeats:NO];
        
    } else {
        _contactTimer = nil;
        _counter = 1;
        [self loadLeads];
    }
}

- (void)loadLeads {
    if (_counter <= 143) {
        if (_showProgress) {
            [[LoadingViewController sharedController]updateProgress:[NSString stringWithFormat:@"Lead %i of 143", _counter]];
            [[LoadingViewController sharedController]showTotalProgress];
            [[LoadingViewController sharedController]completeSegment:3];
        } else {
            [[LoadingViewController sharedController]updateProgress:@"Fetching Data..."];
        }
        _leadTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueLoading:) userInfo:nil repeats:NO];
        
    } else {
        _leadTimer = nil;
        _counter = 1;
        [self loadOpportunities];
    }
}

- (void)loadOpportunities {
    if (_counter <= 163) {
        if (_showProgress) {
            [[LoadingViewController sharedController]updateProgress:[NSString stringWithFormat:@"Opportunity %i of 163", _counter]];
            [[LoadingViewController sharedController]showTotalProgress];
            [[LoadingViewController sharedController]completeSegment:4];
            
        } else {
            [[LoadingViewController sharedController]updateProgress:@"Fetching Data..."];
        }
        _opportunityTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueLoading:) userInfo:nil repeats:NO];
        
    } else {
        _opportunityTimer = nil;
        _counter = 1;
        [self loadActivities];
    }
}

- (void)loadActivities {
    if (_counter <= 182) {
        if (_showProgress) {
            [[LoadingViewController sharedController]updateProgress:[NSString stringWithFormat:@"Activity %i of 182", _counter]];
            [[LoadingViewController sharedController]showTotalProgress];
            [[LoadingViewController sharedController]completeSegment:5];
        } else {
            [[LoadingViewController sharedController]updateProgress:@"Fetching Data..."];
        }
        _activityTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueLoading:) userInfo:nil repeats:NO];
        
    } else {
        _activityTimer = nil;
        _counter = 1;
        [self loadTasks];
    }
}

- (void)loadTasks {
    if (_counter <= 102) {
        if (_showProgress) {
            [[LoadingViewController sharedController]updateProgress:[NSString stringWithFormat:@"Task %i of 102", _counter]];
            [[LoadingViewController sharedController]showTotalProgress];
            [[LoadingViewController sharedController]completeSegment:6];
        } else {
            [[LoadingViewController sharedController]updateProgress:@"Fetching Data..."];
        }
        _tasksTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueLoading:) userInfo:nil repeats:NO];
        
    } else {
        _tasksTimer = nil;
        _counter = 1;
        [self loadEvents];
    }
}

- (void)loadEvents {
    if (_counter <= 96) {
        if (_showProgress) {
            [[LoadingViewController sharedController]updateProgress:[NSString stringWithFormat:@"Event %i of 96", _counter]];
            [[LoadingViewController sharedController]showTotalProgress];
            [[LoadingViewController sharedController]completeSegment:7];
        } else {
            [[LoadingViewController sharedController]updateProgress:@"Fetching Data..."];
        }
        _eventTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueLoading:) userInfo:nil repeats:NO];
        
    } else {
        _counter = 1;
        
        [[LoadingViewController sharedController]completeSegment:8];
        [[LoadingViewController sharedController]removeLoadingView];
    }
}

- (void)continueLoading:(NSTimer *)timer{
    _counter++;
    if (timer == _accountTimer) {
        [self loadAccounts];
    } else if (timer == _contactTimer) {
        [self loadContacts];
    } else if (timer == _leadTimer){
        [self loadLeads];
    } else if (timer == _opportunityTimer){
        [self loadOpportunities];
    } else if (timer == _userTimer){
        [self loadUsers];
    } else if (timer == _activityTimer){
        [self loadActivities];
    } else if (timer == _tasksTimer){
        [self loadTasks];
    } else if (timer == _eventTimer){
        [self loadEvents];
    }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setText:[_accounts objectAtIndex:indexPath.row]];
    
    return cell;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
