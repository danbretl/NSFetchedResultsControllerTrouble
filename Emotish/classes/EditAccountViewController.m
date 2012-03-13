//
//  EditAccountViewController.m
//  Emotish
//
//  Created by Dan Bretl on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditAccountViewController.h"
#import "User.h"
#import <Parse/Parse.h>
#import "UIColor+Emotish.h"
#import "UIView+GetFirstResponder.h"
#import "NSString+EmailValidity.h"
#import "EmotishAlertViews.h"

NSString * const EDIT_ACCOUNT_PASSWORD_PLACEHOLDER = @"••••••••";

@interface EditAccountViewController ()

@property (nonatomic, strong, readonly) UIAlertView * cancelModifiedDataAlertView;

@property (nonatomic, strong) NSString * usernameEdited;
@property (nonatomic, strong) NSString * emailEdited;
@property (nonatomic, strong) NSString * passwordEdited;
@property (nonatomic, strong) NSArray * inputLabels;
@property (nonatomic, strong) NSArray * inputTextFields;
- (void) cancelButtonTouched:(UIButton *)button;
- (void) doneButtonTouched:(UIButton *)button;
- (void)processInputForTextField:(UITextField *)textField;
- (void)doneInputting;
- (BOOL)isCurrentDataModifiedFromOriginal;

- (void)setInputEditedForInputType:(EditAccountInputType)inputType withInput:(NSString *)inputString;
- (NSString *)getInputEditedForInputType:(EditAccountInputType)inputType;
- (NSString *)userServerKeyForEditAccountInputType:(EditAccountInputType)inputType;
- (NSString *)originalDataForInputType:(EditAccountInputType)inputType fromUserServer:(PFUser *)userServer;

@end

@implementation EditAccountViewController
@synthesize topBar = _topBar;
@synthesize headerLabel = _headerLabel;
@synthesize inputLabels=_inputLabels, usernameLabel = _usernameLabel, emailLabel = _emailLabel, passwordLabel = _passwordLabel;
@synthesize inputTextFields=_inputTextFields, usernameTextField=_usernameTextField, emailTextField=_emailTextField, passwordTextField=_passwordTextField;
@synthesize coreDataManager=_coreDataManager;
@synthesize usernameEdited=_usernameEdited, emailEdited=_emailEdited, passwordEdited=_passwordEdited;
@synthesize cancelModifiedDataAlertView=_cancelModifiedDataAlertView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.topBar setViewMode:BrandingCenter animated:NO];
    [self.topBar showButtonType:CancelButton inPosition:LeftNormal animated:NO];
    [self.topBar showButtonType:DoneButton inPosition:RightNormal animated:NO];
    [self.topBar.buttonLeftNormal addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar.buttonRightNormal addTarget:self action:@selector(doneButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.headerLabel.textColor = [UIColor userColor];
    
    self.inputLabels = [NSArray arrayWithObjects:self.usernameLabel, self.emailLabel, self.passwordLabel, nil];
    self.usernameLabel.tag = EditAccountUsername;
    self.emailLabel.tag = EditAccountEmail;
    self.passwordLabel.tag = EditAccountPassword;
    for (UILabel * inputLabel in self.inputLabels) {
        inputLabel.textColor = [UIColor emotishColor];
    }
    
    self.inputTextFields = [NSArray arrayWithObjects:self.usernameTextField, self.emailTextField, self.passwordTextField, nil];
    self.usernameTextField.tag = EditAccountUsername;
    self.emailTextField.tag = EditAccountEmail;
    self.passwordTextField.tag = EditAccountPassword;
    for (UITextFieldWithInsetAndUnderline * inputTextField in self.inputTextFields) {
        inputTextField.backgroundColor = [UIColor whiteColor];
        inputTextField.textColor = [UIColor accountInputColor];
        inputTextField.textFieldInsets = UIEdgeInsetsMake(0, 0, 4.0, 0);
        inputTextField.returnKeyType = [self.inputTextFields lastObject] == inputTextField ? UIReturnKeyDone : UIReturnKeyNext;
    }
    
}

- (void)viewDidUnload
{
    [self setUsernameTextField:nil];
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setInputTextFields:nil];
    [self setTopBar:nil];
    [self setHeaderLabel:nil];
    [self setUsernameLabel:nil];
    [self setEmailLabel:nil];
    [self setPasswordLabel:nil];
    [self setInputLabels:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self resetToUserServer:[PFUser currentUser]];
}

