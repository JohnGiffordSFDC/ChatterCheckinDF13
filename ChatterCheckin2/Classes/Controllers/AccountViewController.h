//
//  AccountViewController.h
//  ChatterCheckin2
//
//  Created by John Gifford on 11/4/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UITableViewController <UIGestureRecognizerDelegate> {
    NSMutableArray *_accounts;
    int _counter;
    bool _showProgress;
    NSTimer *_accountTimer;
    NSTimer *_contactTimer;
    NSTimer *_leadTimer;
    NSTimer *_opportunityTimer;
    NSTimer *_userTimer;
    NSTimer *_activityTimer;
    NSTimer *_tasksTimer;
    NSTimer *_eventTimer;
}

@end
