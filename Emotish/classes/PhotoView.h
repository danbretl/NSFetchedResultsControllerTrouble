//
//  PhotoView.h
//  Emotish
//
//  Created by Dan Bretl on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextFieldWithInset.h"

@protocol PhotoViewDelegate;

@interface PhotoView : UIView

@property (strong, nonatomic) UIButton * button;
@property (strong, nonatomic) UIImageView * photoImageView;
//@property (strong, nonatomic) UILabel * photoCaptionLabel;
@property (strong, nonatomic) UITextFieldWithInset * photoCaptionTextField;

@property (unsafe_unretained, nonatomic) id<PhotoViewDelegate> delegate;

@end

@protocol PhotoViewDelegate <NSObject>
- (void) photoViewTouched:(PhotoView *)photoView;
@end