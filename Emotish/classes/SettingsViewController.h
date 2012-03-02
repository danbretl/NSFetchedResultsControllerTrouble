//
//  SettingsViewController.h
//  Emotish
//
//  Created by Dan Bretl on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataManager.h"
#import "User.h"
#import <Parse/Parse.h>
#import "TopBarView.h"
#import "AccountViewController.h"

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AccountViewControllerDelegate>

@property (nonatomic, strong) CoreDataManager * coreDataManager;
//@property (nonatomic, strong) User * userLocal;
//@property (nonatomic, strong) PFUser * userServer;

@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView * tableView;

@property (unsafe_unretained, nonatomic) id<SettingsViewControllerDelegate> delegate;

@end

@protocol SettingsViewControllerDelegate <NSObject>
- (void) settingsViewControllerFinished:(SettingsViewController *)settingsViewController;
@end
