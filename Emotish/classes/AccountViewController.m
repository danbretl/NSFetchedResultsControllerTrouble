//
//  AccountViewController.m
//  Kwiqet
//
//  Created by Dan Bretl on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+GetFirstResponder.h"
#import "TopBarView.h"
#import "NSString+EmailValidity.h"
#import "UITextFieldWithInsetAndUnderline.h"
#import "FlagStretchView.h"

double const AP_NAV_BUTTONS_ANIMATION_DURATION = 0.25;
CGFloat const AVC_NO_ACCOUNT_ASSURANCE_LABEL_MARGIN_TOP = 15.0;
CGFloat const AVC_INPUT_CONTAINER_PADDING_BOTTOM = 20.0;

@interface AccountViewController()
// Data models
@property (nonatomic, strong) NSString * usernameInputString;
@property (nonatomic, strong) NSString * emailInputString;
@property (nonatomic, strong) NSString * passwordInputString;
@property (nonatomic, strong) NSString * confirmPasswordInputString;
// Top bar
@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
// Main container
@property (unsafe_unretained, nonatomic) IBOutlet UIView * mainViewsContainer;
// Account connect options container
@property (unsafe_unretained, nonatomic) IBOutlet UIView * accountOptionsContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * blurbLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * usernameButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * facebookButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * twitterButton;
// Input container
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView * inputContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *accountConnectionPromptLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * accountCreationPromptLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView * textFieldsContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInsetAndUnderline * usernameTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInsetAndUnderline * emailTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInsetAndUnderline * passwordTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInsetAndUnderline * confirmPasswordTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * emailAccountAssuranceLabel;
// Gesture recognizers
@property (strong) UISwipeGestureRecognizer * swipeDownGestureRecognizer;
// Alert views
@property (nonatomic, strong, readonly) UIAlertView * passwordIncorrectAlertView;
@property (nonatomic, strong, readonly) UIAlertView * emailInvalidAlertView;
@property (nonatomic, strong, readonly) UIAlertView * forgotPasswordConnectionErrorAlertView;
@property (nonatomic, strong, readonly) UIAlertView * anotherAccountWithUsernameExistsAlertView;
@property (nonatomic, strong, readonly) UIAlertView * anotherAccountWithEmailExistsAlertView;
@property (nonatomic, strong, readonly) UIAlertView * connectionErrorGeneralAlertView;
// Utility BOOLs
@property (nonatomic) BOOL waitingForLikes;
@property (nonatomic) BOOL waitingToSubscribeToNotificationsChannel;

// Methods - General
- (void) cancelButtonTouched:(id)sender;
- (void) doneButtonTouched:(id)sender;
- (IBAction) accountOptionButtonTouched:(id)accountOptionButton;
- (void) swipedDown:(UISwipeGestureRecognizer *)swipeGestureRecognizer;
- (void) userInputSubmissionAttemptRequested;
- (void) accountConnectionAttemptRequested;
- (void) accountCreationAttemptRequested;
- (void) resignFirstResponderForAllTextFields;
- (void) showContainer:(UIView *)viewsContainer animated:(BOOL)animated;
- (void) showAccountCreationInputViews:(BOOL)shouldShowCreationViews showPasswordConfirmation:(BOOL)shouldShowPasswordConfirmation activateAppropriateFirstResponder:(BOOL)shouldActivateFirstResponder animated:(BOOL)animated;
- (void) setTextFieldToBeVisible:(UITextField *)textField animated:(BOOL)animated;
// Methods - Keyboard responses
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardWillShow:(NSNotification *)notification;
// Methods - Facebook
//- (void) facebookAccountActivity:(NSNotification *)notification;
//- (void) facebookGetBasicInfoSuccess:(NSNotification *)notification;
//- (void) facebookGetBasicInfoFailure:(NSNotification *)notification;
// Methods - Web
- (void)logInWithUsernameCallback:(PFUser *)user error:(NSError **)error;
- (void) attemptToProceedWithSuccessfulLogin;

@end

@implementation AccountViewController

@synthesize usernameInputString=_usernameInputString, emailInputString=_emailInputString, passwordInputString=_passwordInputString, confirmPasswordInputString=_confirmPasswordInputString;
@synthesize topBar=_topBar;
@synthesize mainViewsContainer=_mainViewsContainer;
@synthesize accountOptionsContainer=_accountOptionsContainer, blurbLabel=_blurbLabel, usernameButton=_usernameButton, facebookButton=_facebookButton, twitterButton=_twitterButton;
@synthesize inputContainer=_inputContainer;
@synthesize accountConnectionPromptLabel = _accountConnectionPromptLabel, accountCreationPromptLabel=_accountCreationPromptLabel;
@synthesize textFieldsContainer=_textFieldsContainer, usernameTextField=_usernameTextField, emailTextField=_emailTextField, passwordTextField=_passwordTextField, confirmPasswordTextField=_confirmPasswordTextField;
@synthesize emailAccountAssuranceLabel;
@synthesize swipeDownGestureRecognizer=_swipeDownGestureRecognizer;
@synthesize passwordIncorrectAlertView=_passwordIncorrectAlertView, emailInvalidAlertView=_emailInvalidAlertView, forgotPasswordConnectionErrorAlertView=_forgotPasswordConnectionErrorAlertView, anotherAccountWithUsernameExistsAlertView=_anotherAccountWithUsernameExistsAlertView, anotherAccountWithEmailExistsAlertView=_anotherAccountWithEmailExistsAlertView, connectionErrorGeneralAlertView=_connectionErrorGeneralAlertView;
@synthesize waitingForLikes=_waitingForLikes, waitingToSubscribeToNotificationsChannel=_waitingToSubscribeToNotificationsChannel;

