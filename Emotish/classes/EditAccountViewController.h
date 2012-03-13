//
//  EditAccountViewController.h
//  Emotish
//
//  Created by Dan Bretl on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextFieldWithInsetAndUnderline.h"
#import "CoreDataManager.h"
#import "TopBarView.h"

// THE VARIOUS EDIT ACCOUNT INPUT TYPES ARE HARD CODED, AND THE RELATIVE POSITIONS OF THEIR TEXT FIELDS AND LABELS ARE AS WELL.
typedef enum {
    EditAccountUsername = 0,
    EditAccountEmail = 1,
    EditAccountPassword = 2,
} EditAccountInputType;

@interface EditAccountViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel * headerLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel * usernameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * emailLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * passwordLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInsetAndUnderline *usernameTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInsetAndUnderline *emailTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInsetAndUnderline *passwordTextField;

@property (unsafe_unretained, nonatomic) IBOutlet TopBarView *topBar;

@property (strong, nonatomic) CoreDataManager * coreDataManager;

@end
