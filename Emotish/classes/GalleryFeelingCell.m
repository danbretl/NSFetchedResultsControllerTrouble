//
//  GalleryFeelingCell.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryFeelingCell.h"
#import "GalleryConstants.h"
#import "UIColor+Emotish.h"
#import "GalleryFeelingImageCell.h"
#import "UIButton+WebCache.h"

//#define GFC_ANIMATION_DURATION 0.25
const CGFloat GFC_FEELING_IMAGE_SECOND_PERCENTAGE_OVERHANG = 0.2;
const CGFloat GFC_FLAG_STRETCH_VIEW_ACTIVATION_DISTANCE_START = 35.0;
const CGFloat GFC_FLAG_STRETCH_VIEW_ACTIVATION_DISTANCE_END = 65.0;
const CGFloat GFC_FLAG_STRETCH_VIEW_HEIGHT = 48.0;

@interface GalleryFeelingCell()
- (void) feelingLabelButtonTouched:(UIButton *)button;
@end

@implementation GalleryFeelingCell

@synthesize photos=_photos;
@synthesize imagesTableView=_imagesTableView;
@synthesize feelingLabel=_feelingLabel;
@synthesize feelingLabelButton=_feelingLabelButton;
@synthesize flagStretchView=_flagStretchView;

@synthesize feelingLabelColorNormal=_feelingLabelColorNormal;
@synthesize feelingLabelColorHighlight=_feelingLabelColorHighlight;
//@synthesize feelingLabelHighlighted=_feelingLabelHighlighted;

@synthesize feelingIndex=_feelingIndex;

@synthesize delegate=_delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        BOOL debugging = NO;
        
        self.feelingLabelColorNormal = [UIColor feelingColor];
        self.feelingLabelColorHighlight = self.feelingLabelColorNormal;
        
        CGFloat selfHeight = GC_FEELING_IMAGE_SIDE_LENGTH + 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
        CGFloat tableViewHeaderWidth = GC_TABLE_WIDTH - (GC_FEELING_IMAGE_SIDE_LENGTH + GC_FEELING_IMAGE_MARGIN_RIGHT + floorf(GC_FEELING_IMAGE_SIDE_LENGTH * GFC_FEELING_IMAGE_SECOND_PERCENTAGE_OVERHANG));
        CGFloat labelWidth = tableViewHeaderWidth - (GC_FEELING_LABEL_MARGIN_LEFT + GC_FEELING_LABEL_MARGIN_RIGHT);
        
        UIScrollView * wrapperScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, GC_TABLE_WIDTH, selfHeight)]; // This fixes a bug where bouncing does not work from the edge of the table view.
        wrapperScrollView.scrollsToTop = NO;
        [self addSubview:wrapperScrollView];
        
        self.imagesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, selfHeight, GC_TABLE_WIDTH)];
//        self.imagesTableView.delegate = self;
        self.imagesTableView.dataSource = self;
        self.imagesTableView.alwaysBounceVertical = YES;
        self.imagesTableView.showsHorizontalScrollIndicator = NO;
        self.imagesTableView.showsVerticalScrollIndicator = NO;
        self.imagesTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        self.imagesTableView.frame = CGRectMake(0, 0, GC_TABLE_WIDTH, selfHeight);
        self.imagesTableView.rowHeight = GC_FEELING_IMAGE_SIDE_LENGTH + GC_FEELING_IMAGE_MARGIN_RIGHT;
        self.imagesTableView.backgroundColor = [UIColor clearColor];
        self.imagesTableView.opaque = YES;
        self.imagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.imagesTableView.allowsSelection = NO;
        self.imagesTableView.directionalLockEnabled = YES;
        self.imagesTableView.scrollsToTop = NO;
        
        UIView * tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selfHeight, tableViewHeaderWidth)];
        self.imagesTableView.tableHeaderView = tableViewHeader;
        
        self.feelingLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.feelingLabelButton.frame = tableViewHeader.bounds;
        self.feelingLabelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.feelingLabelButton addTarget:self action:@selector(feelingLabelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.imagesTableView.tableHeaderView addSubview:self.feelingLabelButton];
        
        self.feelingLabel = nil;
        
        self.feelingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GC_FEELING_LABEL_MARGIN_LEFT, selfHeight, labelWidth)];
        self.feelingLabel.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        self.feelingLabel.frame = CGRectMake(0, GC_FEELING_LABEL_MARGIN_LEFT, selfHeight, labelWidth); // Confused about this...
        self.feelingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.feelingLabel.textAlignment = UITextAlignmentRight;
        self.feelingLabel.text = @"feeling";
        self.feelingLabel.font = [UIFont boldSystemFontOfSize:30.0];
        self.feelingLabel.adjustsFontSizeToFitWidth = YES;
        self.feelingLabel.backgroundColor = [UIColor clearColor];
        [self highlightLabel:NO];
        [self.imagesTableView.tableHeaderView insertSubview:self.feelingLabel belowSubview:self.feelingLabelButton];
          
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//        CGFloat flagStretchViewHeight = selfHeight - 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
//        CGFloat flagStretchViewHeight = floorf(selfHeight / 2.0);
//        CGFloat flagStretchViewHeight = 2 * selfHeight;
        CGFloat flagStretchViewHeight = GFC_FLAG_STRETCH_VIEW_HEIGHT;
        self.flagStretchView = [[FlagStretchView alloc] initWithFrame:CGRectMake(floorf((selfHeight - flagStretchViewHeight) / 2.0), -screenWidth, flagStretchViewHeight, screenWidth)];
        self.flagStretchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.flagStretchView.icon.hidden = YES;
        self.flagStretchView.angledShapes = YES;
        [self.flagStretchView setMiddleStripeBorderWidth:6.0];
