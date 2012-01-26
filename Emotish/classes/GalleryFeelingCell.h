//
//  GalleryFeelingCell.h
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryFeelingCell : UITableViewCell <UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UITableView * imagesTableView;
@property (strong, nonatomic) UILabel * feelingLabel;

@property (strong, nonatomic) UIColor * feelingLabelColorNormal;
@property (strong, nonatomic) UIColor * feelingLabelColorHighlight;
//@property (nonatomic) BOOL feelingLabelHighlighted;

- (void) highlightLabel:(BOOL)highlight;
//- (void) highlightLabel:(BOOL)highlight animated:(BOOL)animated;
//- (void) scrollToOrigin;
- (void) scrollToOriginAnimated:(BOOL)animated;

@end
