//
//  MentionSelectorViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/9/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "SelectUserViewController.h"
#import "User.h"
#import "LoadingViewController.h"

@interface SelectUserViewController ()

@end

@implementation SelectUserViewController

@synthesize selectedUsers = _selectedUsers;

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
    
    if (_selectedUsers == nil) {
        _selectedUsers = [[NSMutableArray alloc]initWithCapacity:0];
    }

    [self setTitle:@"Users"];
    [[LoadingViewController sharedController]addLoadingView:self.navigationController.view];
    [self getUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getUsers
{
	SFRestRequest* request = [[SFRestAPI sharedInstance] requestForResources];
    
    NSString *pathString = _nextPageURL != nil ? _nextPageURL : [NSString stringWithFormat:@"%@/chatter/users?pageSize=20", request.path];
    
    request.path = pathString;
    
    NSLog(@"Path: %@",request.path);
    
    [[SFRestAPI sharedInstance] send:request delegate:self];
}


#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    _nextPageURL = [jsonResponse objectForKey:@"nextPageUrl"];
    
    NSArray *records = [jsonResponse objectForKey:@"following"];
    if(records.count != 0){
        [self processFollowers:jsonResponse];
    } else {
        [self processUsers:jsonResponse];
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    NSArray *sortedUsers = [_dataRows sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    _dataRows = [[NSMutableArray alloc] initWithArray:sortedUsers];
    
    [self.tableView reloadData];
    
    if ((NSNull *)_nextPageURL != [NSNull null]) {
        [self getUsers];
    } else {
        [[LoadingViewController sharedController]removeLoadingView];
    }
}

- (void)processUsers:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"users"];
    
    if (_dataRows == nil) {
        _dataRows = [[NSMutableArray alloc]initWithCapacity:0];
    }
    
    for (NSDictionary *user in records) {
        NSLog(@"user: %@",user);
        
        User *newUser = [[User alloc] init];
        newUser.fullName = [user objectForKey:@"name"];
        newUser.userId = [user objectForKey:@"id"];
        
        [_dataRows addObject:newUser];
	}
}

- (void)processFollowers:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"following"];
    
    if (_dataRows == nil) {
        _dataRows = [[NSMutableArray alloc]initWithCapacity:0];
    }
    
    for (NSDictionary *following in records) {
        NSDictionary *user = [following objectForKey:@"subject"];
        NSLog(@"user: %@",user);
        
        User *newUser = [[User alloc] init];
        newUser.fullName = [user objectForKey:@"name"];
        newUser.userId = [user objectForKey:@"id"];
        
        [_dataRows addObject:newUser];
	}
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}

- (NSDictionary *)getUserForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *following = [_dataRows objectAtIndex:indexPath.row];
    NSLog(@"following: %@",following);
    
    NSDictionary *user = [following objectForKey:@"subject"];
    NSLog(@"user: %@",user);
    
    return user;
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _filteredUsers == nil ? 0 : [_filteredUsers count];
    } else {
        return _dataRows == nil ? 0 : [_dataRows count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    User *user;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user = [_filteredUsers objectAtIndex:indexPath.row];
    } else {
        user = [_dataRows objectAtIndex:indexPath.row];
    }
    
    if ([_selectedUsers containsObject:user.userId]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    cell.textLabel.text = user.fullName;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    User *user;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user = [_filteredUsers objectAtIndex:indexPath.row];
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        user = [_dataRows objectAtIndex:indexPath.row];
    }
    
    if ([_selectedUsers containsObject:user.userId]) {
        [_selectedUsers removeObject:user.userId];
    } else {
        [_selectedUsers addObject:user.userId];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    [self filterContentForSearchText:searchString scope:[[searchBar scopeButtonTitles] objectAtIndex:[searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	// Update the filtered array based on the search text and scope.
	
    // Remove all objects from the filtered search array
	[_filteredUsers removeAllObjects];
    
	// Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullName contains[c] %@",searchText];
    
    _filteredUsers = [[NSMutableArray alloc]initWithArray:[_dataRows filteredArrayUsingPredicate:predicate]];
}


@end