//        self.flagStretchView.alpha = 0.5;
//        self.flagStretchView.pullOutSides = NO; // This, combined with angled shapes, is far too phallic.
        self.flagStretchView.activationDistanceStart = GFC_FLAG_STRETCH_VIEW_ACTIVATION_DISTANCE_START;
        self.flagStretchView.activationDistanceEnd = GFC_FLAG_STRETCH_VIEW_ACTIVATION_DISTANCE_END;
        self.flagStretchView.activationAffectsAlpha = YES;
        self.flagStretchView.sidesAlphaNormal = 0.5;
        self.flagStretchView.sidesAlphaActivated = .9;
        self.flagStretchView.middleAlphaNormal = 0.5;
        self.flagStretchView.middleAlphaActivated = .9;
        self.flagStretchView.activationAffectsIcon = NO;
        [self.imagesTableView.tableHeaderView addSubview:self.flagStretchView];
        
        [wrapperScrollView addSubview:self.imagesTableView];
        [self addSubview:wrapperScrollView];
        
        if (debugging) {
            tableViewHeader.backgroundColor = [UIColor purpleColor];
            self.flagStretchView.backgroundColor = [UIColor cyanColor];
            self.feelingLabel.backgroundColor = [UIColor redColor];
            self.imagesTableView.backgroundColor = [UIColor yellowColor];
        }
        
//        self.clipsToBounds = NO;
//        self.imagesTableView.clipsToBounds = NO;
//        self.imagesTableView.tableHeaderView.clipsToBounds = NO;
        
    }
    return self;
}

- (void) highlightLabel:(BOOL)highlight {
    self.feelingLabel.textColor = highlight ? self.feelingLabelColorHighlight : self.feelingLabelColorNormal;
}

//- (void) highlightLabel:(BOOL)highlight animated:(BOOL)animated {
//    if (animated) {
//        [UIView animateWithDuration:GFC_ANIMATION_DURATION animations:^{
//            [self highlightLabel:highlight];
//        }];
//    } else {
//        [self highlightLabel:highlight];
//    }
//}

//- (void) scrollToOrigin {
//    [self highlightLabel:NO];
////    [self.imagesTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//    [self.imagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
////    [self.imagesTableView setContentOffset:CGPointMake(0, 0)];
//}

//- (void) scrollToOriginAnimated:(BOOL)animated {
//    if (animated) {
//        [UIView animateWithDuration:GFC_ANIMATION_DURATION delay:0.0 options:0 animations:^{
//            [self scrollToOrigin];
//        } completion:NULL];
//    } else {
//        [self scrollToOrigin];
//    }
//}

- (void) scrollToOriginAnimated:(BOOL)animated {
    [self highlightLabel:NO];
    if ([self tableView:self.imagesTableView numberOfRowsInSection:0] > 0) {
        [self.imagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];        
    } else {
        [self.imagesTableView setContentOffset:CGPointZero animated:animated];
    }
}


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"GalleryFeelingCell scrollViewDidScroll, contentOffset=%@", NSStringFromCGPoint(scrollView.contentOffset));
//}

- (void)setFeelingIndex:(NSInteger)feelingIndex {
    _feelingIndex = feelingIndex;
    self.imagesTableView.tag = self.feelingIndex;
    self.feelingLabelButton.tag = self.feelingIndex;
    for (GalleryFeelingImageCell * visibleCell in self.imagesTableView.visibleCells) {
        visibleCell.feelingIndex = self.feelingIndex;
    }
}

- (void)feelingLabelButtonTouched:(UIButton *)button {
    [self.delegate feelingCellSelected:self fromImageCell:nil];
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self.imagesTableView reloadData];
}

- (void)feelingImageCellButtonTouched:(GalleryFeelingImageCell *)feelingImageCell {
    [self.delegate feelingCellSelected:self fromImageCell:feelingImageCell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get / Create the cell
    static NSString * FeelingImageCellID = @"FeelingImageCellID";
    GalleryFeelingImageCell * cell = (GalleryFeelingImageCell *)[tableView dequeueReusableCellWithIdentifier:FeelingImageCellID];
    if (cell == nil) {
        cell = [[GalleryFeelingImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeelingImageCellID];
        cell.delegate = self;
    }
    
    // Configure the cell
    Photo * photo = [self.photos objectAtIndex:indexPath.row];
    [cell.button setImageWithURL:[NSURL URLWithString:photo.imageURL] placeholderImage:[UIImage imageNamed:@"photo_image_placeholder.png"]];
    cell.feelingIndex = self.feelingIndex;
    cell.imageIndex = indexPath.row;
    cell.feelingCell = self;
    [cell setHighlightTabVisible:photo.shouldHighlight.boolValue animated:NO];
                     
    // Return the cell
    return cell;

}
                     


@end
