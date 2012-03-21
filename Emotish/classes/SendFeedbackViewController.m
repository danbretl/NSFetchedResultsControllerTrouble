//
//  SendFeedbackViewController.m
//  Emotish
//
//  Created by Dan Bretl on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendFeedbackViewController.h"
#import "UIColor+Emotish.h"
#import <Parse/Parse.h>

NSString * const SEND_FEEDBACK_PLACEHOLDER_TEXT = @"something not working?\nthink something could be better?\nabsolutely love something?\nlet us know!";
const CGFloat SEND_FEEDBACK_VIEW_PADDING_BOTTOM = 20.0;

@interface SendFeedbackViewController ()
- (void) backButtonTouched:(UIButton *)button;
- (void) doneButtonTouched:(UIButton *)button;
@property (nonatomic, strong) NSString * message;
- (void)submitMessage:(NSString *)message;
@property (nonatomic, strong, readonly) UIAlertView * cancelDiscardMessageAlertView;
@property (nonatomic, strong, readonly) UIAlertView * permissionToContactAlertView;
- (BOOL)isMessageInput:(NSString *)message;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@end

@implementation SendFeedbackViewController
@synthesize textViewContainer = _textViewContainer;
@synthesize topBar=_topBar, headerLabel=_headerLabel, textView=_textView;
@synthesize cancelDiscardMessageAlertView=_cancelDiscardMessageAlertView, permissionToContactAlertView=_permissionToContactAlertView;
@synthesize message=_message;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.message = SEND_FEEDBACK_PLACEHOLDER_TEXT;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.topBar setViewMode:BrandingCenter animated:NO];
    [self.topBar showButtonType:BackButton inPosition:LeftNormal animated:NO];
    [self.topBar showButtonType:DoneButton inPosition:RightNormal animated:NO];
    [self.topBar.buttonLeftNormal addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar.buttonRightNormal addTarget:self action:@selector(doneButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.headerLabel.textColor = [UIColor lightEmotishColor];

    self.textViewContainer.layer.cornerRadius = 10.0;
    self.textViewContainer.layer.borderWidth = 1.0;
    self.textViewContainer.layer.borderColor = [UIColor colorWithRed:207.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;

    self.textView.textColor = [UIColor accountInputColor];
    self.textView.text = self.message;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidUnload
{
    [self setHeaderLabel:nil];
    [self setTextView:nil];
    [self setTopBar:nil];
    [self setTextViewContainer:nil];
    [super viewDidUnload];
}

- (BOOL)isMessageInput:(NSString *)message {
    return message.length > 0 && ![message isEqualToString:SEND_FEEDBACK_PLACEHOLDER_TEXT]; 
}

- (void)backButtonTouched:(UIButton *)button {
    [self.textView resignFirstResponder];
    if ([self isMessageInput:self.message]) {
        [self.cancelDiscardMessageAlertView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonTouched:(UIButton *)button {
    [self.textView resignFirstResponder];
    [self submitMessage:self.message];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (![self isMessageInput:textView.text]) {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([textView.text isEqualToString:@""]) {
        textView.text = SEND_FEEDBACK_PLACEHOLDER_TEXT;
    }
    self.message = textView.text;
}

- (void)submitMessage:(NSString *)message {
    if (![self isMessageInput:message]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.message = message;
        [self.permissionToContactAlertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.cancelDiscardMessageAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self submitMessage:self.message];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (alertView == self.permissionToContactAlertView) {
        
        BOOL permissionToContact = buttonIndex != alertView.cancelButtonIndex;
        
        PFObject * feedbackServer = [PFObject objectWithClassName:@"Feedback"];
        [feedbackServer setObject:[PFUser currentUser] forKey:@"user"];
        [feedbackServer setObject:self.message forKey:@"message"];
        [feedbackServer setObject:[NSNumber numberWithBool:permissionToContact] forKey:@"permissionToContact"];
        [feedbackServer saveEventually];
        
        NSString * thanksMessage = @"Thanks for the feedback!";
        UIAlertView * thanksAlertView = [[UIAlertView alloc] initWithTitle:@"Message Received" message:thanksMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [thanksAlertView show];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (UIAlertView *) cancelDiscardMessageAlertView {
    if (_cancelDiscardMessageAlertView == nil) {
        _cancelDiscardMessageAlertView = [[UIAlertView alloc] initWithTitle:@"Unsent Message" message:@"Are you sure you want to discard your message?" delegate:self cancelButtonTitle:@"Send" otherButtonTitles:@"Discard", nil];
        _cancelDiscardMessageAlertView.delegate = self;
    }
    return _cancelDiscardMessageAlertView;
}

- (UIAlertView *) permissionToContactAlertView {
    if (_permissionToContactAlertView == nil) {
        _permissionToContactAlertView = [[UIAlertView alloc] initWithTitle:@"Up for a Chat?" message:@"Would it be OK if we followed up with you about this feedback?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Sure", nil];
        _permissionToContactAlertView.delegate = self;
    }
    return _permissionToContactAlertView;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        CGRect textViewContainerFrame = self.textViewContainer.frame;
        textViewContainerFrame.size.height = self.view.frame.size.height - SEND_FEEDBACK_VIEW_PADDING_BOTTOM - keyboardSize.height - textViewContainerFrame.origin.y;
        self.textViewContainer.frame = textViewContainerFrame;
    } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboardWillHide");
    NSDictionary * info = [notification userInfo];
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        CGRect textViewContainerFrame = self.textViewContainer.frame;
        textViewContainerFrame.size.height = self.view.frame.size.height - SEND_FEEDBACK_VIEW_PADDING_BOTTOM - textViewContainerFrame.origin.y;
        self.textViewContainer.frame = textViewContainerFrame;
    } completion:NULL];
}

@end
