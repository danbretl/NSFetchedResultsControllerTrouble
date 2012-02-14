//
//  CameraOverlayView.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraOverlayView.h"
#import "UIColor+Emotish.h"
#import "ViewConstants.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat COV_TOP_BAR_PADDING_HORIZONTAL = 20.0;
const CGFloat COV_BOTTOM_BAR_PADDING_LEFT = 3.0;
const CGFloat COV_BOTTOM_BAR_PADDING_RIGHT = 5.0;
const CGFloat COV_FEELING_PROMPT_MARGIN_RIGHT = 6.0;

@interface CameraOverlayView()
@property (strong, nonatomic, readonly) NSString * feelingPlaceholderText;
@property (nonatomic) int feelingPromptIndex;
@property (strong, nonatomic, readonly) NSString * feelingPromptTextLong;
@property (strong, nonatomic, readonly) NSString * feelingPromptTextShort;
@property (strong, nonatomic, readonly) NSString * feelingPromptTextShortest;
@property (strong, nonatomic, readonly) NSArray * feelingPromptsLongestToShortest; // Array of NSStrings
@property (strong, nonatomic, readonly) NSArray * feelingPromptsWidthsLongestToShortest; // Array of NSNumbers
@property (strong, nonatomic) UILabel * feelingPromptLabel;
- (void) adjustFeelingPromptLabelForFeelingString:(NSString *)feelingString;
@end

@implementation CameraOverlayView

@synthesize topBar=_topBar, feelingTextField=_feelingTextField, feelingPromptLabel=_feelingPromptLabel;
@synthesize imageOverlay=_imageOverlay, swapCamerasButton=_swapCamerasButton;
@synthesize bottomBar=_bottomBar, cancelButton=_cancelButton, photoButton=_photoButton, libraryButton=_libraryButton, acceptButton=_acceptButton;
@synthesize feelingPromptsLongestToShortest=_feelingPromptsLongestToShortest, feelingPromptsWidthsLongestToShortest=_feelingPromptsWidthsLongestToShortest, feelingPromptIndex=_feelingPromptIndex;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        BOOL debugging = NO;
        
        CGFloat shadowOpacity = 0.5;
        CGFloat letterboxWhiteAmount = 0.2;
        
        self.topBar = [[TopBarView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CAMERA_OVERLAY_TOP_BAR_HEIGHT)];
        self.topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"top_bar_camera_view.png"]];
        self.topBar.buttonBranding.alpha = 0.0;
        [self addSubview:self.topBar];
        self.topBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBar.bounds].CGPath;
        self.topBar.layer.shadowOpacity = shadowOpacity;
        self.topBar.layer.shadowOffset = CGSizeMake(0, 0);

        self.feelingTextField = [[UITextField alloc] initWithFrame:CGRectMake(COV_TOP_BAR_PADDING_HORIZONTAL, 0, self.topBar.frame.size.width - 2 * COV_TOP_BAR_PADDING_HORIZONTAL, self.topBar.frame.size.height)];
