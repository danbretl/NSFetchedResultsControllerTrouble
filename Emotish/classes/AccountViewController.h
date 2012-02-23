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

@protocol AccountViewControllerDelegate;

@interface AccountViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    
    BOOL initialPromptScreenVisible;
    BOOL accountCreationViewsVisible;
    BOOL confirmPasswordVisible;
    BOOL waitingForFacebookAuthentication;
    BOOL waitingForFacebookInfo;
    
}

@property (nonatomic, unsafe_unretained) id<AccountViewControllerDelegate> delegate;
@property (nonatomic, strong) CoreDataManager * coreDataManager;

@end

@protocol AccountViewControllerDelegate <NSObject>

- (void) accountViewController:(AccountViewController *)accountViewController didFinishWithConnection:(BOOL)finishedWithConnection;

@end