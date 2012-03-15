//
//  PhotoView.m
//  Emotish
//
//  Created by Dan Bretl on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoView.h"
#import "ViewConstants.h"
#import "UIColor+Emotish.h"
#import "NSDateFormatter+EmotishTimeSpans.h"

const CGFloat PC_PHOTO_CELL_LABEL_FONT_SIZE =           20.0;
const double PV_ACTION_BUTTONS_VISIBLE_ANIMATION_DURATION = 0.25;
const double PV_INFO_VISIBLE_ANIMATION_DURATION = 0.15;
const CGFloat PV_TIME_BUTTON_MARGIN_RIGHT = 8.0;

@interface PhotoViewActionButtonInfo : NSObject
@property (nonatomic) PhotoViewActionButtonCode code;
@property (nonatomic, strong) NSIndexPath * position;
@property (nonatomic, strong) NSString * filenameIcon;
@property (nonatomic, strong) NSString * filenameIconTouch;
+ (PhotoViewActionButtonInfo *)photoViewActionButtonWithCode:(PhotoViewActionButtonCode)code position:(NSIndexPath *)position;
+ (NSString *)filenameIconForCode:(PhotoViewActionButtonCode)code touchVersion:(BOOL)touchVersion;
@end
@implementation PhotoViewActionButtonInfo
@synthesize code=_code, filenameIcon=_filenameIcon, filenameIconTouch=_filenameIconTouch, position=_position;
+ (PhotoViewActionButtonInfo *)photoViewActionButtonWithCode:(PhotoViewActionButtonCode)code position:(NSIndexPath *)position {
    PhotoViewActionButtonInfo * photoViewActionButton = [[PhotoViewActionButtonInfo alloc] init];
    photoViewActionButton.code = code;
    photoViewActionButton.position = position;
    photoViewActionButton.filenameIcon = [PhotoViewActionButtonInfo filenameIconForCode:code touchVersion:NO];
    photoViewActionButton.filenameIconTouch = [PhotoViewActionButtonInfo filenameIconForCode:code touchVersion:YES];
    return photoViewActionButton;
}
+ (NSString *)filenameIconForCode:(PhotoViewActionButtonCode)code touchVersion:(BOOL)touchVersion {
    NSString * filenameID = nil;
    switch (code) {
        case Twitter:     filenameID = @"twitter";  break;
        case Facebook:    filenameID = @"facebook"; break;
        case Email:       filenameID = @"email";    break;
        case TextMessage: filenameID = @"text";     break;
        case LikePhoto:   filenameID = @"like";     break;
        case Flag:        filenameID = @"flag";     break;
        case Delete:      filenameID = @"delete";   break;            
        default: break;
    }
    return [NSString stringWithFormat:@"btn_image_overlay_%@%@.png", filenameID, touchVersion ? @"_touch" : @""];
}
@end

@interface PhotoView()
- (void) initWithFrameOrCoder;
- (void) photoCaptionButtonTouched:(UIButton *)button;
@property (nonatomic) int actionButtonRows;
@property (nonatomic) int actionButtonColumns;
@property (nonatomic, readonly) int actionButtonSlots;
@property (strong, nonatomic) NSMutableArray * actionButtons;
@property (strong, nonatomic, readonly) NSArray * actionButtonsInfo;
@property (strong, nonatomic) UIView * actionButtonsContainer;
- (void) actionButtonTouched:(UIButton *)actionButton;
@property (strong, nonatomic) UITapGestureRecognizer * tapSingleGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer * tapDoubleGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer * tapHoldGestureRecognizer;
- (void) tapSingle:(UITapGestureRecognizer *)gestureRecognizer;
- (void) tapDouble:(UITapGestureRecognizer *)gestureRecognizer;
- (void) tapHold:(UILongPressGestureRecognizer *)gestureRecognizer;
@property (nonatomic) BOOL actionButtonsVisible;
- (void) show:(BOOL)shouldShow infoButton:(UIButton *)infoButton animated:(BOOL)animated;
- (void) showTime:(BOOL)shouldShowTime animated:(BOOL)animated;
@end

@implementation PhotoView

