//
//  LoadingViewController.h
//  ChatterCheckin
//
//  Created by John Gifford on 10/31/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *loadingBox;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIView *totalProgressView;
@property (weak, nonatomic) IBOutlet UIView *progressIndicator;

+ (LoadingViewController *)sharedController;

- (void)addLoadingView:(UIView *)view;
- (void)addLoadingView:(UIView *)view withLabel:(NSString *)label;
- (void)updateProgress:(NSString *)label;
- (void)showTotalProgress;
- (void)updateTotalProgress;
- (void)completeSegment:(int)index;
- (void)removeLoadingView;



@end
