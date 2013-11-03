//
//  MentionSelectorViewController.h
//  ChatterCheckin
//
//  Created by John Gifford on 10/9/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"

@interface SelectUserViewControllerOrig : UITableViewController <SFRestDelegate,UISearchBarDelegate> {
    NSMutableArray *_dataRows;
    NSMutableArray *_selectedUsers;
    NSMutableArray *_filteredUsers;
    NSString *_nextPageURL;
}

@property (nonatomic,weak) IBOutlet UISearchBar * userSearchBar;
@property (nonatomic,strong) NSArray *selectedUsers;

@end