//        self.feelingTextField.text = self.feelingPlaceholderText;
//        self.feelingTextField.textColor = [UIColor emotishColor];
        self.feelingTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.feelingTextField.adjustsFontSizeToFitWidth = NO;
        self.feelingTextField.font = [UIFont boldSystemFontOfSize:24.0];
        self.feelingTextField.textColor = [UIColor feelingColor];
        self.feelingTextField.returnKeyType = UIReturnKeyDone;
        self.feelingTextField.delegate = self;
        self.feelingTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.feelingTextField.leftViewMode = UITextFieldViewModeAlways;
        [self.topBar addSubview:self.feelingTextField];
        self.feelingPromptLabel = [[UILabel alloc] init];
        self.feelingPromptLabel.numberOfLines = 1;
        self.feelingPromptLabel.backgroundColor = [UIColor clearColor];
        self.feelingPromptLabel.textAlignment = UITextAlignmentLeft;
        self.feelingPromptLabel.lineBreakMode = UILineBreakModeClip;
        self.feelingPromptLabel.font = [UIFont boldSystemFontOfSize:24.0];
        self.feelingPromptLabel.textColor = [UIColor emotishColor];
        self.feelingPromptIndex = 0;
        self.feelingTextField.leftView = self.feelingPromptLabel;
        [self setFeelingText:self.feelingPlaceholderText];
        
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - CAMERA_OVERLAY_BOTTOM_BAR_HEIGHT, self.frame.size.width, CAMERA_OVERLAY_BOTTOM_BAR_HEIGHT)];
        self.bottomBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_bar_camera_view.png"]];
        [self addSubview:self.bottomBar];
        self.bottomBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bottomBar.bounds].CGPath;
        self.bottomBar.layer.shadowOpacity = shadowOpacity;
        self.bottomBar.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(COV_BOTTOM_BAR_PADDING_LEFT, 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.cancelButton.contentMode = UIViewContentModeCenter;
        [self.cancelButton setImage:[UIImage imageNamed:@"btn_camera_view_cancel.png"] forState:UIControlStateNormal];
        self.cancelButton.adjustsImageWhenHighlighted = NO;
        [self.bottomBar addSubview:self.cancelButton];
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake(floorf((self.bottomBar.frame.size.width - self.bottomBar.frame.size.height) / 2.0), 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.photoButton.contentMode = UIViewContentModeCenter;
        [self.photoButton setImage:[UIImage imageNamed:@"btn_camera_view_photo.png"] forState:UIControlStateNormal];
        self.photoButton.adjustsImageWhenHighlighted = NO;
        [self.bottomBar addSubview:self.photoButton];        
        
        self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.acceptButton.frame = CGRectMake(floorf((self.bottomBar.frame.size.width - self.bottomBar.frame.size.height) / 2.0), 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.acceptButton.contentMode = UIViewContentModeCenter;
        [self.acceptButton setImage:[UIImage imageNamed:@"btn_camera_view_accept.png"] forState:UIControlStateNormal];
        self.acceptButton.adjustsImageWhenHighlighted = NO;
        self.acceptButton.hidden = YES;
        [self.bottomBar addSubview:self.acceptButton];

        self.libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.libraryButton.frame = CGRectMake(self.bottomBar.frame.size.width - self.bottomBar.frame.size.height - COV_BOTTOM_BAR_PADDING_RIGHT, 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.libraryButton.contentMode = UIViewContentModeCenter;
        [self.libraryButton setImage:[UIImage imageNamed:@"btn_camera_view_library.png"] forState:UIControlStateNormal];
        [self.libraryButton setImage:[UIImage imageNamed:@"btn_camera_view_library_disabled.png"] forState:UIControlStateDisabled];
        self.libraryButton.adjustsImageWhenHighlighted = NO;
        [self.bottomBar addSubview:self.libraryButton];
        
        CGRect imageFrame = CGRectMake(0, CAMERA_VIEW_SCREEN_DISPLAY_ORIGIN_Y, CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH, CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH);
//        NSLog(@"imageFrame = %@", NSStringFromCGRect(imageFrame));
//        NSLog(@"floorf((CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0)");
//        NSLog(@"\nCGRectGetMinY(self.bottomBar.frame) = %f\nCGRectGetMaxY(self.topBar.frame) = %f\nCAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH = %f\n(CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) = %f\n(CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0 = %f\nfloorf((CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0) = %f", CGRectGetMinY(self.bottomBar.frame), CGRectGetMaxY(self.topBar.frame), CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH, (CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH), (CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0, floorf((CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0));
        
        UIView * imageLetterboxViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CGRectGetMinY(imageFrame))];
        imageLetterboxViewTop.backgroundColor = [UIColor colorWithWhite:letterboxWhiteAmount alpha:1.0];
        imageLetterboxViewTop.clipsToBounds = YES;
        [self insertSubview:imageLetterboxViewTop belowSubview:self.topBar];
        UIView * imageLetterboxViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageFrame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(imageFrame))];
        imageLetterboxViewBottom.backgroundColor = [UIColor colorWithWhite:letterboxWhiteAmount alpha:1.0];
        imageLetterboxViewBottom.clipsToBounds = YES;
        [self insertSubview:imageLetterboxViewBottom belowSubview:self.bottomBar];
        
        UIView * imageShadowViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, imageLetterboxViewTop.bounds.size.height, imageLetterboxViewTop.bounds.size.width, 20.0)];
        imageShadowViewTop.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageShadowViewTop.bounds].CGPath;
        imageShadowViewTop.layer.shadowOpacity = shadowOpacity;
        imageShadowViewTop.layer.shadowOffset = CGSizeMake(0, 0);
        imageShadowViewTop.backgroundColor = [UIColor blackColor];
        [imageLetterboxViewTop addSubview:imageShadowViewTop];
        UIView * imageShadowViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, -20.0, imageLetterboxViewBottom.bounds.size.width, 20.0)];
        imageShadowViewBottom.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageShadowViewBottom.bounds].CGPath;
        imageShadowViewBottom.layer.shadowOpacity = shadowOpacity;
        imageShadowViewBottom.layer.shadowOffset = CGSizeMake(0, 0);
        imageShadowViewBottom.backgroundColor = [UIColor blackColor];
        [imageLetterboxViewBottom addSubview:imageShadowViewBottom];
        
        self.imageOverlay = [[UIImageView alloc] initWithFrame:imageFrame];// CGRectMake(0, 0, CAMERA_VIEW_SCREEN_WIDTH, CAMERA_VIEW_SCREEN_HEIGHT)];
        self.imageOverlay.contentMode = UIViewContentModeScaleAspectFill;
        self.imageOverlay.hidden = YES;
        self.imageOverlay.userInteractionEnabled = NO;
        [self insertSubview:self.imageOverlay belowSubview:imageLetterboxViewTop];
        
        self.swapCamerasButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat swapCamerasButtonWidth = 50.0;
        self.swapCamerasButton.frame = CGRectMake(CGRectGetMaxX(imageFrame) - swapCamerasButtonWidth, CGRectGetMinY(imageFrame), swapCamerasButtonWidth, swapCamerasButtonWidth);
        [self.swapCamerasButton setTitle:@"Swap" forState:UIControlStateNormal];
        [self.swapCamerasButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.swapCamerasButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.swapCamerasButton.backgroundColor = [UIColor colorWithWhite:0.75 alpha:0.40];
        [self insertSubview:self.swapCamerasButton belowSubview:self.imageOverlay];
        
        
        if (debugging) {
            self.topBar.backgroundColor = [UIColor greenColor];
            self.feelingTextField.backgroundColor = [UIColor blueColor];
            self.bottomBar.backgroundColor = [UIColor greenColor];
            self.cancelButton.backgroundColor = [UIColor blueColor];
            self.photoButton.backgroundColor = [UIColor blueColor];
            self.acceptButton.backgroundColor = [UIColor blueColor];
            self.libraryButton.backgroundColor = [UIColor blueColor];
        }
        
    }
    return self;
}

