//
//  CheckinViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/5/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "CheckinViewController.h"
#import <CoreLocation/CoreLocation.h>

// Good
#import "SelectUserViewController.h"

// Bad
#import "SelectUserViewControllerOrig.h"

#import "LoadingViewController.h"

@interface CheckinViewController ()

@end

@implementation CheckinViewController

@synthesize placemarks = _placemarks;

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
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"_placemarks count: %i",[_placemarks count]);
    if ([_placemarks count] > 0) {
        CLPlacemark *placemark = (CLPlacemark *)[_placemarks objectAtIndex:0];
        NSString *cityString = [placemark.addressDictionary objectForKey:@"City"];
        NSString *stateString = [placemark.addressDictionary objectForKey:@"State"];
        [_location setText:[NSString stringWithFormat:@"%@, %@", cityString, stateString]];
    } else {
        [_location setText:@"Location Not Found"];
    }
    
    [self setTitle:@"Checkin"];
    
    [self setupNavbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([_selectedUsers count] > 0) {
        [_selectButton setTitle:[NSString stringWithFormat:@"Select Coworkers (%i)",[_selectedUsers count]] forState:UIControlStateNormal];
    } else {
        [_selectButton setTitle:@"Select Coworkers" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

}

- (void)viewDidUnload {
    [self setLocation:nil];
    [self setStatus:nil];
    [self setSelectButton:nil];
    [super viewDidUnload];
}

#pragma mark - Instance Methods

- (IBAction)selectPeople:(id)sender {

	// Unoptimized user selection
	SelectUserViewControllerOrig * msvc = [[SelectUserViewControllerOrig alloc] init];
	
	// Optimized user selection
//    SelectUserViewController *msvc = [[SelectUserViewController alloc] init];
	
	
	if (_selectedUsers == nil) {
        _selectedUsers = [[NSMutableArray alloc] init];
    }
	[_selectedUsers removeAllObjects];
    msvc.selectedUsers = _selectedUsers;
	
	
    [self.navigationController pushViewController:msvc animated:YES];
}

- (void)setupNavbar
{
    UIBarButtonItem *postBtn = [[UIBarButtonItem alloc]initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(post:)];
    [self.navigationItem setRightBarButtonItem:postBtn];
}

- (void)post:(id)sender
{
    NSString *test = [_status.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![test isEqualToString:@"Entertext..."] && ![test isEqualToString:@""]) {
        [_location resignFirstResponder];
        [_status resignFirstResponder];
        
        [[LoadingViewController sharedController]addLoadingView:self.navigationController.view withLabel:@"Posting..."];
        
        NSLog(@"_selectedUsers: %@",_selectedUsers);
        
        NSString *postString;
        
        if (![[_location.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            postString = [NSString stringWithFormat:@"Checked in near %@ - %@",_location.text,_status.text];
        } else {
            postString = [NSString stringWithFormat:@"Checked in - %@",_status.text];
        }
        
        if ([_selectedUsers count] > 0) {
            postString = [postString stringByAppendingFormat:@" with: "];
        }
        
        NSLog(@"%@",postString);
        
        SFRestRequest* request = [[SFRestAPI sharedInstance] requestForResources];
        
        NSString *postUrl = [NSString stringWithFormat:@"%@/chatter/feeds/news/me/feed-items",request.path];
        
        NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:@"Text", @"type", postString, @"text", nil];
        NSMutableArray *segments = [NSMutableArray arrayWithObject:values];
        
        for (NSString *s in _selectedUsers) {
            [segments addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mention", @"type", s, @"id", nil]];
        }
        
        NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:segments, @"messageSegments", nil];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:message, @"body", nil];
        
        SFRestRequest *post = [SFRestRequest requestWithMethod:SFRestMethodPOST path:postUrl queryParams:params];
        
        NSLog(@"post.path: %@",post.queryParams);
        
        [[SFRestAPI sharedInstance] send:post delegate:self];

    } else {
        [self displayError];
    }
}

- (void)displayError {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error!"
                          message: @"Please enter a status"
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert setTag:111];
    [alert show];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"items"];
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    NSLog(@"%@",records);
    
    [[LoadingViewController sharedController]removeLoadingView];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Success"
                          message: @"Status posted successfully!"
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert setTag:123];
    [alert show];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 111) {
        [_status becomeFirstResponder];
    } else {
        [_status setText:@"Enter text..."];
        [_status setTextColor:[UIColor grayColor]];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [_status resignFirstResponder];
        return NO;
    }
    
    return YES;
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if ([_status.text isEqualToString:@"Enter text..."]) {
        [_status setText:@""];
        [_status setTextColor:[UIColor blackColor]];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([_status.text isEqualToString:@""]) {
        [_status setText:@"Enter text..."];
        [_status setTextColor:[UIColor grayColor]];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