@synthesize coreDataManager=_coreDataManager;
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        initialPromptScreenVisible = YES;
        accountCreationViewsVisible = YES;
        confirmPasswordVisible = YES;
        self.waitingForLikes = NO;
        self.waitingToSubscribeToNotificationsChannel = NO;
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
    [self.topBar showButtonType:CancelButton inPosition:LeftNormal animated:NO];
    [self.topBar showButtonType:DoneButton inPosition:RightNormal animated:NO];
    [self.topBar.buttonLeftNormal addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar.buttonRightNormal addTarget:self action:@selector(doneButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor * almostGreyColor = [UIColor colorWithRed:137.0/255.0 green:135.0/255.0 blue:135.0/255.0 alpha:1.0];
    
    self.blurbLabel.textColor = almostGreyColor;
    self.accountConnectionPromptLabel.textColor = almostGreyColor;
    self.accountCreationPromptLabel.textColor = almostGreyColor;
    self.emailAccountAssuranceLabel.textColor = [UIColor colorWithRed:103.0/255.0 green:186.0/255.0 blue:225.0/255.0 alpha:1.0];

    self.usernameTextField.textColor = almostGreyColor;
    self.emailTextField.textColor = almostGreyColor;
    self.passwordTextField.textColor = almostGreyColor;
    self.confirmPasswordTextField.textColor = almostGreyColor;
    
    UILabel * orLine = [[UILabel alloc] initWithFrame:CGRectMake(self.usernameButton.frame.origin.x, CGRectGetMaxY(self.usernameButton.frame), self.usernameButton.frame.size.width, CGRectGetMinY(self.facebookButton.frame) - CGRectGetMaxY(self.usernameButton.frame))];
    orLine.font = [UIFont italicSystemFontOfSize:12];
    orLine.textColor = almostGreyColor;
    orLine.autoresizingMask = self.usernameButton.autoresizingMask;
    orLine.text = @"OR";
    orLine.textAlignment = UITextAlignmentCenter;
    CGSize orSize = [orLine.text sizeWithFont:orLine.font];
    CGFloat orStartXPadding = 8;
    CGFloat orEndXPadding = 8;
    CGFloat orStartX = (orLine.frame.size.width - orSize.width) / 2.0 - orStartXPadding;
    CGFloat orEndX = orStartX + + orStartXPadding + orSize.width + orEndXPadding;
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.frame = orLine.bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathAddRect(maskPath, nil, CGRectMake(0, 0, orStartX, maskLayer.frame.size.height));
    CGPathAddRect(maskPath, nil, CGRectMake(orEndX, 0, maskLayer.frame.size.width - orEndX, maskLayer.frame.size.height));
    maskLayer.path = maskPath;
    CGPathRelease(maskPath);
    CALayer * dividerGrayLayer = [CALayer layer];
    CGFloat dividerGrayLayerHeight = 1;
    dividerGrayLayer.frame = CGRectMake(0, floorf((orLine.frame.size.height - dividerGrayLayerHeight) / 2.0), orLine.frame.size.width, dividerGrayLayerHeight);
    dividerGrayLayer.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:224.0/255.0 blue:226.0/255.0 alpha:1.0].CGColor;
    dividerGrayLayer.mask = maskLayer;
    [orLine.layer addSublayer:dividerGrayLayer];
    [self.accountOptionsContainer addSubview:orLine];
    
    UIEdgeInsets textFieldInsets = UIEdgeInsetsMake(0, 0, 8.0, 0);
    self.usernameTextField.textFieldInsets = textFieldInsets;
    self.emailTextField.textFieldInsets = textFieldInsets;
    self.passwordTextField.textFieldInsets = textFieldInsets;
    self.confirmPasswordTextField.textFieldInsets = textFieldInsets;
    
    self.mainViewsContainer.backgroundColor = [UIColor clearColor];
    self.accountOptionsContainer.backgroundColor = [UIColor clearColor];
    self.inputContainer.backgroundColor = [UIColor clearColor];
    self.textFieldsContainer.backgroundColor = [UIColor clearColor];
    
    [self.mainViewsContainer addSubview:self.accountOptionsContainer];
    self.accountOptionsContainer.frame = CGRectMake(0, 0, self.accountOptionsContainer.frame.size.width, self.accountOptionsContainer.frame.size.height);
    [self.mainViewsContainer addSubview:self.inputContainer];
    self.inputContainer.frame = CGRectMake(self.mainViewsContainer.frame.size.width, 0, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
    
    self.swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown:)];
    self.swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:self.swipeDownGestureRecognizer];
    
    // Register for Facebook events
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookAccountActivity:) name:FBM_ACCOUNT_ACTIVITY_KEY object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookGetBasicInfoSuccess:) name:FBM_GET_BASIC_INFO_AND_EMAIL_SUCCESS_KEY object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookGetBasicInfoFailure:) name:FBM_GET_BASIC_INFO_AND_EMAIL_FAILURE_KEY object:nil];
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // The view might have unloaded due to a memory warning. If so, get back to where we were now.
    [self showContainer:initialPromptScreenVisible ? self.accountOptionsContainer : self.inputContainer animated:NO];
    [self showAccountCreationInputViews:accountCreationViewsVisible showPasswordConfirmation:confirmPasswordVisible activateAppropriateFirstResponder:NO animated:NO];
    self.usernameTextField.text = self.usernameInputString;
    self.emailTextField.text = self.emailInputString;
    self.passwordTextField.text = self.passwordInputString;
    self.confirmPasswordTextField.text = self.confirmPasswordInputString;
    
}