- (void)resetToUserServer:(PFUser *)userServer {
    [self setInputEditedForInputType:EditAccountUsername withInput:[self originalDataForInputType:EditAccountUsername fromUserServer:userServer]];
    [self setInputEditedForInputType:EditAccountEmail withInput:[self originalDataForInputType:EditAccountEmail fromUserServer:userServer]];
    [self setInputEditedForInputType:EditAccountPassword withInput:[self originalDataForInputType:EditAccountPassword fromUserServer:userServer]];
    [self updateTextFieldsForDataCurrent];
}

- (void)updateTextFieldsForDataCurrent {
    for (UITextField * inputTextField in self.inputTextFields) {
        inputTextField.text = [self getInputEditedForInputType:inputTextField.tag];
    }
}

- (void)cancelButtonTouched:(UIButton *)button {
    
    if ([self isCurrentDataModifiedFromOriginal]) {
        [self.cancelModifiedDataAlertView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.cancelModifiedDataAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self doneInputting];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)doneButtonTouched:(UIButton *)button {
    [self doneInputting];
}

- (void)doneInputting {
    
    // Accept any lingering input
    UITextField * inputTextFieldFirstResponder = (UITextField *)[self.view getFirstResponder];
    [self processInputForTextField:inputTextFieldFirstResponder];

    // Check all the input...
    if (!self.emailTextField.text.isValidEmailAddress) {
        [[EmotishAlertViews emailInvalidAlertView] show];
        [self.emailTextField becomeFirstResponder];
    } else {
        
        if ([self isCurrentDataModifiedFromOriginal]) {
            
            NSMutableDictionary * originalUserValues = [NSMutableDictionary dictionary];
            
            // Update the userServer object
            for (UITextField * inputTextField in self.inputTextFields) {
                EditAccountInputType inputType = inputTextField.tag;
                NSString * inputEdited = [self getInputEditedForInputType:inputTextField.tag];
                NSString * originalData = [self originalDataForInputType:inputType fromUserServer:[PFUser currentUser]];
                NSString * userServerKey = [self userServerKeyForEditAccountInputType:inputType];
                if (![inputEdited isEqualToString:originalData]) {
                    if (inputType != EditAccountPassword) {
                        [originalUserValues setObject:originalData forKey:userServerKey];
                        [[PFUser currentUser] setObject:inputEdited forKey:userServerKey];
                        // vvv HARDCODED HACK. UGH. vvv
                        if (inputType == EditAccountUsername ||
                            inputType == EditAccountEmail) {
                            NSString * originalDataLowercase = originalData.lowercaseString;
                            NSString * userServerKeyLowercase = [userServerKey stringByAppendingString:@"Lowercase"];
                            [originalUserValues setObject:originalDataLowercase forKey:userServerKeyLowercase];
                            [[PFUser currentUser] setObject:inputEdited.lowercaseString forKey:userServerKeyLowercase];
                        }
                        // ^^^ HARDCODED HACK. UGH. ^^^
                    } else {
                        ((PFUser *)[PFUser currentUser]).password = inputEdited;
                    }
                    
                }
            }
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error && succeeded) {
                    [self.coreDataManager addOrUpdateUserFromServer:[PFUser currentUser]];
                    [self.coreDataManager saveCoreData];
                    [[EmotishAlertViews userEditedAlertView] show];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    if (error.code == kPFErrorUsernameTakenError) {
                        [[EmotishAlertViews anotherAccountWithUsernameExistsDeadEndAlertView] show];
                        [self.usernameTextField becomeFirstResponder];
                    } else if (error.code == kPFErrorUserEmailTakenError) {
                        [[EmotishAlertViews anotherAccountWithEmailExistsDeadEndAlertView] show];
                        [self.emailTextField becomeFirstResponder];
                    } else if (error.code == kPFErrorInvalidEmailAddress) {
                        [[EmotishAlertViews emailInvalidAlertView] show];
                        [self.emailTextField becomeFirstResponder];
                    } else {
                        [[EmotishAlertViews generalConnectionErrorAlertView] show];
                    }
                    for (NSString * userServerKey in originalUserValues) {
                        [[PFUser currentUser] setValuesForKeysWithDictionary:originalUserValues];
                    }
                }
            }];
            
        } else {
            // The user didn't change anything. Simply pop the view controller.
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }

}

