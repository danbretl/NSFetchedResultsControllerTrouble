//
//  TopBarView.h
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BrandingRight = 100,
    BrandingCenter = 200,
} TopBarViewMode;

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

@property (strong, nonatomic) UIButton * buttonBranding;
@property (strong, nonatomic) UIButton * buttonLeftSpecial;
@property (strong, nonatomic) UIButton * buttonLeftNormal;
@property (strong, nonatomic) UIButton * buttonRightNormal;
@property (strong, nonatomic) UIView * backgroundView;

- (void) setViewMode:(TopBarViewMode)viewMode animated:(BOOL)animated;
- (void) showButtonType:(TopBarButtonType)buttonType inPosition:(TopBarButtonPosition)buttonPosition animated:(BOOL)animated;
- (void) hideButtonInPosition:(TopBarButtonPosition)buttonPosition animated:(BOOL)animated;
- (void) addTarget:(id)target selector:(SEL)selector forButtonPosition:(TopBarButtonPosition)buttonPosition;

@end
