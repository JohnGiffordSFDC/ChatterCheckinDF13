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
#import "PlaceholderRow.h"
#import "LoadingCell.h"

@interface SelectUserViewController ()
{
	BOOL _reloading;
}
@end

@implementation SelectUserViewController

@synthesize selectedUsers = _selectedUsers;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
	
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if (_dataRows == nil) {
		_dataRows = [[NSMutableArray alloc] init];
	}
	
    if (_selectedUsers == nil) {
        _selectedUsers = [[NSMutableArray alloc]initWithCapacity:0];
    }

    [self setTitle:@"Users"];

	[self addLoadingCell];
    [self getUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getUsers
{
	
	_reloading = YES;
	
	SFRestRequest* request = [[SFRestAPI sharedInstance] requestForResources];
    
    NSString *pathString = _nextPageURL != nil ? _nextPageURL : [NSString stringWithFormat:@"%@/chatter/users?pageSize=50", request.path];
    
    request.path = pathString;
    
    NSLog(@"Path: %@",request.path);
    
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - Loading Cell Updates

- (void)addLoadingCell {
	
	[_dataRows addObject:[[PlaceholderRow alloc] init]];
	
	if(_dataRows.count == 1) {
		[self.tableView reloadData];
	} else {
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dataRows.count-1 inSection:0]]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
	BOOL shouldGetNextPage = (maximumOffset - scrollView.contentOffset.y) <= 40.0;
	
	if (shouldGetNextPage && !_reloading) {
		if ((NSNull *)_nextPageURL != [NSNull null]) {
			[self addLoadingCell];
			[self getUsers];
		}
	}
}

// Inserts the new page of data into the table, removing and loading cells in the process
- (void)updateTable:(UITableView *)table withData:(NSMutableArray *)array sinceLastCount:(int)lastCount {
	
	int deleteIndex;
	NSMutableArray * newPaths = [NSMutableArray array];
	NSMutableArray * deletePaths = [NSMutableArray array];
	
	// Find and remove the loading cell, if existing
	for (int x = 0; x < array.count; x++) {
		if ([[array objectAtIndex:x] isKindOfClass:[PlaceholderRow class]]) {
			[deletePaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
			deleteIndex = x;
			break;
		}
	}
	
	if(deletePaths.count) {
		[array removeObjectAtIndex:deleteIndex];
		lastCount -= 1;
	}
	
	// Insert new indexes
	for (int x = lastCount; x < array.count; x++) {
		[newPaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
	}
	
	// Finally perform batch updates
	[table beginUpdates];
	if(deletePaths.count) {
		[table deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationFade];
	}
    [table insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
	[table endUpdates];
}

#pragma mark - Response Parsing

// Saving 'old' way for demo... TODO: reorganize this

//- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
//    _nextPageURL = [jsonResponse objectForKey:@"nextPageUrl"];
//
//    NSArray *records = [jsonResponse objectForKey:@"following"];
//    if(records.count != 0){
//        [self processFollowers:jsonResponse];
//    } else {
//        [self processUsers:jsonResponse];
//    }
//
//    NSSortDescriptor *sortDescriptor;
//    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
//    NSArray *sortedUsers = [_dataRows sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//
//    _dataRows = [[NSMutableArray alloc] initWithArray:sortedUsers];
//
//    [self.tableView reloadData];
//
//    if ((NSNull *)_nextPageURL != [NSNull null]) {
//        [self getUsers];
//    } else {
//        [[LoadingViewController sharedController]removeLoadingView];
//    }
//}

- (NSArray *)processUsers:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"users"];
    
    
	NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
	
    for (NSDictionary *user in [records sortedArrayUsingDescriptors:@[sortDescriptor]]) {
        //NSLog(@"user: %@",user);
        
        User *newUser = [[User alloc] init];
        newUser.fullName = [user objectForKey:@"name"];
        newUser.userId = [user objectForKey:@"id"];
        
        [_dataRows addObject:newUser];
	}
	
	return [NSArray arrayWithArray:_dataRows];
}


#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    _nextPageURL = [jsonResponse objectForKey:@"nextPageUrl"];
    
	int lastCount = _dataRows.count;
	
	// Process the new data
	_dataRows = [self processUsers:jsonResponse].mutableCopy;
	
	// Update the table
	[self updateTable:self.tableView
			 withData:_dataRows
	  sinceLastCount:lastCount];
	
    _reloading = NO;
}

//TODO: error handling
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
	
	id object = [_dataRows objectAtIndex:indexPath.row];
	UITableViewCell * cell = nil;
	if ([object isKindOfClass:[PlaceholderRow class]]) {
		static NSString *LoadingCellIdentifier = @"LoadingCell";
		cell = (LoadingCell*)[tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
		if (cell == nil) {
			cell = (LoadingCell*)[[LoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadingCellIdentifier];
		}
	} else {
		static NSString *CellIdentifier = @"Cell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
	}
    
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