- (BOOL) isCurrentDataModifiedFromOriginal {
    BOOL inputChanged = NO;
    for (UITextField * inputTextField in self.inputTextFields) {
        EditAccountInputType inputType = inputTextField.tag;
        NSString * inputEdited = [self getInputEditedForInputType:inputTextField.tag];
        inputChanged = ![inputEdited isEqualToString:[self originalDataForInputType:inputType fromUserServer:[PFUser currentUser]]];
        if (inputChanged) {
            break;
        }
    }
    return inputChanged;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChange = YES;
    if (textField.tag == EditAccountPassword && 
        [textField.text isEqualToString:EDIT_ACCOUNT_PASSWORD_PLACEHOLDER]) {
        textField.text = string;
        shouldChange = NO;
    }
    return shouldChange;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.textColor = [UIColor userColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == [self.inputTextFields lastObject]) {
        [self doneInputting];
    } else {
        [[self.inputTextFields objectAtIndex:[self.inputTextFields indexOfObject:textField] + 1] becomeFirstResponder];
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self processInputForTextField:textField];
    textField.textColor = [textField.text isEqualToString:[self originalDataForInputType:textField.tag fromUserServer:[PFUser currentUser]]] ? [UIColor accountInputColor] : [UIColor userColor];
}

- (void)processInputForTextField:(UITextField *)textField {
    if (textField != nil) {
        if (textField.text.length == 0) {
            textField.text = [self originalDataForInputType:textField.tag fromUserServer:[PFUser currentUser]];
        }
        [self setInputEditedForInputType:textField.tag withInput:textField.text];
    }
}

- (NSString *)originalDataForInputType:(EditAccountInputType)inputType fromUserServer:(PFUser *)userServer {
    NSString * originalString = nil;
    if (inputType == EditAccountPassword) {
        originalString = EDIT_ACCOUNT_PASSWORD_PLACEHOLDER;
    } else {
        originalString = [userServer objectForKey:[self userServerKeyForEditAccountInputType:inputType]];
    }
    return originalString;
}

- (void)setInputEditedForInputType:(EditAccountInputType)inputType withInput:(NSString *)inputString {
    switch (inputType) {
        case EditAccountUsername: self.usernameEdited = inputString; break;
        case EditAccountEmail:    self.emailEdited = inputString;    break;
        case EditAccountPassword: self.passwordEdited = inputString; break;            
        default: break;
    }
}

- (NSString *)getInputEditedForInputType:(EditAccountInputType)inputType {
    NSString * inputEdited = nil;
    switch (inputType) {
        case EditAccountUsername: inputEdited = self.usernameEdited; break;
        case EditAccountEmail:    inputEdited = self.emailEdited;    break;
        case EditAccountPassword: inputEdited = self.passwordEdited; break;            
        default: break;
    }
    return inputEdited;
}
     
- (NSString *)userServerKeyForEditAccountInputType:(EditAccountInputType)inputType {
    NSString * userServerKey = nil;
    switch (inputType) {
        case EditAccountUsername: userServerKey = @"username"; break;
        case EditAccountEmail:    userServerKey = @"email";    break;
        case EditAccountPassword: userServerKey = @"password"; break;
        default: break;
    }
    return userServerKey;
}

- (UIAlertView *) cancelModifiedDataAlertView {
    if (_cancelModifiedDataAlertView == nil) {
        _cancelModifiedDataAlertView = [[UIAlertView alloc] initWithTitle:@"Unsaved Changes" message:@"Are you sure you want to discard the changes to your account below?" delegate:self cancelButtonTitle:@"Save Changes" otherButtonTitles:@"Discard", nil];
        _cancelModifiedDataAlertView.delegate = self;
    }
    return _cancelModifiedDataAlertView;
}

@end