- (void)viewDidUnload {
    self.topBar = nil;
    self.blurbLabel = nil;
    self.usernameButton = nil;
    self.facebookButton = nil;
    self.twitterButton = nil;
    self.mainViewsContainer = nil;
    self.accountOptionsContainer = nil;
    self.inputContainer = nil;
    self.emailTextField = nil;
    self.passwordTextField = nil;
    self.emailAccountAssuranceLabel = nil;
    self.confirmPasswordTextField = nil;
    self.textFieldsContainer = nil;
    self.usernameTextField = nil;
    self.accountCreationPromptLabel = nil;
    [self setAccountConnectionPromptLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.facebookButton.enabled = NO;
    self.facebookButton.alpha   = 0.5;    
    self.twitterButton.enabled  = NO;
    self.twitterButton.alpha    = 0.5;
}

- (IBAction)accountOptionButtonTouched:(id)accountOptionButton {
    if (accountOptionButton == self.usernameButton) {
        
        [self showContainer:self.inputContainer animated:YES];
        [self.usernameTextField becomeFirstResponder];
        
    } else if (accountOptionButton == self.facebookButton) {
        NSLog(@"Facebook button touched");
        
//        [self.facebookManager pullAuthenticationInfoFromDefaults];
//        if (![self.facebookManager.fb isSessionValid]) {
//            waitingForFacebookAuthentication = YES;
//            [self.facebookManager login];
//            
//            // Wait for a notification about succeeding or failing to Facebook-authenticate.
//            
//        } else {
//            
//            // Get from Facebook, using the authenticated Facebook account:
//            // - the account ID
//            // - the email(s) associated with that account
//            waitingForFacebookInfo = YES;
//            [self.facebookManager getBasicInfoAndEmail];
//            
//            // Wait for a notification about succeeding or failing to get that info. Allow for a user cancel.
//            
//        }
        
    } else if (accountOptionButton == self.twitterButton) {
        NSLog(@"Twitter button touched");
    } else {
        NSLog(@"ERROR in AccountPromptViewController - unrecognized accountOptionButton %@", accountOptionButton);
    }
}

//- (void)facebookAccountActivity:(NSNotification *)notification {
//    if (waitingForFacebookAuthentication) {
//        waitingForFacebookAuthentication = NO;
//        // Check the notification.
//        NSString * action = [notification.userInfo objectForKey:FBM_ACCOUNT_ACTIVITY_ACTION_KEY];
//        if ([action isEqualToString:FBM_ACCOUNT_ACTIVITY_ACTION_LOGIN]) {
//            [self.facebookManager pullAuthenticationInfoFromDefaults];
//            // Get from Facebook, using the authenticated Facebook account:
//            // - the account ID
//            // - the email(s) associated with that account
//            waitingForFacebookInfo = YES;
//            [self.facebookManager getBasicInfoAndEmail];
//        } else {
//            BOOL userCancelled = [[notification.userInfo objectForKey:FBM_ACCOUNT_ACTIVITY_ACTION_LOGOUT_IS_DUE_TO_CANCEL_KEY] boolValue];
//            if (!userCancelled) {
//                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook Connect" message:@"Could not connect to Facebook. Please try again, or try connecting to Kwiqet another way." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
//            }
//        }
//    }
//}
//
//- (void)facebookGetBasicInfoSuccess:(NSNotification *)notification {
//    if (waitingForFacebookInfo) {
//        waitingForFacebookInfo = NO;
//        // Call our server with the Facebook account ID and associated email, and wait for one of a few responses:
//        // - Kwiqet account exists that is associated either with given Facebook account ID or email ; Will receive an API key, should log in the user.
//        // - Associated Kwiqet account does not exist ; should send the user to the Kwiqet account creation screen (either with Facebook info we already grabbed, or start grabbing it then)
//        NSString * fbID = [notification.userInfo objectForKey:FBM_BASIC_INFO_FACEBOOK_ID_KEY];
//        NSString * fbEmail = [notification.userInfo objectForKey:FBM_BASIC_INFO_EMAIL_KEY];
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Not Implemented" message:[NSString stringWithFormat:@"At this point, we should call our server, with the Facebook account ID %@ and associated email %@.", fbID, fbEmail] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//    }
//}
//
//- (void)facebookGetBasicInfoFailure:(NSNotification *)notification {
//    if (waitingForFacebookInfo) {
//        waitingForFacebookInfo = NO;
//        // Report back to the user that we failed to authenticate via Facebook. Instruct to try again or choose another avenue.
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook Connect" message:@"Could not connect to Facebook. Please try again, or try connecting to Kwiqet another way." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//    }    
//}

- (void)cancelButtonTouched:(id)sender {
    if (initialPromptScreenVisible) {
//        if (waitingForFacebookAuthentication || waitingForFacebookInfo) {
//            waitingForFacebookAuthentication = NO;
//            waitingForFacebookInfo = NO;
//            [self.facebookManager.fb cancelPendingRequest];
//        } else {
            [self.delegate accountViewController:self didFinishWithConnection:NO];
//        }
    } else {
        [self showContainer:self.accountOptionsContainer animated:YES];
    }
}

- (void)userInputSubmissionAttemptRequested {
    if (accountCreationViewsVisible) {
        [self accountCreationAttemptRequested];
    } else {
        [self accountConnectionAttemptRequested];
    }    
}

- (void) doneButtonTouched:(id)sender {
    [self userInputSubmissionAttemptRequested];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    NSLog(@"textFieldDidBeginEditing:%@", textField);
    [self setTextFieldToBeVisible:textField animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (textField.text.isPotentialEmailAddress &&
            !accountCreationViewsVisible) {
            self.emailInputString = textField.text;
        } else {
            self.usernameInputString = textField.text;
        }
    } else if (textField == self.emailTextField) {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.emailInputString = textField.text;
    } else if (textField == self.passwordTextField) {
        self.passwordInputString = textField.text;
    } else if (textField == self.confirmPasswordTextField) {
        self.confirmPasswordInputString = textField.text;
    } else {
        NSLog(@"ERROR in AccountPromptViewController - unrecognized textFieldDidEndEditing:%@", textField);
    }
}

- (void)setTextFieldToBeVisible:(UITextField *)textField animated:(BOOL)animated {
    CGRect textFieldRectInInputContainer = [self.inputContainer convertRect:textField.frame fromView:textField.superview];
    [self.inputContainer scrollRectToVisible:CGRectInset(textFieldRectInInputContainer, 0, -AVC_INPUT_CONTAINER_PADDING_BOTTOM) animated:animated];
}

//- (void) setTextFieldToBeVisible:(UITextField *)textField animated:(BOOL)animated {
//    
//    void(^adjustmentsBlock)(void) = ^{
//        BOOL shouldScroll = NO;
//        CGFloat contentOffsetY = 0;
//        if (CGRectGetMinY(containerView.frame) - 10 < self.inputContainer.contentOffset.y) {
//            shouldScroll = YES;
//            contentOffsetY = CGRectGetMinY(containerView.frame) - 10;
//        } else {
//            CGFloat visibleHeightOfScrollView = self.inputContainer.frame.size.height - (self.inputContainer.contentInset.top + self.inputContainer.contentInset.bottom);
//            if (CGRectGetMaxY(containerView.frame) + 10 > self.inputContainer.contentOffset.y + visibleHeightOfScrollView) {
//                shouldScroll = YES;
//                contentOffsetY = MIN(CGRectGetMaxY(containerView.frame) - containerView.frame.size.height - 10, self.inputContainer.contentSize.height - visibleHeightOfScrollView);
//            }
//        }
//        if (shouldScroll) {
//            self.inputContainer.contentOffset = CGPointMake(0, contentOffsetY);
//        }
//    };
//    
//    if (animated) {
//        [UIView animateWithDuration:0.25 animations:adjustmentsBlock];
//    } else {
//        adjustmentsBlock();
//    }
//    
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        self.passwordTextField.returnKeyType = confirmPasswordVisible ? UIReturnKeyNext : UIReturnKeySend;
    }    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        if (accountCreationViewsVisible) {
            [self.emailTextField becomeFirstResponder];
        } else {
            [self.passwordTextField becomeFirstResponder];
        }
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        if (confirmPasswordVisible) {
            [self.confirmPasswordTextField becomeFirstResponder];
        } else {
            [self userInputSubmissionAttemptRequested];
        }
    } else if (textField == self.confirmPasswordTextField) {
        [self userInputSubmissionAttemptRequested];
    } else {
        NSLog(@"ERROR in AccountPromptViewController - unrecognized textField");
    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.passwordIncorrectAlertView ||
        alertView == self.forgotPasswordConnectionErrorAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // Start 'forgot password' flow.
            NSLog(@"FORGOT PASSWORD WEB CALL SHOULD BE HERE");
            [PFUser requestPasswordResetForEmailInBackground:self.emailInputString block:^(BOOL succeeded, NSError * error){
                if (succeeded) {
                    UIAlertView * passwordResetEmailAlertView = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:@"An email has been sent with a link to reset your password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [passwordResetEmailAlertView show];
                } else {
                    [self.forgotPasswordConnectionErrorAlertView show];
                }
            }];
//            [self.webConnector forgotPasswordForAccountAssociatedWithEmail:self.emailTextField.text];
        } else {
            // Do nothing.
        }
    } else if (alertView == self.anotherAccountWithUsernameExistsAlertView ||
               alertView == self.anotherAccountWithEmailExistsAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // Change email or username
            if (alertView == self.anotherAccountWithUsernameExistsAlertView) {
                [self.usernameTextField becomeFirstResponder];
            } else {
                [self.emailTextField becomeFirstResponder];
            }
        } else {
            // Log in
            NSString * userIdentifierString = alertView == self.anotherAccountWithUsernameExistsAlertView ? self.usernameInputString : self.emailInputString;
            self.usernameTextField.text = userIdentifierString;
            self.passwordTextField.text = @"";
            [self showAccountCreationInputViews:NO showPasswordConfirmation:NO activateAppropriateFirstResponder:YES animated:YES];
        }
    }
}

