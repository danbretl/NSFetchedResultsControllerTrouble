//
//  GalleryFeelingCell.h
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryFeelingImageCell.h"
#import "Photo.h"
#import "FlagStretchView.h"

@protocol GalleryFeelingCellDelegate;

@interface GalleryFeelingCell : UITableViewCell <UITableViewDataSource, GalleryFeelingImageCellDelegate>

@property (strong, nonatomic) NSArray * photos;

@property (strong, nonatomic) UITableView * imagesTableView;
@property (strong, nonatomic) UILabel * feelingLabel;
@property (strong, nonatomic) UIButton * feelingLabelButton;
@property (strong, nonatomic) UILabel * timestampLabel;
@property (strong, nonatomic) FlagStretchView * flagStretchView;

@property (strong, nonatomic) UIColor * feelingLabelColorNormal;
@property (strong, nonatomic) UIColor * feelingLabelColorHighlight;

@property (nonatomic) NSInteger feelingIndex;

@property (unsafe_unretained, nonatomic) id<GalleryFeelingCellDelegate> delegate;

- (void) highlightLabel:(BOOL)highlight;
//- (void) highlightLabel:(BOOL)highlight animated:(BOOL)animated;
//- (void) scrollToOrigin;
- (void) scrollToOriginAnimated:(BOOL)animated;

@end

@protocol GalleryFeelingCellDelegate <NSObject>
- (void) feelingCellSelected:(GalleryFeelingCell *)feelingCell fromImageCell:(GalleryFeelingImageCell *)imageCell;
@end