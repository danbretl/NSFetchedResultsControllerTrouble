//
//  SettingsViewController.m
//  Emotish
//
//  Created by Dan Bretl on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+Emotish.h"
#import "SettingsItemTableViewCell.h"
#import <objc/message.h>
#import "PushConstants.h"

@interface SettingsItem : NSObject
@property (nonatomic, strong) NSString * titleNormal;
@property (nonatomic, strong) NSString * titleActivated;
@property (nonatomic, strong, readonly) NSString * titleCurrent;
@property (nonatomic, strong) NSNumber * activated;
@property (nonatomic, strong) NSNumber * visibleNormal;
@property (nonatomic, strong) NSNumber * visibleActivated;
@property (nonatomic, strong, readonly) NSNumber * visibleCurrent;
@property (nonatomic, strong) NSNumber * showArrowNormal;
@property (nonatomic, strong) NSNumber * showArrowActivated;
@property (nonatomic, strong, readonly) NSNumber * showArrowCurrent;
@property (nonatomic) SEL touchSelector;
@property (nonatomic) int indentLevel;
@property (nonatomic, strong) NSMutableArray * subItems; // An array of SettingsItem objects
@property (nonatomic, strong, readonly) NSArray * subItemsVisible;
- (void) addSubItem:(SettingsItem *)subItem;
+ (SettingsItem *) settingsItemWithTitleNormal:(NSString *)titleNormal titleActivated:(NSString *)titleActivated touchSelector:(SEL)touchSelector visibleNormal:(NSNumber *)visibleNormal visibleActivated:(NSNumber *)visibleActivated showArrowNormal:(NSNumber *)showArrowNormal showArrowActivated:(NSNumber *)showArrowActivated;
@end
@implementation SettingsItem
@synthesize titleNormal=_titleNormal, titleActivated=_titleActivated;
@synthesize activated=_activated;
@synthesize visibleNormal=_visibleNormal, visibleActivated=_visibleActivated, showArrowNormal=_showArrowNormal, showArrowActivated=_showArrowActivated;
@synthesize touchSelector=_touchSelector;
@synthesize indentLevel=_indentLevel;
@synthesize subItems=_subItems, subItemsVisible=_subItemsVisible;
@synthesize titleCurrent=_titleCurrent, visibleCurrent=_visibleCurrent, showArrowCurrent=_showArrowCurrent;
- (id)init {
    if (self = [super init]) {
        self.activated = [NSNumber numberWithBool:NO];
        self.visibleNormal = [NSNumber numberWithBool:YES];
        self.visibleActivated = [NSNumber numberWithBool:YES];
        self.showArrowNormal = [NSNumber numberWithBool:NO];
        self.showArrowActivated = [NSNumber numberWithBool:NO];
        self.indentLevel = 0;
        self.subItems = [NSMutableArray array];
    }
    return self;
}
- (void)addSubItem:(SettingsItem *)subItem {
    subItem.indentLevel = self.indentLevel + 1;
    [self.subItems addObject:subItem];
}
- (void)setIndentLevel:(int)indentLevel {
    _indentLevel = indentLevel;
    for (SettingsItem * subItem in self.subItems) {
        subItem.indentLevel = self.indentLevel + 1;
    }
}
- (NSArray *)subItemsVisible {
    return [self.subItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.visibleCurrent == YES"]];
}
+ (SettingsItem *)settingsItemWithTitleNormal:(NSString *)titleNormal titleActivated:(NSString *)titleActivated touchSelector:(SEL)touchSelector visibleNormal:(NSNumber *)visibleNormal visibleActivated:(NSNumber *)visibleActivated showArrowNormal:(NSNumber *)showArrowNormal showArrowActivated:(NSNumber *)showArrowActivated {
    SettingsItem * settingsItem = [[SettingsItem alloc] init];
    settingsItem.titleNormal = titleNormal;
    settingsItem.titleActivated = titleActivated;
    settingsItem.visibleNormal = visibleNormal;
    settingsItem.visibleActivated = visibleActivated;
    settingsItem.showArrowNormal = showArrowNormal;
    settingsItem.showArrowActivated = showArrowActivated;
    settingsItem.touchSelector = touchSelector;
    return settingsItem;
}
- (NSString *)titleCurrent {
    return self.activated.boolValue ? self.titleActivated : self.titleNormal;
}
- (NSNumber *)visibleCurrent {
    return self.activated.boolValue ? self.visibleActivated : self.visibleNormal;
}
- (NSNumber *)showArrowCurrent {
    return self.activated.boolValue ? self.showArrowActivated : self.showArrowNormal;
}
@end

@interface SettingsViewController()

@property (nonatomic, strong, readonly) NSMutableArray * settingsItems; // Array of SettingsItem objects
- (SettingsItem *) settingsItemForIndexPath:(NSIndexPath *)indexPath;
- (void) backButtonTouched:(UIButton *)button;
- (void) editAccountTouched:(SettingsItem *)settingsItem;
- (void) logoutTouched:(SettingsItem *)settingsItem;
- (void) facebookTouched:(SettingsItem *)settingsItem;
- (void) twitterTouched:(SettingsItem *)settingsItem;
- (void) inviteFriendsTouched:(SettingsItem *)settingsItem;
- (void) sendFeedbackTouched:(SettingsItem *)settingsItem;
- (void) aboutEmotishTouched:(SettingsItem *)settingsItem;
- (void) rateInAppStoreTouched:(SettingsItem *)settingsItem;
+ (UIColor *) colorForSection:(NSUInteger)section;
@property (nonatomic, strong, readonly) UIAlertView * tempUnfinishedAlertView;
@end

@implementation SettingsViewController
@synthesize coreDataManager=_coreDataManager, userLocal=_userLocal, userServer=_userServer;
@synthesize settingsItems=_settingsItems;
@synthesize topBar = _topBar;
@synthesize tableView = _tableView;
@synthesize delegate=_delegate;
@synthesize tempUnfinishedAlertView=_tempUnfinishedAlertView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.topBar showButtonType:BackButton inPosition:LeftNormal animated:NO];
    [self.topBar.buttonLeftNormal addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [self setTopBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SettingsItem * userSettings = [self.settingsItems objectAtIndex:0];
    NSNumber * userLoggedIn = [NSNumber numberWithBool:self.userServer != nil];
    userSettings.activated = userLoggedIn;
    userSettings.titleActivated = self.userServer.username;
    for (SettingsItem * subItem in userSettings.subItems) {
        subItem.activated = userLoggedIn;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) updateDataForUserActivity {
    SettingsItem * userSettings = [self.settingsItems objectAtIndex:0];
    NSNumber * userLoggedIn = [NSNumber numberWithBool:self.userServer != nil];
    userSettings.activated = userLoggedIn;
    userSettings.titleActivated = self.userServer.username;
    for (SettingsItem * subItem in userSettings.subItems) {
        subItem.activated = userLoggedIn;
    }
}

- (void)backButtonTouched:(UIButton *)button {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate settingsViewControllerFinished:self];
}

- (void) editAccountTouched:(SettingsItem *)settingsItem {
    // Push a VC to edit account
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (!settingsItem.activated.boolValue) {
        // Push a VC to sign in to / create an Emotish account
        AccountViewController * accountViewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:[NSBundle mainBundle]];
        accountViewController.delegate = self;
        accountViewController.coreDataManager = self.coreDataManager;
        accountViewController.swipeRightToCancelEnabled = YES;
        [self.navigationController pushViewController:accountViewController animated:YES];
    } else {
        // Push a VC to edit account
        [self.tempUnfinishedAlertView show];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)accountViewController:(AccountViewController *)accountViewController didFinishWithConnection:(BOOL)finishedWithConnection {
    if (finishedWithConnection) {
        self.userServer = [PFUser currentUser];
        self.userLocal = (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", self.userServer.objectId] usingSortDescriptors:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (finishedWithConnection) {
        UIAlertView * loggedInAlertView = [[UIAlertView alloc] initWithTitle:@"Logged In" message:@"Have fun expressing yourself!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [loggedInAlertView show];
    }
}

- (void) logoutTouched:(SettingsItem *)settingsItem {
    // Log the user out
    NSLog(@"%@", NSStringFromSelector(_cmd));
    PFUser * currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        [PFPush unsubscribeFromChannelInBackground:[NSString stringWithFormat:@"%@%@", PUSH_USER_CHANNEL_PREFIX, currentUser.objectId]];
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [PFUser logOut];
    self.userServer = nil;
    self.userLocal = nil;
    [self updateDataForUserActivity];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade]; // This is not perfect, but it's OK for now.
}
- (void) facebookTouched:(SettingsItem *)settingsItem {
    // Connect or disconnect Facebook
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.tempUnfinishedAlertView show];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    if (!settingsItem.activated.boolValue) {
        
    } else {
        
    }
}
- (void) twitterTouched:(SettingsItem *)settingsItem {
    // Connect or disconnect Twitter
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.tempUnfinishedAlertView show];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    if (!settingsItem.activated.boolValue) {
        
    } else {
        
    }    
}
- (void) inviteFriendsTouched:(SettingsItem *)settingsItem {
    // Push a VC to invite friends
    NSLog(@"%@", NSStringFromSelector(_cmd));    
    [self.tempUnfinishedAlertView show];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}