//- (void)webConnector:(WebConnector *)webConnector forgotPasswordSuccess:(ASIHTTPRequest *)request forAccountAssociatedWithEmail:(NSString *)emailString {
//        
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:[NSString stringWithFormat:@"Check your email at %@ and follow the link provided to set a new password.", emailString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show]; 
//    
//    [self.passwordTextField becomeFirstResponder];
//    self.passwordTextField.text = @"";
//    self.confirmPasswordTextField.text = @""; // Sort of silly.
//    
//}
//
//- (void)webConnector:(WebConnector *)webConnector forgotPasswordFailure:(ASIHTTPRequest *)request forAccountAssociatedWithEmail:(NSString *)emailString {
//    [self.forgotPasswordConnectionErrorAlertView show];
//}

- (void) accountConnectionAttemptRequested {
    
    self.usernameTextField.text = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.emailTextField.text = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString * idInput = self.usernameTextField.text;
    BOOL idInputEntered = idInput.length > 0;
    BOOL idInputIsEmail = idInputEntered && idInput.isPotentialEmailAddress;
    BOOL idInputIsEmailValid = idInputIsEmail && idInput.isValidEmailAddress;

    if (idInputEntered) {
        if (idInputIsEmail && !idInputIsEmailValid) {
            UIAlertView * emailInvalidSpecialAlertView = [[UIAlertView alloc] initWithTitle:self.emailInvalidAlertView.title message:@"You must enter a valid email address or username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [emailInvalidSpecialAlertView show];
            [self.usernameTextField becomeFirstResponder];
        } else {
            self.passwordInputString = self.passwordTextField.text;
            NSString * queryKey = nil;
            if (idInputIsEmail) {
                self.emailInputString = idInput;
                queryKey = @"emailLowercase";
            } else {
                self.usernameInputString = idInput;
                queryKey = @"usernameLowercase";
            }
            PFQuery * queryForUser = [PFQuery queryForUser];
            [queryForUser whereKey:queryKey equalTo:idInput.lowercaseString];
            [queryForUser getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
                if (!error) {
                    if (object != nil) {
                        PFUser * userObject = (PFUser *)object;
                        NSLog(@"About to call logInWithUsernameInBackground username:%@ password:%@", userObject.username, self.passwordInputString);
                        self.emailInputString = userObject.email; // Sort of a hack...
                        [PFUser logInWithUsernameInBackground:userObject.username password:self.passwordInputString target:self selector:@selector(logInWithUsernameCallback:error:)];
                    } else {
                        [self showAccountCreationInputViews:YES showPasswordConfirmation:YES activateAppropriateFirstResponder:YES animated:YES];
                    }
                } else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    [self.connectionErrorGeneralAlertView show];
                }
            }];
            
        }
    } else {
        [self.usernameTextField becomeFirstResponder];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" 
                                                         message:@"You must enter a username or email address."
                                                        delegate:nil 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)logInWithUsernameCallback:(PFUser *)user error:(NSError **)error {
    if (!error) {
        if (user != nil) {
            NSLog(@"Logged in with user %@", user);
            [self.coreDataManager addOrUpdateUserFromServer:user];
            [self.coreDataManager saveCoreData];
            self.waitingForLikes = YES;
            self.waitingToSubscribeToNotificationsChannel = YES;
            PFQuery * likesQuery = [PFQuery queryWithClassName:@"Like"];
            [likesQuery whereKey:@"user" equalTo:user];
            [likesQuery includeKey:@"photo"];
            [likesQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                if (!error) {
                    if (objects != nil && objects.count > 0) {
                        NSLog(@"Logged in user has %d previous likes. Attempting to restore them locally.", objects.count);
                        for (PFObject * likeServer in objects) {
                            PFObject * photoServer = [likeServer objectForKey:@"photo"];
                            [self.coreDataManager addOrUpdateLikeFromServer:likeServer photoFromServer:photoServer userFromServer:user];
                        }
                        [self.coreDataManager saveCoreData];
                    }
                    self.waitingForLikes = NO;
                    [self attemptToProceedWithSuccessfulLogin];
                } else {
                    [self.connectionErrorGeneralAlertView show];
                    [PFUser logOut];
                }
            }];
            [PFPush subscribeToChannelInBackground:user.objectId block:^(BOOL succeeded, NSError * error){
                if (!error && succeeded) {
                    self.waitingToSubscribeToNotificationsChannel = NO;
                    [self attemptToProceedWithSuccessfulLogin];
                } else {
                    [self.connectionErrorGeneralAlertView show];
                    [PFUser logOut];
                }
            }];
        } else {
            // I *guess* this means that the password was incorrect... Not really fitting into their documentation, but oh well.
            [self.passwordIncorrectAlertView show];
        }
    } else {
        NSLog(@"%@", *error);
        NSLog(@"%d where kPFErrorObjectNotFound=%d", [*error code], kPFErrorObjectNotFound);
//        if ([*error code] == kPFErrorObjectNotFound) {
//            [self.passwordIncorrectAlertView show];
//        } else {
        [self.connectionErrorGeneralAlertView show];
//        }        
    }
}

