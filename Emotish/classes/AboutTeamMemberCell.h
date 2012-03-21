//
//  AboutTeamMemberCell.h
//  Emotish
//
//  Created by Dan Bretl on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutLinksView.h"
#import "PhotoView.h"

@interface AboutTeamMemberCell : UITableViewCell <PhotoViewDelegate>

//@property (nonatomic, strong) UIButton * headerButton;
@property (nonatomic, strong) PhotoView * photoView;
@property (nonatomic, strong) AboutLinksView * linksView;

//+ (CGFloat) fixedHeight; // TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY

@end
