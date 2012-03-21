//
//  SettingsSectionHeaderView.h
//  Emotish
//
//  Created by Dan Bretl on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsSectionHeaderView : UIView

@property (nonatomic) BOOL borderBottomVisible;
@property (nonatomic, strong) UIColor  * borderBottomColor;
@property (nonatomic, strong) NSString * labelText;
@property (nonatomic, strong) UIColor  * labelTextColor;

@property (nonatomic) CGFloat paddingLeft;
@property (nonatomic) CGFloat paddingRight;

@property (nonatomic, strong) UIButton * button;

@end