- (void) attemptToProceedWithSuccessfulLogin {
    if (!(self.waitingForLikes || self.waitingToSubscribeToNotificationsChannel)) {
        [self.delegate accountViewController:self didFinishWithConnection:YES];
    } else {
        NSLog(@"waiting to proceed with successful login, self.waitingForLikes=%d, self.waitingToSubscribeToNotificationsChannel=%d", self.waitingForLikes, self.waitingToSubscribeToNotificationsChannel);
    }
}

- (void)accountCreationAttemptRequested {
    
    self.usernameTextField.text = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.emailTextField.text = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL nameEntered = self.usernameTextField.text.length > 0;
    BOOL emailEntered = self.emailTextField.text.length > 0;
    BOOL emailValid = emailEntered && self.emailTextField.text.isValidEmailAddress;
    BOOL passwordsEntered = self.passwordTextField.text.length > 0 && (!confirmPasswordVisible || self.confirmPasswordTextField.text.length > 0);
    BOOL passwordsMatch = passwordsEntered && (!confirmPasswordVisible || [self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]);
    
    if (!(nameEntered && emailEntered && emailValid && passwordsEntered && passwordsMatch)) {
        
        NSString * alertTitle = nil;
        NSString * alertMessage = nil;
        UITextField * nextFirstResponder = nil;
        if (!nameEntered) {
            // Missing Information
            // Enter your name, so that we'll know who to expect at events!
            // -> Make name (first or last) first responder
            alertTitle = @"Missing Information";
            alertMessage = @"Enter a username that you'd like to have displayed with your photos!";
            nextFirstResponder = self.usernameTextField;
        } else if (!emailValid) {
            // Invalid Email
            // You must enter a valid email address.
            // -> Make email first responder
            alertTitle = self.emailInvalidAlertView.title;
            alertMessage = self.emailInvalidAlertView.message;
            nextFirstResponder = self.emailTextField;
        } else if (!passwordsEntered) {
            // Missing Information
            // You must enter a password.
            // -> Make password first responder
            // Please confirm your password.
            // -> Make confirm password first responder
            alertTitle = @"Missing Information";
            if (self.passwordTextField.text.length == 0) {
                alertMessage = @"You must enter a password.";
                nextFirstResponder = self.passwordTextField;
            } else {
                alertMessage = @"Please confirm your password.";
                nextFirstResponder = self.confirmPasswordTextField;
            }
        } else if (!passwordsMatch) {
            // Password Unconfirmed
            // Your password confirmation does not match. Please try again.
            // -> Clear confirm password, make confirm password first responder.
            alertTitle = @"Password Unconfirmed";
            alertMessage = @"Your password confirmation does not match. Please try again.";
            nextFirstResponder = self.confirmPasswordTextField;
            self.confirmPasswordTextField.text = @"";
        }
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        if (nextFirstResponder == [self.inputContainer getFirstResponder]) {
            [self setTextFieldToBeVisible:nextFirstResponder animated:YES];
        } else {
            [nextFirstResponder becomeFirstResponder];
        }
        
    } else {
        
        [self resignFirstResponderForAllTextFields];
        NSLog(@"CREATE ACCOUNT VIA USERNAME WEB CALL SHOULD BE HERE");
        
        PFUser * userToSignUp = [PFUser user];
        userToSignUp.username = self.usernameInputString;
        userToSignUp.email = self.emailInputString;
        userToSignUp.password = self.passwordInputString;
        [userToSignUp setObject:self.usernameInputString.lowercaseString forKey:@"usernameLowercase"];
        [userToSignUp setObject:self.emailInputString.lowercaseString forKey:@"emailLowercase"];
        [userToSignUp signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error){
            if (!error) {
                // Hooray! Let them use the app now.
                PFUser * userSignedUp = [PFUser currentUser];
                [self.coreDataManager addOrUpdateUserFromServer:userSignedUp];
                [PFPush subscribeToChannelInBackground:userSignedUp.objectId];
                [self.delegate accountViewController:self didFinishWithConnection:YES];
            } else {
                NSLog(@"error: %@", error);
                if (error.code == kPFErrorUsernameTakenError) {
                    [self.anotherAccountWithUsernameExistsAlertView show];
                } else if (error.code == kPFErrorUserEmailTakenError) {
                    [self.anotherAccountWithEmailExistsAlertView show];
                } /*else if (error.code == kPFErrorInvalidEmailAddress) { // This is causing an Apple Mach-O Linker Error for some odd reason...
                    [self.emailInvalidAlertView show];
                } */else {
                    [self.connectionErrorGeneralAlertView show];
                }
            }
        }];
//        [self.webConnector accountCreateWithEmail:self.emailInputString password:self.passwordInputString username:self.usernameInputString];
        
    }
    
}

