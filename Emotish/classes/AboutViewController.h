//
//  AboutViewController.h
//  Emotish
//
//  Created by Dan Bretl on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarView.h"
#import "AboutBlurbView.h"
#import "CoreDataManager.h"

@interface AboutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView * tableView;

@property (strong, nonatomic) AboutBlurbView * appTextContainer;
@property (strong, nonatomic) AboutBlurbView * teamTextContainer;

@property (nonatomic, strong) CoreDataManager * coreDataManager;

@end
