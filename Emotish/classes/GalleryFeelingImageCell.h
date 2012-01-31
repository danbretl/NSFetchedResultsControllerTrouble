//
//  GalleryFeelingImageCell.h
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GalleryFeelingCell;
@protocol GalleryFeelingImageCellDelegate;

@interface GalleryFeelingImageCell : UITableViewCell

//@property (strong, nonatomic) UIImageView * feelingImageView;
@property (strong, nonatomic) UIButton * button;
@property (nonatomic) NSInteger feelingIndex;
@property (nonatomic) NSInteger imageIndex;
@property (unsafe_unretained, nonatomic) GalleryFeelingCell * feelingCell;
@property (unsafe_unretained, nonatomic) id<GalleryFeelingImageCellDelegate> delegate;

@end

@protocol GalleryFeelingImageCellDelegate <NSObject>
- (void) feelingImageCellButtonTouched:(GalleryFeelingImageCell *)feelingImageCell;
@end