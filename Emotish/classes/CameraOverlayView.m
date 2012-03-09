//
//  CameraOverlayView.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraOverlayView.h"
#import "SubmitPhotoShared.h"
#import "UIColor+Emotish.h"
#import "ViewConstants.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat COV_BOTTOM_BAR_PADDING_LEFT = 3.0;
const CGFloat COV_BOTTOM_BAR_PADDING_RIGHT = 5.0;
const CGFloat COV_FEELING_PROMPT_MARGIN_RIGHT = 6.0;
const CGFloat COV_SWAP_CAMERAS_BUTTON_SIDE_LENGTH = 50.0;
const CGFloat COV_SWAP_CAMERAS_BUTTON_MARGIN_RIGHT = 10.0;
const CGFloat COV_CAMERA_BUTTON_WIDTH = 100.0;


@interface CameraOverlayView()
@property (nonatomic) int feelingPromptIndex;
@property (strong, nonatomic, readonly) NSString * feelingPromptTextLong;
@property (strong, nonatomic, readonly) NSString * feelingPromptTextShort;
@property (strong, nonatomic, readonly) NSString * feelingPromptTextShortest;
@property (strong, nonatomic, readonly) NSArray * feelingPromptsLongestToShortest; // Array of NSStrings
@property (strong, nonatomic, readonly) NSArray * feelingPromptsWidthsLongestToShortest; // Array of NSNumbers
@property (strong, nonatomic) UILabel * feelingPromptLabel;
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
        
        self.topBar = [[TopBarView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CAMERA_OVERLAY_TOP_BAR_HEIGHT)];
        self.topBar.backgroundView.image = [UIImage imageNamed:@"top_bar_camera_view.png"];
        self.topBar.buttonBranding.hidden = YES;
        self.topBar.backgroundFlagView.hidden = YES;
        [self addSubview:self.topBar];
//        self.topBar.clipsToBounds = NO;
//        self.topBar.backgroundView.clipsToBounds = NO;
        // The shadow seems to be included in the image, but I can't see it in the app. Going to keep drawing the shadow in code for now.
        self.topBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBar.bounds].CGPath;
        self.topBar.layer.shadowOpacity = shadowOpacity;
        self.topBar.layer.shadowOffset = CGSizeMake(0, 0);

        self.feelingTextField = [[UITextField alloc] initWithFrame:CGRectMake(CAMERA_VIEW_TOP_BAR_PADDING_HORIZONTAL, 0, self.topBar.frame.size.width - 2 * CAMERA_VIEW_TOP_BAR_PADDING_HORIZONTAL, self.topBar.frame.size.height)];
        self.feelingTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.feelingTextField.adjustsFontSizeToFitWidth = NO;
        self.feelingTextField.font = [UIFont boldSystemFontOfSize:24.0];
        self.feelingTextField.textColor = [UIColor feelingColor];
        self.feelingTextField.returnKeyType = UIReturnKeyDone;
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
        [self setFeelingText:SUBMIT_PHOTO_FEELING_PLACEHOLDER_TEXT];
        
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - CAMERA_OVERLAY_BOTTOM_BAR_HEIGHT, self.frame.size.width, CAMERA_OVERLAY_BOTTOM_BAR_HEIGHT)];
        self.bottomBar.contentMode = UIViewContentModeBottomLeft;
        UIImageView * bottomBarBackgroundImageView = [[UIImageView alloc] initWithFrame:self.bottomBar.bounds];
        bottomBarBackgroundImageView.contentMode = UIViewContentModeBottom;
        bottomBarBackgroundImageView.image = [UIImage imageNamed:@"bottom_bar_camera_view.png"];
        [self.bottomBar addSubview:bottomBarBackgroundImageView];
        [self insertSubview:self.bottomBar belowSubview:self.topBar];
        self.bottomBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bottomBar.bounds].CGPath;
        // The shadow seems to be included in the image, but I can't see it in the app. Going to keep drawing the shadow in code for now.
        self.bottomBar.layer.shadowOpacity = shadowOpacity;
        self.bottomBar.layer.shadowOffset = CGSizeMake(0, 0);