@synthesize photoCaptionButton=_photoCaptionButton;
@synthesize photoImageView=_photoImageView;
@synthesize photoInfoContainer=_photoInfoContainer, likesButton=_likesButton, timeButton=_timeButton;
//@synthesize photoCaptionLabel=_photoCaptionLabel;
@synthesize photoCaptionTextField=_photoCaptionTextField;
@synthesize delegate=_delegate;
@synthesize actionButtonRows, actionButtonColumns;
@synthesize actionButtonsContainer=_actionButtonsContainer, actionButtons=_actionButtons, actionButtonsInfo=_actionButtonsInfo;
@synthesize actionButtonsEnabled=_actionButtonsEnabled, /*tapAndHoldGestureRecognizer=_tapAndHoldGestureRecognizer,*/ actionButtonsVisible=_actionButtonsVisible;
@synthesize tapSingleGestureRecognizer=_tapSingleGestureRecognizer, tapDoubleGestureRecognizer=_tapDoubleGestureRecognizer, tapHoldGestureRecognizer=_tapHoldGestureRecognizer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (void) initWithFrameOrCoder {
    
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH)];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.clipsToBounds = YES;
    [self addSubview:self.photoImageView];
    
    CGFloat captionsHeight = PC_PHOTO_CELL_PADDING_BOTTOM +  PC_PHOTO_CELL_LABEL_HEIGHT + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM;
    
    self.photoInfoContainer = [[UIView alloc] initWithFrame:CGRectMake(self.photoImageView.frame.origin.x, CGRectGetMaxY(self.photoImageView.frame), self.photoImageView.frame.size.width, captionsHeight)];
    [self addSubview:self.photoInfoContainer];
    
    self.timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.timeButton.frame = CGRectMake(0, 0, 40, self.photoInfoContainer.frame.size.height);
    self.timeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.timeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.timeButton.imageEdgeInsets = UIEdgeInsetsMake(7, 0, 0, 0);
    self.timeButton.titleEdgeInsets = UIEdgeInsetsMake(6, 5, 0, 0);
    self.timeButton.imageView.contentMode = UIViewContentModeCenter;
    self.timeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.timeButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    [self.timeButton setTitleColor:[UIColor timeLikesColor] forState:UIControlStateNormal];
    [self.timeButton setImage:[UIImage imageNamed:@"icon_clock.png"] forState:UIControlStateNormal];
    self.timeButton.backgroundColor = [UIColor clearColor];
    self.timeButton.imageView.backgroundColor = [UIColor clearColor];
    self.timeButton.titleLabel.backgroundColor = [UIColor clearColor];
    self.timeButton.userInteractionEnabled = NO;
    [self.photoInfoContainer addSubview:self.timeButton];
    
    self.likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.likesButton.frame = CGRectMake(CGRectGetMaxX(self.timeButton.frame), 0, 80, self.photoInfoContainer.frame.size.height);
    self.likesButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.likesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.likesButton.imageEdgeInsets = UIEdgeInsetsMake(8, 0, 0, 0);
    self.likesButton.titleEdgeInsets = UIEdgeInsetsMake(6, 5, 0, 0);
    self.likesButton.imageView.contentMode = UIViewContentModeCenter;
    self.likesButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.likesButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    [self.likesButton setTitleColor:[UIColor timeLikesColor] forState:UIControlStateNormal];
    [self.likesButton setTitleColor:[UIColor timeLikesColor] forState:UIControlStateHighlighted];
    [self.likesButton setImage:[UIImage imageNamed:@"icon_like.png"] forState:UIControlStateNormal];
    [self.likesButton setImage:[UIImage imageNamed:@"icon_like_touch.png"] forState:UIControlStateHighlighted];
    self.likesButton.backgroundColor = [UIColor clearColor];
    self.likesButton.imageView.backgroundColor = [UIColor clearColor];
    self.likesButton.titleLabel.backgroundColor = [UIColor clearColor];
    self.likesButton.userInteractionEnabled = NO;
    [self.photoInfoContainer addSubview:self.likesButton];
    
    [self showInfo:NO animated:NO];
    
//    self.photoInfoContainer.backgroundColor = [UIColor redColor];
//    self.timeButton.backgroundColor = [UIColor yellowColor];
//    self.likesButton.backgroundColor = [UIColor orangeColor];
    
    self.photoCaptionTextField = [[UITextFieldWithInset alloc] initWithFrame:CGRectMake(self.photoImageView.frame.origin.x, CGRectGetMaxY(self.photoImageView.frame), self.photoImageView.frame.size.width, captionsHeight)];
    self.photoCaptionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.photoCaptionTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.photoCaptionTextField.textAlignment = UITextAlignmentRight;
    self.photoCaptionTextField.textFieldInsets = UIEdgeInsetsMake(PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM - 4.0, 0, 0, 0);;
    self.photoCaptionTextField.font = [UIFont boldSystemFontOfSize:PC_PHOTO_CELL_LABEL_FONT_SIZE];
    self.photoCaptionTextField.backgroundColor = [UIColor clearColor];
    self.photoCaptionTextField.userInteractionEnabled = NO;
    self.photoCaptionTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.photoCaptionTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self addSubview:self.photoCaptionTextField];
    
    self.photoCaptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.photoCaptionButton.frame = CGRectMake(self.photoCaptionTextField.frame.origin.x, self.photoCaptionTextField.frame.origin.y, self.frame.size.width - self.photoCaptionTextField.frame.origin.x, self.photoCaptionTextField.frame.size.height);
    self.photoCaptionButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.photoCaptionButton addTarget:self action:@selector(photoCaptionButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.photoCaptionButton];
    