- (void) sendFeedbackTouched:(SettingsItem *)settingsItem {
    // Push a VC to give text feedback
    NSLog(@"%@", NSStringFromSelector(_cmd));    
    [self.tempUnfinishedAlertView show];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}
- (void) aboutEmotishTouched:(SettingsItem *)settingsItem {
    // Push a VC about the app and team
    NSLog(@"%@", NSStringFromSelector(_cmd));    
    [self.tempUnfinishedAlertView show];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}
- (void) rateInAppStoreTouched:(SettingsItem *)settingsItem {
    // Multitask away to the App Store
    NSLog(@"%@", NSStringFromSelector(_cmd));    
    [self.tempUnfinishedAlertView show];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingsItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((SettingsItem *)[self.settingsItems objectAtIndex:section]).subItemsVisible.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get / Create the cell
    static NSString * CellID = @"SettingsItemCellID";
    SettingsItemTableViewCell * cell = (SettingsItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[SettingsItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    SettingsItem * settingsItem = [self settingsItemForIndexPath:indexPath];
    cell.textLabel.text = settingsItem.titleCurrent;
    cell.highlightedBackgroundColor = [[SettingsViewController colorForSection:indexPath.section] colorWithAlphaComponent:0.20];
    cell.arrowView.alpha = settingsItem.showArrowCurrent.boolValue ? 1.0 : 0.0;
    
    // TEMPORARY... VISIBLY DISABLING FACEBOOK & TWITTER CONNECT UNTIL WE IMPLEMENT THOSE FEATURES
    BOOL tempDisable = indexPath.section == 1 && indexPath.row < 2;
    cell.userInteractionEnabled = !tempDisable;
    cell.textLabel.alpha = tempDisable ? 0.5 : 1.0;
    
    // Return the cell
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableView.sectionHeaderHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SettingsItem * settingsItem = [self.settingsItems objectAtIndex:section];
    return settingsItem.titleCurrent;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    UIView * sectionHeaderBorderBottom = [[UIView alloc] initWithFrame:CGRectMake(0, sectionHeaderView.frame.size.height - 1, sectionHeaderView.frame.size.width, 1)];
    sectionHeaderBorderBottom.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    sectionHeaderBorderBottom.backgroundColor = tableView.separatorColor;
    [sectionHeaderView addSubview:sectionHeaderBorderBottom];
    CGFloat sectionHeaderLabelPaddingHorizontal = 20.0;
    UILabel * sectionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(sectionHeaderLabelPaddingHorizontal, 0, sectionHeaderView.frame.size.width - 2 * sectionHeaderLabelPaddingHorizontal, sectionHeaderView.frame.size.height)];
    sectionHeaderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    sectionHeaderLabel.textColor = [SettingsViewController colorForSection:section];
    sectionHeaderLabel.font = [UIFont boldSystemFontOfSize:38.0];
    sectionHeaderLabel.textAlignment = UITextAlignmentLeft;
    sectionHeaderLabel.adjustsFontSizeToFitWidth = NO;
    sectionHeaderLabel.backgroundColor = [UIColor clearColor];
    sectionHeaderLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [sectionHeaderView addSubview:sectionHeaderLabel];
    sectionHeaderView.alpha = 0.8;
    return sectionHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsItem * settingsItem = [self settingsItemForIndexPath:indexPath];
//    NSLog(@"%@ - %@ - %@ - %@", settingsItem, settingsItem.titleNormal, settingsItem.titleActivated, settingsItem.touchSelector);
//    [self performSelector:settingsItem.touchSelector withObject:settingsItem]; // This causes a warning with ARC.
    objc_msgSend(self, settingsItem.touchSelector, settingsItem);    
}

+ (UIColor *)colorForSection:(NSUInteger)section {
    CGFloat red, green, blue;
    switch (section) {
        case 0: red=115; green=205; blue=247; break;
        case 1: red=254; green=180; blue= 36; break;
        case 2: red=185; green=203; blue=218; break;
        default:  
            red = 0; green = 0; blue = 0;
            NSLog(@"ERROR in SettingsViewController - unrecognized section number %d", section);
            break;
    }
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

- (SettingsItem *)settingsItemForIndexPath:(NSIndexPath *)indexPath {
    return [((SettingsItem *)[self.settingsItems objectAtIndex:indexPath.section]).subItems objectAtIndex:indexPath.row];
}

- (NSArray *)settingsItems {
    if (_settingsItems == nil) {
        _settingsItems = [NSMutableArray array];
        NSNumber * noObj = [NSNumber numberWithBool:NO];
        NSNumber * yesObj = [NSNumber numberWithBool:YES];
        SettingsItem * userSettings = [SettingsItem settingsItemWithTitleNormal:@"user" titleActivated:@"username" touchSelector:NULL visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:noObj showArrowActivated:noObj];
        {
            [userSettings addSubItem:[SettingsItem settingsItemWithTitleNormal:@"sign in to account" titleActivated:@"edit account" touchSelector:@selector(editAccountTouched:) visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:yesObj showArrowActivated:yesObj]];
            [userSettings addSubItem:[SettingsItem settingsItemWithTitleNormal:nil titleActivated:@"log out" touchSelector:@selector(logoutTouched:) visibleNormal:noObj visibleActivated:yesObj showArrowNormal:noObj showArrowActivated:noObj]];
        }
        SettingsItem * connectionsSettings = [SettingsItem settingsItemWithTitleNormal:@"connections" titleActivated:@"connections" touchSelector:NULL visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:noObj showArrowActivated:noObj];
        {
            [connectionsSettings addSubItem:[SettingsItem settingsItemWithTitleNormal:@"connect facebook" titleActivated:@"disconnect facebook" touchSelector:@selector(facebookTouched:) visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:noObj showArrowActivated:noObj]];
            [connectionsSettings addSubItem:[SettingsItem settingsItemWithTitleNormal:@"connect twitter" titleActivated:@"disconnect twitter" touchSelector:@selector(facebookTouched:) visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:noObj showArrowActivated:noObj]];
            [connectionsSettings addSubItem:[SettingsItem settingsItemWithTitleNormal:@"invite friends" titleActivated:@"invite friends" touchSelector:@selector(inviteFriendsTouched:) visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:yesObj showArrowActivated:yesObj]];
        }
        SettingsItem * emotishSettings = [SettingsItem settingsItemWithTitleNormal:@"emotish" titleActivated:@"emotish" touchSelector:NULL visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:noObj showArrowActivated:noObj];
        {
            [emotishSettings addSubItem:[SettingsItem settingsItemWithTitleNormal:@"send feedback" titleActivated:@"send feedback" touchSelector:@selector(sendFeedbackTouched:) visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:yesObj showArrowActivated:yesObj]];
            [emotishSettings addSubItem:[SettingsItem settingsItemWithTitleNormal:@"about emotish" titleActivated:@"about emotish" touchSelector:@selector(aboutEmotishTouched:) visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:yesObj showArrowActivated:yesObj]];
            [emotishSettings addSubItem:[SettingsItem settingsItemWithTitleNormal:@"rate in app store" titleActivated:@"rate in app store" touchSelector:@selector(rateInAppStoreTouched:) visibleNormal:yesObj visibleActivated:yesObj showArrowNormal:noObj showArrowActivated:noObj]];
        }
        [_settingsItems addObject:userSettings];
        [_settingsItems addObject:connectionsSettings];
        [_settingsItems addObject:emotishSettings];
    }
    return _settingsItems;
}

- (UIAlertView *)tempUnfinishedAlertView {
    if (_tempUnfinishedAlertView == nil) {
        _tempUnfinishedAlertView = [[UIAlertView alloc] initWithTitle:@"Coming Soon!" message:@"Sorry, this feature hasn't been implemented yet. All you can do for now is log in and out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return _tempUnfinishedAlertView;
}

@end
