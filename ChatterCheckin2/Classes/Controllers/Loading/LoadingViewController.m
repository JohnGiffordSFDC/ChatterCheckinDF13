//
//  LoadingViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/31/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "LoadingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoadingViewController ()

@end

@implementation LoadingViewController

static LoadingViewController * _sharedLoadingViewController = nil;

+ (LoadingViewController *)sharedController
{
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedLoadingViewController = [[[self class] alloc] init];
	});
	
	return _sharedLoadingViewController;
}

- (void)addLoadingView:(UIView *)view
{
    [_loadingLabel setText:@"Loading..."];
	self.view.frame = view.bounds;
    [view addSubview:self.view];
    [_totalProgressView setAlpha:0.0];
}

- (void)addLoadingView:(UIView *)view withLabel:(NSString *)label
{
    [_loadingLabel setText:label];
	self.view.frame = view.bounds;
    [view addSubview:self.view];
    [_totalProgressView setAlpha:0.0];
}

- (void)updateProgress:(NSString *)label
{
    [_progressLabel setText:label];
}

- (void)showTotalProgress
{
    [_totalProgressView setAlpha:1.0];
}

- (void)completeSegment:(int)index
{
    [_progressIndicator setFrame:CGRectMake(_progressIndicator.frame.origin.x, _progressIndicator.frame.origin.y, (280/8)*index, _progressIndicator.frame.size.height)];
}

- (void)updateTotalProgress
{
    
}

- (void)removeLoadingView
{
    [self.view removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _loadingBox.layer.cornerRadius = 10.0;
    [_loadingIndicator startAnimating];
    _totalProgressView.layer.borderWidth = 2.0;
    _totalProgressView.layer.borderColor = [UIColor colorWithRed:166.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    _totalProgressView.backgroundColor = [UIColor clearColor];
    _progressIndicator.backgroundColor = [UIColor colorWithRed:166.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	
}

- (void)viewDidUnload {
    [self setLoadingBox:nil];
    [self setLoadingIndicator:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
}
@end
