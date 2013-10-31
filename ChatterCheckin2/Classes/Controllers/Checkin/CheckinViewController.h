//
//  CheckinViewController.h
//  ChatterCheckin
//
//  Created by John Gifford on 10/5/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"

@interface CheckinViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, SFRestDelegate, UIAlertViewDelegate> {
    NSMutableArray *_selectedUsers;
}

@property (nonatomic, retain) NSArray *placemarks;

@property (retain, nonatomic) IBOutlet UITextField *location;
@property (retain, nonatomic) IBOutlet UITextView *status;
@property (retain, nonatomic) IBOutlet UIButton *selectButton;

- (IBAction)selectPeople:(id)sender;

@end