//    self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    
    self.actionButtonsContainer = [[UIView alloc] initWithFrame:self.photoImageView.frame];
//    self.actionButtonsContainer.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.0 alpha:0.5];
    [self addSubview:self.actionButtonsContainer];
    
    self.actionButtonRows = 4;
    self.actionButtonColumns = 4;
    self.actionButtons = [NSMutableArray arrayWithCapacity:self.actionButtonSlots];
    for (int i=0; i<self.actionButtonSlots; i++) {
        [self.actionButtons addObject:[NSNull null]];
    }
    
    for (PhotoViewActionButtonInfo * actionButtonInfo in self.actionButtonsInfo) {
        UIButton * actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        actionButton.contentMode = UIViewContentModeCenter;
        [actionButton addTarget:self action:@selector(actionButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        actionButton.tag = actionButtonInfo.code; // Insider knowledge...
        [actionButton setImage:[UIImage imageNamed:actionButtonInfo.filenameIcon] forState:UIControlStateNormal];
        [actionButton setImage:[UIImage imageNamed:actionButtonInfo.filenameIconTouch] forState:UIControlStateHighlighted];
        [self.actionButtons replaceObjectAtIndex:(actionButtonInfo.position.section * actionButtonColumns + actionButtonInfo.position.row) withObject:actionButton];
//        NSLog(@"Placing action button (filename %@) with index path %d-%d at index %d", actionButtonInfo.filenameIcon, actionButtonInfo.position.section, actionButtonInfo.position.row, actionButtonInfo.position.section * actionButtonColumns + actionButtonInfo.position.row);
        // Below is TEMPORARY, while features are being developed...
        // Below is TEMPORARY, while features are being developed...
        // Below is TEMPORARY, while features are being developed...
        BOOL enabled = YES;
        if (actionButtonInfo.code != LikePhoto &&
            actionButtonInfo.code != Delete &&
            actionButtonInfo.code != Flag) {
            enabled = NO;
        }
        actionButton.alpha = enabled ? 1.0 : 0.5;
        // Above is TEMPORARY, while features are being developed...
        // Above is TEMPORARY, while features are being developed...
        // Above is TEMPORARY, while features are being developed...
        [self.actionButtonsContainer addSubview:actionButton];
    }
    [self setNeedsLayout];
    self.actionButtonsContainer.alpha = 0.0;
    _actionButtonsVisible = NO;
    
    // Tap double
    self.tapDoubleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDouble:)];
    self.tapDoubleGestureRecognizer.delegate = self;
    self.tapDoubleGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:self.tapDoubleGestureRecognizer];
    // Tap single
    self.tapSingleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSingle:)];
    self.tapSingleGestureRecognizer.delegate = self;
    [self.tapSingleGestureRecognizer requireGestureRecognizerToFail:self.tapDoubleGestureRecognizer];
    [self addGestureRecognizer:self.tapSingleGestureRecognizer];
    // Tap hold
    self.tapHoldGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapHold:)];
    self.tapHoldGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapHoldGestureRecognizer];
    
    BOOL debugging = NO;
    if (debugging) {
//        self.photoImageView.backgroundColor = [UIColor blueColor];
//        self.photoCaptionTextField.backgroundColor = [UIColor greenColor];
//        self.photoCaptionButton.backgroundColor = [UIColor redColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
        self.photoImageView.backgroundColor = [UIColor clearColor];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat actionButtonWidth = floorf(self.photoImageView.frame.size.width / self.actionButtonColumns);
    CGFloat actionButtonHeight = floorf(self.photoImageView.frame.size.height / self.actionButtonRows);
    for (int column=0; column<self.actionButtonColumns; column++) {
        for (int row=0; row<self.actionButtonRows; row++) {
            int index = column * self.actionButtonRows + row;
            id actionButtonID = [self.actionButtons objectAtIndex:index];
            if (actionButtonID != [NSNull null]) {
                UIButton * actionButton = (UIButton *)actionButtonID;
//                NSLog(@"Setting frame for button with code %d", actionButton.tag);
                actionButton.frame = CGRectMake(actionButtonWidth * row, actionButtonHeight * column, actionButtonWidth, actionButtonHeight);
//                NSLog(@"%@", NSStringFromCGRect(actionButton.frame));
            }
        }
    }
}