//        self.bottomBar.clipsToBounds = NO;
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(COV_BOTTOM_BAR_PADDING_LEFT, 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.cancelButton.contentMode = UIViewContentModeCenter;
        [self.cancelButton setImage:[UIImage imageNamed:@"icon_camera_view_cancel.png"] forState:UIControlStateNormal];
        [self.cancelButton setImage:[UIImage imageNamed:@"icon_camera_view_cancel_touch.png"] forState:UIControlStateHighlighted];
        [self.bottomBar addSubview:self.cancelButton];
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake(floorf((self.bottomBar.frame.size.width - COV_CAMERA_BUTTON_WIDTH) / 2.0), 0, COV_CAMERA_BUTTON_WIDTH, self.bottomBar.frame.size.height);
        self.photoButton.imageView.contentMode = UIViewContentModeCenter;
        self.photoButton.contentMode = UIViewContentModeCenter;
        [self.photoButton setImage:[UIImage imageNamed:@"icon_camera_view_camera_glow.png"] forState:UIControlStateNormal];
        [self.photoButton setImage:[UIImage imageNamed:@"icon_camera_view_camera_glow_touch.png"] forState:UIControlStateHighlighted];
//        self.photoButton.clipsToBounds = NO;
//        self.photoButton.imageView.clipsToBounds = NO;
        [self.bottomBar addSubview:self.photoButton];        
        
        self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.acceptButton.frame = self.photoButton.frame;
        self.acceptButton.contentMode = UIViewContentModeCenter;
        [self.acceptButton setImage:[UIImage imageNamed:@"icon_camera_view_done.png"] forState:UIControlStateNormal];
        [self.acceptButton setImage:[UIImage imageNamed:@"icon_camera_view_done_touch.png"] forState:UIControlStateHighlighted];
        self.acceptButton.hidden = YES;
        [self.bottomBar addSubview:self.acceptButton];

        self.libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.libraryButton.frame = CGRectMake(self.bottomBar.frame.size.width - self.bottomBar.frame.size.height - COV_BOTTOM_BAR_PADDING_RIGHT, 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.libraryButton.contentMode = UIViewContentModeCenter;
        [self.libraryButton setImage:[UIImage imageNamed:@"icon_camera_view_library.png"] forState:UIControlStateNormal];
        [self.libraryButton setImage:[UIImage imageNamed:@"icon_camera_view_library_touch.png"] forState:UIControlStateHighlighted];
        [self.bottomBar addSubview:self.libraryButton];
        
        CGRect imageFrame = CGRectMake(0, CAMERA_VIEW_SCREEN_DISPLAY_ORIGIN_Y, CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH, CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH);
//        NSLog(@"imageFrame = %@", NSStringFromCGRect(imageFrame));
//        NSLog(@"floorf((CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0)");
//        NSLog(@"\nCGRectGetMinY(self.bottomBar.frame) = %f\nCGRectGetMaxY(self.topBar.frame) = %f\nCAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH = %f\n(CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) = %f\n(CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0 = %f\nfloorf((CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0) = %f", CGRectGetMinY(self.bottomBar.frame), CGRectGetMaxY(self.topBar.frame), CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH, (CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH), (CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0, floorf((CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame) - CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH) / 2.0));
        
        UIColor * letterboxBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_blue_compressed.png"]];
        UIView * imageLetterboxViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CGRectGetMinY(imageFrame))];
        imageLetterboxViewTop.backgroundColor = letterboxBackgroundColor;
        imageLetterboxViewTop.contentMode = UIViewContentModeTop;
        imageLetterboxViewTop.clipsToBounds = YES;
        [self insertSubview:imageLetterboxViewTop belowSubview:self.topBar];
        UIView * imageLetterboxViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageFrame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(imageFrame))];
        imageLetterboxViewBottom.backgroundColor = letterboxBackgroundColor;
        imageLetterboxViewBottom.contentMode = UIViewContentModeBottom;
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
        self.swapCamerasButton.frame = CGRectMake(CGRectGetMaxX(imageFrame) - COV_SWAP_CAMERAS_BUTTON_SIDE_LENGTH - COV_SWAP_CAMERAS_BUTTON_MARGIN_RIGHT, CGRectGetMinY(imageFrame), COV_SWAP_CAMERAS_BUTTON_SIDE_LENGTH, COV_SWAP_CAMERAS_BUTTON_SIDE_LENGTH);
        self.swapCamerasButton.contentMode = UIViewContentModeCenter;
        [self.swapCamerasButton setImage:[UIImage imageNamed:@"icon_camera_swap.png"] forState:UIControlStateNormal];
        [self.swapCamerasButton setImage:[UIImage imageNamed:@"icon_camera_swap_touch.png"] forState:UIControlStateHighlighted];
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
