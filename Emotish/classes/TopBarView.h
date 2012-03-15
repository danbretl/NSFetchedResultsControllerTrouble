//
//  TopBarView.h
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlagStretchView.h"

typedef enum {
    BrandingRight = 100,
    BrandingCenter = 200,
} TopBarViewMode;

typedef enum {
    StampNone = 0,
    StampAlphabetical = 1,
    StampRecent = 2,
} TopBarBrandingStamp;

typedef enum {
    ProfileButton = 1,
    SettingsButton = 2,
    BackButton = 3,
    CancelButton = 4,
    DoneButton = 5,
    SendButton = 6,
} TopBarButtonType;

typedef enum {
    LeftSpecial = 1,
    LeftNormal = 2,
    RightNormal = 3,
} TopBarButtonPosition;

@interface TopBarView : UIView

@property (nonatomic, readonly) TopBarViewMode viewMode;
@property (nonatomic, readonly) TopBarBrandingStamp brandingStamp;
@property (unsafe_unretained, nonatomic, readonly) NSTimer * brandingStampFadeTimer;

@property (strong, nonatomic) UIButton * buttonBranding;
@property (strong, nonatomic) UIButton * buttonLeftSpecial;
@property (strong, nonatomic) UIButton * buttonLeftNormal;
@property (strong, nonatomic) UIButton * buttonRightNormal;
@property (strong, nonatomic) UIImageView * backgroundView;
@property (strong, nonatomic) FlagStretchView * backgroundFlagView;

- (void) setViewMode:(TopBarViewMode)viewMode animated:(BOOL)animated;
- (void) setBrandingStamp:(TopBarBrandingStamp)brandingStamp animated:(BOOL)animated;
- (void)setBrandingStamp:(TopBarBrandingStamp)brandingStamp animated:(BOOL)animated delayedFadeToNone:(BOOL)shouldFadeToNoneAfterDelay;
- (void) showButtonType:(TopBarButtonType)buttonType inPosition:(TopBarButtonPosition)buttonPosition animated:(BOOL)animated;
- (void) hideButtonInPosition:(TopBarButtonPosition)buttonPosition animated:(BOOL)animated;
- (void) addTarget:(id)target selector:(SEL)selector forButtonPosition:(TopBarButtonPosition)buttonPosition;

@end
