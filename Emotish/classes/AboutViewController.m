//
//  AboutViewController.m
//  Emotish
//
//  Created by Dan Bretl on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "SettingsSectionHeaderView.h"
#import "UIColor+Emotish.h"
#import "EmotishURLManager.h"
#import "AboutTeamMemberCell.h"
#import "ViewConstants.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import "EmotishAlertViews.h"

@interface AboutViewController ()
- (void) backButtonTouched:(UIButton *)button;
- (void) linkButtonGeneralTouched:(UIButton *)linkButtonGeneral;
- (void) linkButtonTwitterTouched:(UIButton *)linkButtonTwitter;
- (void) linkButtonTumblrTouched:(UIButton *)linkButtonTumblr;
- (void) linkButtonEmailTouched:(UIButton *)linkButtonEmail;
- (void) getEmotishTeamMembersFromServer;
- (void) getEmotishTeamMembersFromServerCallback:(NSArray *)teamMemberPhotos error:(NSError *)error;
@property (nonatomic, strong) NSArray * teamMembers;
@property (nonatomic, strong) PFQuery * teamPhotosQuery;
@end

@implementation AboutViewController
@synthesize topBar;
@synthesize tableView = _tableView;
@synthesize appTextContainer=_appTextContainer, teamTextContainer=_teamTextContainer;
@synthesize coreDataManager=_coreDataManager;
@synthesize teamMembers=_teamMembers, teamPhotosQuery=_teamPhotosQuery;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.teamMembers = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.topBar.backgroundColor = [UIColor clearColor];
    [self.topBar showButtonType:BackButton inPosition:LeftNormal animated:NO];
    [self.topBar.buttonLeftNormal addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar setBrandingStampToCurrentAppVersionAnimated:NO];
    self.topBar.backgroundFlagView.overlayImageViewVisibleHangOutDistance = 4.0;
    
    self.appTextContainer = [[AboutBlurbView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    [self.appTextContainer setBlurbText:@"The concept is simple: snap a self-portrait and tag it with whatever you're feeling in the moment. Stay connected with your family, your friends, and people from around the world through the common language of emotion."];
    [self.appTextContainer.linksView addLinkButtonWithText:@"emotish.com" target:self selector:@selector(linkButtonGeneralTouched:)];
    [self.appTextContainer.linksView addLinkButtonWithText:@"@emotishapp" target:self selector:@selector(linkButtonTwitterTouched:)];
    [self.appTextContainer.linksView addLinkButtonWithText:@"emotish.tumblr.com" target:self selector:@selector(linkButtonTumblrTouched:)];
    [self.appTextContainer setNeedsLayout];
    
    self.teamTextContainer = [[AboutBlurbView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    [self.teamTextContainer setBlurbText:@"This app was crafted with care at Redrawn Labs in New York City. We are all about innovative design, speedy iteration, and inspiring technology. And cupcakes. But mostly the first three."];
    [self.teamTextContainer.linksView addLinkButtonWithText:@"redrawnlabs.com" target:self selector:@selector(linkButtonGeneralTouched:)];
    [self.teamTextContainer.linksView addLinkButtonWithText:@"@redrawnlabs" target:self selector:@selector(linkButtonTwitterTouched:)];
    [self.teamTextContainer.linksView addLinkButtonWithText:@"redrawnlabs.tumblr.com" target:self selector:@selector(linkButtonTumblrTouched:)];
    [self.teamTextContainer setNeedsLayout];
    
    [self.appTextContainer layoutIfNeeded];
    [self.teamTextContainer layoutIfNeeded];
        
}

- (void)viewDidUnload {
    [self setTopBar:nil];
    [self setAppTextContainer:nil];
    [self setTeamTextContainer:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if (self.teamMembers.count == 0) {
    //    self.teamMembers = [self.coreDataManager getEmotishTeamMembers]; // Disabling this just to be absolutely sure that we have all team-member-related data downloaded before we show anything.
//        NSLog(@"self.teamMembers.count = %d", self.teamMembers.count);
        [self getEmotishTeamMembersFromServer];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.teamPhotosQuery cancel];
}

- (void)backButtonTouched:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)linkButtonGeneralTouched:(UIButton *)linkButtonGeneral {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [EmotishURLManager openGeneralURLForString:[linkButtonGeneral titleForState:UIControlStateNormal]];
}

- (void)linkButtonTwitterTouched:(UIButton *)linkButtonTwitter {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [EmotishURLManager openTwitterURLForUsername:[linkButtonTwitter titleForState:UIControlStateNormal]];
}

- (void)linkButtonTumblrTouched:(UIButton *)linkButtonTumblr {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [EmotishURLManager openGeneralURLForString:[linkButtonTumblr titleForState:UIControlStateNormal]];
}

- (void)linkButtonEmailTouched:(UIButton *)linkButtonEmail {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString * emailAddress = [linkButtonEmail titleForState:UIControlStateNormal];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController * mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Emotish"];
        [mailViewController setToRecipients:[NSArray arrayWithObject:emailAddress]];
        [self presentModalViewController:mailViewController animated:YES];
    } else {
        [UIPasteboard generalPasteboard].string = emailAddress;
        [[EmotishAlertViews emailAddedToPasteboardAlertView:emailAddress] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView: %d", 1 /* app */ + 1 /* team */ + self.teamMembers.count);
    return 1 /* app */ + 1 /* team */ + self.teamMembers.count /* team members */;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
//    NSInteger rowCount = 0;
//    if (section == 0) {
//        rowCount = 1;
//    } else {
//        rowCount = 1 + 6;
//    }
//    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == 0/* && indexPath.row == 0*/) {
        height = self.appTextContainer.frame.size.height;
    } else if (indexPath.section == 1/* && indexPath.row == 0*/) {
        height = self.teamTextContainer.frame.size.height;
    } else {
        height = tableView.frame.size.height - tableView.sectionHeaderHeight;
//        height = [AboutTeamMemberCell fixedHeight];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * appCellID = @"AppTextCellID";
    static NSString * teamCellID = @"TeamTextCellID";
    static NSString * teamMemberCellID = @"TeamMemberCellID";
    
    BOOL isAppCell  = indexPath.section == 0;// && indexPath.row == 0;
    BOOL isTeamCell = indexPath.section == 1;// && indexPath.row == 0;
    BOOL isTeamMemberCell = indexPath.section > 1;
    
    NSString * CellID = nil;
    
    if (isAppCell) {
        CellID = appCellID;
    } else if (isTeamCell) {
        CellID = teamCellID;
    } else {
        CellID = teamMemberCellID;
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        if (isAppCell || isTeamCell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        } else {
            cell = [[AboutTeamMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        }
        if (isAppCell) {
            [cell addSubview:self.appTextContainer];
        } else if (isTeamCell) {
            [cell addSubview:self.teamTextContainer];
        } else {
            // ...
        }
    }
    
    if (isTeamMemberCell) {
        
        User * teamMember = [self.teamMembers objectAtIndex:indexPath.section - 2];
        
        AboutTeamMemberCell * teamMemberCell = (AboutTeamMemberCell *)cell;
        [teamMemberCell.photoView.photoImageView setImageWithURL:[NSURL URLWithString:teamMember.emotishTeamPhoto.imageURL] placeholderImage:[UIImage imageNamed:@"photo_image_placeholder.png"]];
        teamMemberCell.photoView.photoCaptionTextField.text = teamMember.emotishTeamOneLiner;
        
        [teamMemberCell.linksView removeAllLinkButtons];
        [teamMemberCell.linksView addLinkButtonWithText:[NSString stringWithFormat:@"@%@", teamMember.emotishTeamTwitterUsername] target:self selector:@selector(linkButtonTwitterTouched:)];
        [teamMemberCell.linksView addLinkButtonWithText:teamMember.emotishTeamEmail target:self selector:@selector(linkButtonEmailTouched:)];
        
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableView.sectionHeaderHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * title = nil;
    if (section == 0) {
        title = @"the app";
    } else if (section == 1) {
        title = @"the team";
    } else {
        User * teamMember = [self.teamMembers objectAtIndex:section - 2];
        title = teamMember.name;
    }
    return title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SettingsSectionHeaderView * headerView = [[SettingsSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    headerView.labelText = [self tableView:tableView titleForHeaderInSection:section];
    headerView.labelTextColor = section == 0 ? [UIColor feelingColor] : [UIColor userColor];
    headerView.borderBottomVisible = NO;
//    headerView.borderBottomColor = [UIColor whiteColor];// tableView.separatorColor;
    if (section > 1) {
        headerView.paddingLeft = PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X;
    }
    return headerView;
}

- (void)getEmotishTeamMembersFromServer {
    NSLog(@"getEmotishTeamMembersFromServer");
    self.teamPhotosQuery = [PFQuery queryWithClassName:@"Photo"];
    [self.teamPhotosQuery includeKey:@"user"];
    [self.teamPhotosQuery includeKey:@"feeling"];
    [self.teamPhotosQuery whereKey:@"isEmotishTeamPhoto" equalTo:[NSNumber numberWithBool:YES]];
    [self.teamPhotosQuery findObjectsInBackgroundWithTarget:self selector:@selector(getEmotishTeamMembersFromServerCallback:error:)];
}

- (void)getEmotishTeamMembersFromServerCallback:(NSArray *)teamMemberPhotos error:(NSError *)error {
    NSLog(@"getEmotishTeamMembersFromServerCallback - %d teamMemberPhotos", teamMemberPhotos.count);
    if (!error && teamMemberPhotos.count > 0) {
        for (PFObject * teamMemberPhoto in teamMemberPhotos) {
            PFObject * feeling = [teamMemberPhoto objectForKey:@"feeling"];
            PFUser * user = [teamMemberPhoto objectForKey:@"user"];
            Photo * photoLocal = [self.coreDataManager addOrUpdatePhotoFromServer:teamMemberPhoto feelingFromServer:feeling userFromServer:user];
            photoLocal.user.emotishTeamPhoto = photoLocal;
            NSLog(@"teamMemberPhoto = %@", teamMemberPhoto);
            NSLog(@"user = %@", user);
            NSLog(@"feeling = %@", feeling);
            NSLog(@"photoLocal = %@", photoLocal);
            NSLog(@"photoLocal.feeling = %@", photoLocal.feeling);
            NSLog(@"photoLocal.user = %@", photoLocal.user);
        }
        [self.coreDataManager saveCoreData];
        self.teamMembers = [self.coreDataManager getEmotishTeamMembers];
        NSLog(@"self.teamMembers.count = %d", self.teamMembers.count);
        [self.tableView reloadData];
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, self.teamMembers.count)] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        // Do nothing...
    }
    self.teamPhotosQuery = nil;
}

@end