- (void)setActionButtonsEnabled:(BOOL)actionButtonsEnabled {
    _actionButtonsEnabled = actionButtonsEnabled;
    self.actionButtonsContainer.userInteractionEnabled = self.actionButtonsEnabled;
    self.tapSingleGestureRecognizer.enabled = self.actionButtonsEnabled;
    self.tapHoldGestureRecognizer.enabled = self.actionButtonsEnabled;
}

- (void)showInfo:(BOOL)shouldShowInfo animated:(BOOL)animated {
    [self showInfo:shouldShowInfo showLikes:shouldShowInfo animated:animated];
}

- (void)showInfo:(BOOL)shouldShowInfo showLikes:(BOOL)shouldShowLikes animated:(BOOL)animated {
    [self showTime:shouldShowInfo  animated:animated];
    [self showLikes:shouldShowInfo && shouldShowLikes animated:animated];
}

- (void) showTime:(BOOL)shouldShowTime animated:(BOOL)animated {
    [self show:shouldShowTime infoButton:self.timeButton animated:animated];
}

- (void) showLikes:(BOOL)shouldShowLikes animated:(BOOL)animated {
    [self show:shouldShowLikes infoButton:self.likesButton animated:animated];
}

- (void) show:(BOOL)shouldShow infoButton:(UIButton *)infoButton animated:(BOOL)animated {
    if (shouldShow) { NSLog(@"DEBUGDEBUGDEBUGDEBUGDEBUGDEBUG"); }
    if (animated) {
        [UIView animateWithDuration:PV_INFO_VISIBLE_ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            infoButton.alpha = shouldShow ? 1.0 : 0.0;
        } completion:NULL];
    } else {
        infoButton.alpha = shouldShow ? 1.0 : 0.0;
    }
}

- (void) updateTime:(NSDate *)timestamp {
    NSLog(@"updateTime:%@", timestamp);
    NSString * timeString = [NSDateFormatter emotishTimeSpanStringForDatetime:timestamp countSeconds:YES];
    NSLog(@"timeString:%@", timeString);
    
    [self.timeButton setTitle:timeString forState:UIControlStateNormal];
    
    CGSize timeSize = [timeString sizeWithFont:self.timeButton.titleLabel.font];
    NSLog(@"timeStringWidth = %f", timeSize.width);
    CGRect timeButtonFrame = self.timeButton.frame;
    timeButtonFrame.size.width = self.timeButton.titleLabel.frame.origin.x + timeSize.width;
    self.timeButton.frame = timeButtonFrame;
//    self.timeButton.imageView.backgroundColor = [UIColor blueColor];
//    self.timeButton.titleLabel.backgroundColor = [UIColor greenColor];
    CGRect likesButtonFrame = self.likesButton.frame;
    likesButtonFrame.origin.x = CGRectGetMaxX(self.timeButton.frame) + PV_TIME_BUTTON_MARGIN_RIGHT;
    self.likesButton.frame = likesButtonFrame;
    
}

- (void) updateLikesCount:(NSNumber *)likesCount likedPersonally:(BOOL)likedPersonally {
    BOOL likesCountGreaterThanZero = likesCount != nil && likesCount.intValue > 0;
    NSString * likesString = likesCountGreaterThanZero ? [NSString stringWithFormat:@"%d", likesCount.intValue] : @"";
    [self.likesButton setTitle:likesString forState:UIControlStateNormal];
    [self.likesButton setTitle:likesString forState:UIControlStateHighlighted];
//    NSLog(@"updateLikesCount, likesCountGreaterThanZero? %d", likesCountGreaterThanZero);
//    self.likesButton.imageView.alpha = likesCountGreaterThanZero ? 1.0 : 0.0; // Why is this not working...
    NSString * normalImageFilename = @"icon_like.png";
    if (likedPersonally) {
        normalImageFilename = @"icon_like_touch.png";
    }
    [self.likesButton setImage:[UIImage imageNamed:normalImageFilename] forState:UIControlStateNormal];
}

- (void) setActionButtonWithCode:(PhotoViewActionButtonCode)actionButtonCode enabled:(BOOL)enabled visible:(BOOL)visible {
    UIButton * actionButton = [self actionButtonWithCode:actionButtonCode];
    actionButton.userInteractionEnabled = enabled;
    actionButton.alpha = visible ? 1.0 : 0.0;
}

