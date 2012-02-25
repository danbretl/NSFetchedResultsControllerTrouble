//
//  SettingsItemTableViewCell.h
//  Emotish
//
//  Created by Dan Bretl on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsItemTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView * arrowView;
@property (nonatomic) CGFloat textLabelPaddingLeft;
@property (nonatomic) CGFloat textLabelPaddingRight;
@property (nonatomic, strong) UIColor * highlightedBackgroundColor;

@end