//- (void)webConnector:(WebConnector *)webConnector accountConnectSuccess:(ASIHTTPRequest *)request withEmail:(NSString *)emailString firstName:(NSString *)nameFirst lastName:(NSString *)nameLast apiKey:(NSString *)apiKey {
//        
//    NSLog(@"AccountPromptViewController accountConnectSuccess email=%@ first=%@ last=%@ apiKey=%@", emailString, nameFirst, nameLast, apiKey);
//    
//    [DefaultsModel saveAPIKey:apiKey];
//    NSString * identifierString = (nameFirst && nameFirst.length > 0) || (nameLast && nameLast.length > 0) ? [NSString stringWithFormat:@"%@%@%@", nameFirst, nameFirst != nil ? @" " : @"", nameLast] : emailString;
//    [DefaultsModel saveKwiqetUserIdentifierToUserDefaults:identifierString];
//
//    NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"login", @"action", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
//    
//    [self.delegate accountPromptViewController:self didFinishWithConnection:YES];
//    
//}
//
//- (void) webConnector:(WebConnector *)webConnector accountConnectFailure:(ASIHTTPRequest *)request failureCode:(WebConnectorFailure)failureCode withEmail:(NSString *)emailString {
//    
//    if (failureCode == AccountConnectPasswordIncorrect) {
//        [self.passwordIncorrectAlertView show];
//    } else if (failureCode == AccountConnectAccountDoesNotExist) {
//        [self showAccountCreationInputViews:YES showPasswordConfirmation:YES activateAppropriateFirstResponder:YES animated:YES];
//    } else {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry - there was a problem connecting with Kwiqet. Please check your connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//    }
//    
//}
//
//- (void)webConnector:(WebConnector *)webConnector accountCreateFailure:(ASIHTTPRequest *)request failureCode:(WebConnectorFailure)failureCode withEmail:(NSString *)emailString {
//        
//    if (failureCode == AccountCreateEmailAssociatedWithAnotherAccount) {
//        
//        [self.anotherAccountWithUsernameExistsAlertView show];
//        
//    } else if (failureCode == AccountCreateEmailNotValid) {
//        
//        [self.emailInvalidAlertView show];
//        [self.emailTextField becomeFirstResponder];
//        
//    } else {
//        
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry - there was a problem connecting with Kwiqet. Please check your connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        
//    }
//    
//}