- (UIButton *)actionButtonWithCode:(PhotoViewActionButtonCode)actionButtonCode {
    UIButton * actionButtonMatched = nil;
    for (UIButton * actionButton in self.actionButtons) {
        if (![actionButton isEqual:[NSNull null]] && 
            actionButton.tag == actionButtonCode) {
            actionButtonMatched = actionButton;
            break;
        }
    }
    return actionButtonMatched;
}

- (void)showActionButtons:(BOOL)shouldShowActionButtons animated:(BOOL)animated {
    _actionButtonsVisible = shouldShowActionButtons;
//    self.actionButtonsContainer.userInteractionEnabled = self.actionButtonsVisible;
    void(^alphaBlock)(BOOL) = ^(BOOL visible){
        self.actionButtonsContainer.alpha = visible ? 1.0 : 0.0;
    };
    if (animated) {
        [UIView animateWithDuration:PV_ACTION_BUTTONS_VISIBLE_ANIMATION_DURATION animations:^{
            alphaBlock(self.actionButtonsVisible);
        }];
    } else {
        alphaBlock(self.actionButtonsVisible);
    }
}

- (int)actionButtonSlots {
    return self.actionButtonColumns * self.actionButtonRows;
}

- (NSArray *)actionButtonsInfo {
    if (_actionButtonsInfo == nil) {
        _actionButtonsInfo = [NSArray arrayWithObjects:
                              [PhotoViewActionButtonInfo photoViewActionButtonWithCode:Twitter position:[NSIndexPath indexPathForRow:0 inSection:0]],
                              [PhotoViewActionButtonInfo photoViewActionButtonWithCode:Facebook position:[NSIndexPath indexPathForRow:1 inSection:0]],
                              [PhotoViewActionButtonInfo photoViewActionButtonWithCode:Email position:[NSIndexPath indexPathForRow:2 inSection:0]],
                              [PhotoViewActionButtonInfo photoViewActionButtonWithCode:TextMessage position:[NSIndexPath indexPathForRow:3 inSection:0]],
                              [PhotoViewActionButtonInfo photoViewActionButtonWithCode:LikePhoto position:[NSIndexPath indexPathForRow:3 inSection:1]],
                              [PhotoViewActionButtonInfo photoViewActionButtonWithCode:Flag position:[NSIndexPath indexPathForRow:3 inSection:2]],
                              [PhotoViewActionButtonInfo photoViewActionButtonWithCode:Delete position:[NSIndexPath indexPathForRow:3 inSection:3]],
                              nil];
    }
    return _actionButtonsInfo;
}

- (void)photoCaptionButtonTouched:(UIButton *)button {
    [self.delegate photoView:self photoCaptionButtonTouched:button];
}
                              
- (void)actionButtonTouched:(UIButton *)actionButton {
    PhotoViewActionButtonCode actionButtonCode = actionButton.tag; // Insider knowledge...
    [self.delegate photoView:self actionButtonTouched:actionButton withActionButtonCode:actionButtonCode];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.tapSingleGestureRecognizer) {
        NSLog(@"gestureRecognizerShouldReceiveTouch - gestureRecognizer (%@) for %d touches", [[gestureRecognizer class] description], gestureRecognizer.numberOfTouches);
    }
    BOOL shouldReceiveTouch = YES;
//    if ([touch.view isDescendantOfView:self.actionButtonsContainer]) {
//        shouldReceiveTouch = NO;
//    }
//    NSLog(@"%@", touch.view);
//    NSLog(@"touch.view isMemberOfClass:[UIButton class] ?=? %d", [touch.view isMemberOfClass:[UIButton class]]);
    if ([touch.view isMemberOfClass:[UIButton class]] ||
        !CGRectContainsPoint(self.photoImageView.bounds, [touch locationInView:self.photoImageView])) {
        shouldReceiveTouch = NO;
    }
    return shouldReceiveTouch;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.tapSingleGestureRecognizer) {
        [self.delegate photoView:self tapSingleGestureDidBegin:(UITapGestureRecognizer *)gestureRecognizer];
    }
    return YES;
}

- (void)tapSingle:(UITapGestureRecognizer *)gestureRecognizer {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate photoView:self tapSingleGestureRecognized:gestureRecognizer];
}

- (void)tapDouble:(UITapGestureRecognizer *)gestureRecognizer {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate photoView:self tapDoubleGestureRecognized:gestureRecognizer];
}

- (void)tapHold:(UILongPressGestureRecognizer *)gestureRecognizer {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate photoView:self tapHoldGestureRecognized:gestureRecognizer];
    }
}

@end