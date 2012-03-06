//
//  AccountViewController.h
//  Kwiqet
//
//  Created by Dan Bretl on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CoreDataManager.h"

typedef enum {
    FailureToConnect = 0,
    UsernameEmailAccountConnect = 1,
    FacebookAccountConnect = 2,
    TwitterAccountConnect = 3,
} AccountConnectMethod;

@protocol AccountViewControllerDelegate;

@interface AccountViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, PF_FBRequestDelegate, UIGestureRecognizerDelegate, NSURLConnectionDataDelegate> {
    
    BOOL initialPromptScreenVisible;
    BOOL accountCreationViewsVisible;
    BOOL confirmPasswordVisible;
    
}

@property (nonatomic, unsafe_unretained) id<AccountViewControllerDelegate> delegate;
@property (nonatomic, strong) CoreDataManager * coreDataManager;
@property (nonatomic) BOOL swipeDownToCancelEnabled;
@property (nonatomic) BOOL swipeRightToCancelEnabled;
@property (nonatomic) BOOL workingOnAccountFromFacebook;
@property (nonatomic) BOOL workingOnAccountFromTwitter;
@property (nonatomic, readonly) BOOL workingOnAccountFromSocialNetwork;
@property (nonatomic) BOOL shouldImmediatelyAttemptFacebookConnect;
@property (nonatomic) BOOL shouldImmediatelyAttemptTwitterConnect;

@end

@protocol AccountViewControllerDelegate <NSObject>

- (void) accountViewController:(AccountViewController *)accountViewController didFinishWithConnection:(BOOL)finishedWithConnection viaConnectMethod:(AccountConnectMethod)connectMethod;

@end