//+ (CGRect) imageCropFrame {
////    CGSize hardCodedScreenSize = [UIScreen mainScreen].bounds.size;
////    CGFloat hardCodedBottomBarHeight = 54.0;
////    CGFloat minScreenSideLength = MIN(hardCodedScreenSize.width, hardCodedScreenSize.height);
////    CGSize imageSize = CGSizeMake(minScreenSideLength, minScreenSideLength);
//    return CGRectMake(0, CAMERA_OVERLAY_TOP_BAR_HEIGHT, CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH, CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH);
////    return CGRectMake(0, hardCodedScreenSize.height - imageSize.height - hardCodedBottomBarHeight, imageSize.width, imageSize.height);
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.feelingTextField) {
        shouldReturn = NO;
        [textField resignFirstResponder];
    }
    return shouldReturn;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:self.feelingPlaceholderText]) {
        textField.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        textField.text = self.feelingPlaceholderText;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self adjustFeelingPromptLabelForFeelingString:[textField.text stringByReplacingCharactersInRange:range withString:string]];    
//    NSLog(@"stringWillBeSize = %@", NSStringFromCGSize(stringWillBeSize));
//    NSLog(@"textFieldSize = %@", NSStringFromCGSize(textField.frame.size));
//    NSLog(@"promptSize = %@", NSStringFromCGSize(textField.leftView.frame.size));
//    NSLog(@"stringWillBeSize = %@", NSStringFromCGSize(stringWillBeSize));
//    NSLog(@"textField.text = %@", textField.text);
//    NSLog(@"range = %@", NSStringFromRange(range));
//    NSLog(@"replacementString = %@", string);
    return YES;
}

- (void) adjustFeelingPromptLabelForFeelingString:(NSString *)feelingString {
    CGSize feelingStringSize = [feelingString sizeWithFont:self.feelingTextField.font constrainedToSize:self.feelingTextField.frame.size];
    CGFloat feelingPromptAvailableWidth = self.feelingTextField.frame.size.width - feelingStringSize.width;
    for (int i=0; i<self.feelingPromptsWidthsLongestToShortest.count; i++) {
        CGFloat feelingPromptWidth = [[self.feelingPromptsWidthsLongestToShortest objectAtIndex:i] intValue];
        if (feelingPromptWidth + COV_FEELING_PROMPT_MARGIN_RIGHT <= feelingPromptAvailableWidth) {
            self.feelingPromptLabel.text = [self.feelingPromptsLongestToShortest objectAtIndex:i];
            self.feelingPromptLabel.frame = CGRectMake(0, 0, feelingPromptWidth + COV_FEELING_PROMPT_MARGIN_RIGHT, self.feelingTextField.frame.size.height);
            break;
        }
    }
}

- (NSString *)feelingPlaceholderText { return @"something"; }
- (NSString *)feelingPromptTextShortest { return @""; }
- (NSString *)feelingPromptTextShort    { return @"I'm"; }
- (NSString *)feelingPromptTextLong     { return @"I'm feeling"; }
- (NSArray *)feelingPromptsLongestToShortest {
    if (_feelingPromptsLongestToShortest == nil) {
        _feelingPromptsLongestToShortest = [NSArray arrayWithObjects:self.feelingPromptTextLong, self.feelingPromptTextShort, self.feelingPromptTextShortest, nil];
    }
    return _feelingPromptsLongestToShortest;
}
- (NSArray *)feelingPromptsWidthsLongestToShortest {
    if (_feelingPromptsWidthsLongestToShortest == nil) {
        NSMutableArray * widths = [NSMutableArray array];
        for (NSString * feelingPrompt in self.feelingPromptsLongestToShortest) {
            [widths addObject:[NSNumber numberWithFloat:[feelingPrompt sizeWithFont:self.feelingPromptLabel.font].width]];
        }
        _feelingPromptsWidthsLongestToShortest = widths;
    }
    return _feelingPromptsWidthsLongestToShortest;
}

- (void)setFeelingText:(NSString *)feelingText {
    self.feelingTextField.text = feelingText;
    [self adjustFeelingPromptLabelForFeelingString:feelingText];
}

@end
