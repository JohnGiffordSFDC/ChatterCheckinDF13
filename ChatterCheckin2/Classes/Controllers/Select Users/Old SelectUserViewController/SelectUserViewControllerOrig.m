//
//  MentionSelectorViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/9/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "SelectUserViewControllerOrig.h"
#import "User.h"
#import "LoadingViewController.h"

@interface SelectUserViewControllerOrig ()

@end

@implementation SelectUserViewControllerOrig

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
	
	if(!_selectedUsers) _selectedUsers = [[NSMutableArray alloc] init];
	
	_dataRows = [[NSMutableArray alloc] initWithCapacity:0];
	
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
    
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
	
	NSLog(@"Got page of users. %@",jsonResponse);
    
	_nextPageURL = [jsonResponse objectForKey:@"nextPageUrl"];
    
	_dataRows = [self processUsers:jsonResponse];
    
    [self.tableView reloadData];
	
    if ((NSNull *)_nextPageURL != [NSNull null]) {
		NSLog(@"Getting next page...");
        [self getUsers];
    } else {
        [[LoadingViewController sharedController] removeLoadingView];
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

#pragma mark - Parsing

- (NSMutableArray *)processUsers:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"users"];
    
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    for (NSDictionary *user in [records sortedArrayUsingDescriptors:@[sortDescriptor]]) {
        
        User *newUser = [[User alloc] init];
        newUser.fullName = [user objectForKey:@"name"];
        newUser.userId = [user objectForKey:@"id"];
        
        [_dataRows addObject:newUser];
	}
	
	return _dataRows;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dataRows == nil ? 0 : [_dataRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    User * user = [_dataRows objectAtIndex:indexPath.row];
    
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
    User * user = [_dataRows objectAtIndex:indexPath.row];
    
    if ([_selectedUsers containsObject:user.userId]) {
        [_selectedUsers removeObject:user.userId];
    } else {
        [_selectedUsers addObject:user.userId];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Search Query

- (void)performSearchFor:(NSString *)searchString {
	
	SFRestRequest* request = [[SFRestAPI sharedInstance] requestForResources];
    
    NSString *pathString = [NSString stringWithFormat:@"%@/chatter/users?q=%@&pageSize=50",request.path,searchString];
    
    request.path = pathString;
    
	[[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	_nextPageURL = nil;
	[_dataRows removeAllObjects];
	[self.tableView reloadData];
	[self performSearchFor:searchBar.text];
	[searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	_nextPageURL = nil;
	[_dataRows removeAllObjects];
	[self.tableView reloadData];
	[self getUsers];
}


@end