- (void) showContainer:(UIView *)viewsContainer animated:(BOOL)animated {
    
    BOOL shouldShowInputViews = (viewsContainer == self.inputContainer);
    
//    void(^blurbPromptsAlphaBlock)(BOOL) = ^(BOOL shouldShowOptionsBlurb){
//        self.blurbLabel.alpha = shouldShowOptionsBlurb ? 1.0 : 0.0;
//        self.accountConnectionPromptLabel.alpha = shouldShowOptionsBlurb ? 0.0 : 1.0;
//        self.accountCreationPromptLabel.alpha = 0.0; // Sort of silly...
//    };
    
    void(^topBarBlock)(BOOL) = ^(BOOL shouldShowDone){
        self.topBar.buttonLeftNormal.alpha = 1.0;
        self.topBar.buttonRightNormal.alpha = shouldShowDone ? 1.0 : 0.0;
        [self.topBar setViewMode:(shouldShowDone ? BrandingCenter : BrandingRight) animated:NO];
    };
    
    void(^accountOptionsBlock)(BOOL) = ^(BOOL shouldShow){
        CGFloat alpha = shouldShow ? 1.0 : 0.0;
        self.accountOptionsContainer.alpha = alpha;
    };
    
    void(^emailOptionBlock)(BOOL) = ^(BOOL shouldShow){
        CGFloat alpha = shouldShow ? 1.0 : 0.0;
        self.inputContainer.alpha = alpha;
        CGRect inputContainerFrame = self.inputContainer.frame;
        inputContainerFrame.origin.x = shouldShow ? 0 : self.mainViewsContainer.frame.size.width;
        self.inputContainer.frame = inputContainerFrame;
    };
    
    void(^resetInputBlock)(void) = ^{
        self.usernameTextField.text = @"";
        self.emailTextField.text = @"";
        self.passwordTextField.text = @"";
        self.confirmPasswordTextField.text = @"";
    };

    initialPromptScreenVisible = !shouldShowInputViews;
//    self.cancelButton.userInteractionEnabled = YES;
//    self.doneButton.userInteractionEnabled = shouldShowInputViews;

    [UIView animateWithDuration:animated ? AP_NAV_BUTTONS_ANIMATION_DURATION : 0.0 delay:0.0 options:0 animations:^{
        accountOptionsBlock(!shouldShowInputViews);
        emailOptionBlock(shouldShowInputViews);
        topBarBlock(shouldShowInputViews);
//        blurbPromptsAlphaBlock(!shouldShowInputViews);
    } completion:^(BOOL finished) {
        if (!shouldShowInputViews) {
            resetInputBlock();
            [self showAccountCreationInputViews:NO showPasswordConfirmation:NO activateAppropriateFirstResponder:NO animated:NO];
        }
    }];
    if (!shouldShowInputViews) {
        [self resignFirstResponderForAllTextFields];
    }
    
}

