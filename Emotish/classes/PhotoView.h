//
//  PhotoView.h
//  Emotish
//
//  Created by Dan Bretl on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextFieldWithInset.h"

typedef enum {
    Twitter = 1,
    Facebook = 2,
    Email = 3,
    TextMessage = 4,
    LikePhoto = 5,
    Flag = 6,
    Delete = 7,
} PhotoViewActionButtonCode;

@protocol PhotoViewDelegate;

@interface PhotoView : UIView <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView * photoImageView;
//@property (strong, nonatomic) UILabel * photoCaptionLabel;
@property (strong, nonatomic) UIButton * likesButton;
- (void) showLikes:(BOOL)shouldShowLikes animated:(BOOL)animated;
- (void) updateLikesCount:(NSNumber *)likesCount likedPersonally:(BOOL)likedPersonally;
- (void) showLikes:(BOOL)shouldShowLikes likesCount:(NSNumber *)likesCount likedPersonally:(BOOL)likedPersonally animated:(BOOL)animated;
@property (strong, nonatomic) UITextFieldWithInset * photoCaptionTextField;
@property (strong, nonatomic) UIButton * photoCaptionButton;

@property (nonatomic) BOOL actionButtonsEnabled;
@property (nonatomic, readonly) BOOL actionButtonsVisible;
- (void) showActionButtons:(BOOL)shouldShowActionButtons animated:(BOOL)animated;

@property (unsafe_unretained, nonatomic) id<PhotoViewDelegate> delegate;

@end

@protocol PhotoViewDelegate <NSObject>
@optional
- (void) photoView:(PhotoView *)photoView photoCaptionButtonTouched:(UIButton *)photoCaptionButton;
- (void) photoView:(PhotoView *)photoView actionButtonTouched:(UIButton *)actionButton withActionButtonCode:(PhotoViewActionButtonCode)actionButtonCode;
- (void) photoView:(PhotoView *)photoView tapSingleGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer;
- (void) photoView:(PhotoView *)photoView tapDoubleGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer;
- (void) photoView:(PhotoView *)photoView tapHoldGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer;
@end