- (void) resignFirstResponderForAllTextFields {
    [self.usernameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}

- (void) showAccountCreationInputViews:(BOOL)shouldShowCreationViews showPasswordConfirmation:(BOOL)shouldShowPasswordConfirmation activateAppropriateFirstResponder:(BOOL)shouldActivateFirstResponder animated:(BOOL)animated {
    
    shouldShowPasswordConfirmation &= shouldShowCreationViews;
    accountCreationViewsVisible = shouldShowCreationViews;
    confirmPasswordVisible = shouldShowPasswordConfirmation;    
    
    void(^prepBlock)(void) = ^{
        if (shouldShowCreationViews) {
            BOOL idInputIsEmail = self.usernameTextField.text.isValidEmailAddress;
            self.emailTextField.frame = self.usernameTextField.frame;
            self.confirmPasswordTextField.frame = self.passwordTextField.frame;
            self.confirmPasswordTextField.alpha = 0.0;
            if (idInputIsEmail) {
                self.emailTextField.text = self.usernameTextField.text;
                self.usernameTextField.text = @"";
                self.usernameTextField.alpha = 0.0;
                self.emailTextField.alpha = 1.0;
            } else {
                self.emailTextField.alpha = 0.0;
            }
        } else {
            // No prep necessary...
        }
    };
    
    void(^changesBlock)(void) = ^{
        
        self.accountConnectionPromptLabel.alpha = shouldShowCreationViews ? 0.0 : 1.0;
        self.accountCreationPromptLabel.alpha = shouldShowCreationViews ? 1.0 : 0.0;
        self.usernameTextField.placeholder = shouldShowCreationViews ? @"Username" : @"Username or Email Address";
        
        if (shouldShowCreationViews) {
            self.usernameTextField.alpha = 1.0;
            self.emailTextField.alpha = 1.0;
            self.confirmPasswordTextField.alpha = shouldShowPasswordConfirmation ? 1.0 : 0.0;
            self.emailTextField.frame = CGRectOffset(self.usernameTextField.frame, 0, self.usernameTextField.frame.size.height);
            self.passwordTextField.frame = CGRectOffset(self.emailTextField.frame, 0, self.emailTextField.frame.size.height);
            self.confirmPasswordTextField.frame = CGRectOffset(self.passwordTextField.frame, 0, self.passwordTextField.frame.size.height);
            self.passwordTextField.returnKeyType = shouldShowPasswordConfirmation ? UIReturnKeyNext : UIReturnKeySend; // If passwordTextField is first responder when this call is made, the returnKeyType does not get updated until another text field becomes first responder, and then this one becomes it once again. It does not help to quickly switch to another and come back right here, either. Strange bug.
        } else {
            self.emailTextField.alpha = 0.0;
            self.confirmPasswordTextField.alpha = 0.0;
            self.emailTextField.frame = self.usernameTextField.frame;
            self.passwordTextField.frame = CGRectOffset(self.emailTextField.frame, 0, self.emailTextField.frame.size.height);
            self.confirmPasswordTextField.frame = self.passwordTextField.frame;
        }
        
        self.emailAccountAssuranceLabel.alpha = shouldShowCreationViews ? 0.0 : 1.0;
        self.emailAccountAssuranceLabel.frame = CGRectMake(self.emailAccountAssuranceLabel.frame.origin.x, CGRectGetMaxY(self.confirmPasswordTextField.frame) + AVC_NO_ACCOUNT_ASSURANCE_LABEL_MARGIN_TOP, self.emailAccountAssuranceLabel.frame.size.width, self.emailAccountAssuranceLabel.frame.size.height);
        
        CGPoint pointMaxY = [self.inputContainer convertPoint:CGPointMake(0, MAX(CGRectGetMaxY(self.passwordTextField.frame), CGRectGetMaxY(self.confirmPasswordTextField.frame))) fromView:self.passwordTextField.superview];
        self.inputContainer.contentSize = CGSizeMake(self.inputContainer.frame.size.width, pointMaxY.y + AVC_INPUT_CONTAINER_PADDING_BOTTOM);
//        NSLog(@"self.inputContainer.contentSize = %@", NSStringFromCGSize(self.inputContainer.contentSize));
        
    };
    
    void(^firstResponderBlock)(void) = ^{
        if (shouldShowCreationViews) {
            NSArray * inputTextFields = [NSArray arrayWithObjects:self.usernameTextField, self.emailTextField, self.passwordTextField, self.confirmPasswordTextField, nil];
            for (UITextField * inputTextField in inputTextFields) {
                if (inputTextField.text.length == 0) {
                    [inputTextField becomeFirstResponder];
                    break;
                }
            }
        } else {
            if (self.usernameTextField.text.length == 0) {
                [self.usernameTextField becomeFirstResponder];
            } else {
                [self.passwordTextField becomeFirstResponder];
            }
            
        }
    };
    
    void(^resetCreationInputBlock)(void) = ^{
        self.emailTextField.text = @"";
        self.confirmPasswordTextField.text = @"";
    };
        
    prepBlock();
    [UIView animateWithDuration:animated ? AP_NAV_BUTTONS_ANIMATION_DURATION : 0.0
                          delay:0.0 
                        options:0 
                     animations:changesBlock
                     completion:^(BOOL finished){
                         if (!shouldShowCreationViews) {
                             resetCreationInputBlock();
                         }
                     }];
    if (shouldActivateFirstResponder) {
        firstResponderBlock();
    }
    
}

- (UIAlertView *) passwordIncorrectAlertView {
    if (_passwordIncorrectAlertView == nil) {
        _passwordIncorrectAlertView = [[UIAlertView alloc] initWithTitle:@"Wrong Password" message:@"Your password was incorrect. Please try again." delegate:self cancelButtonTitle:@"Forgot" otherButtonTitles:@"Try Again", nil];
        _passwordIncorrectAlertView.delegate = self;
    }
    return _passwordIncorrectAlertView;
}

- (UIAlertView *)emailInvalidAlertView {
    if (_emailInvalidAlertView == nil) {
        _emailInvalidAlertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"You must enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return _emailInvalidAlertView;
}

- (UIAlertView *) forgotPasswordConnectionErrorAlertView {
    if (_forgotPasswordConnectionErrorAlertView == nil) {
        _forgotPasswordConnectionErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Something went wrong while trying to reset your password. Check your connection and try again." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:@"OK", nil];
        _forgotPasswordConnectionErrorAlertView.delegate = self;
    }
    return _forgotPasswordConnectionErrorAlertView;
}

- (UIAlertView *) anotherAccountWithUsernameExistsAlertView {
    if (_anotherAccountWithUsernameExistsAlertView == nil) {
        _anotherAccountWithUsernameExistsAlertView = [[UIAlertView alloc] initWithTitle:@"Account with Username Exists" message:@"There is already an Emotish account associated with that username. Please try logging in with that username, or enter a different one." delegate:self cancelButtonTitle:@"Change Username" otherButtonTitles:@"Log In", nil];
        _anotherAccountWithUsernameExistsAlertView.delegate = self;
    }
    return _anotherAccountWithUsernameExistsAlertView;
}

- (UIAlertView *) anotherAccountWithEmailExistsAlertView {
    if (_anotherAccountWithEmailExistsAlertView == nil) {
        _anotherAccountWithEmailExistsAlertView = [[UIAlertView alloc] initWithTitle:@"Account with Email Exists" message:@"There is already an Emotish account associated with that email address. Please try logging in with that email, or enter a different one." delegate:self cancelButtonTitle:@"Change Email" otherButtonTitles:@"Log In", nil];
        _anotherAccountWithEmailExistsAlertView.delegate = self;
    }
    return _anotherAccountWithEmailExistsAlertView;
}

- (UIAlertView *) connectionErrorGeneralAlertView {
    if (_connectionErrorGeneralAlertView == nil) {
        _connectionErrorGeneralAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry - there was a problem connecting with Emotish. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return _connectionErrorGeneralAlertView;
}

- (void)swipedDown:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    if (swipeGestureRecognizer == self.swipeDownGestureRecognizer) {
        if (initialPromptScreenVisible) {
            [self.delegate accountViewController:self didFinishWithConnection:NO];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
//        NSLog(@"self.inputContainer.frame = %@", NSStringFromCGRect(self.inputContainer.frame));
//        NSLog(@"self.inputContainer.contentSize = %@", NSStringFromCGSize(self.inputContainer.contentSize));
//        NSLog(@"self.inputContainer.contentInset = %@", NSStringFromUIEdgeInsets(self.inputContainer.contentInset));
//        NSLog(@"keyboardSize = %@", NSStringFromCGSize(keyboardSize));
        UIEdgeInsets insetsForKeyboard = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        self.inputContainer.contentInset = insetsForKeyboard;
        self.inputContainer.scrollIndicatorInsets = insetsForKeyboard;
//        [self setBottomInset:self.mainViewsContainer.frame.origin.y + keyboardSize.height + 10 forScrollView:self.inputContainer];
        [self setTextFieldToBeVisible:(UITextField *)[self.inputContainer getFirstResponder] animated:NO];
    } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        self.inputContainer.contentInset = UIEdgeInsetsZero;
    } completion:NULL];
}

@end
