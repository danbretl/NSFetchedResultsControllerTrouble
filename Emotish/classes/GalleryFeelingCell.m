//
//  GalleryFeelingCell.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryFeelingCell.h"
#import "GalleryConstants.h"

//#define GFC_ANIMATION_DURATION 0.25

@interface GalleryFeelingCell()
- (void) feelingLabelButtonTouched:(UIButton *)button;
@end

@implementation GalleryFeelingCell

@synthesize imagesTableView=_imagesTableView;
@synthesize feelingLabel=_feelingLabel;
@synthesize feelingLabelButton=_feelingLabelButton;

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
        
        self.feelingLabelColorNormal = [UIColor colorWithRed:1.0 green:.71 blue:.14 alpha:1.0];
        self.feelingLabelColorHighlight = [self.feelingLabelColorNormal colorWithAlphaComponent:1.0];
        
        CGFloat selfHeight = GC_FEELING_IMAGE_SIDE_LENGTH + 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
        CGFloat labelContainerWidth = GC_TABLE_WIDTH - (GC_FEELING_IMAGE_SIDE_LENGTH + GC_FEELING_IMAGE_MARGIN_RIGHT + floorf(GC_FEELING_IMAGE_SIDE_LENGTH * 0.2));
        CGFloat labelWidth = labelContainerWidth - (GC_FEELING_LABEL_MARGIN_LEFT + GC_FEELING_LABEL_MARGIN_RIGHT);
        
        UIScrollView * wrapperScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, GC_TABLE_WIDTH, selfHeight)]; // This fixes a bug where bouncing does not work from the edge of the table view.
        [self addSubview:wrapperScrollView];
        
        self.imagesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, selfHeight, GC_TABLE_WIDTH)];
//        self.imagesTableView.delegate = self;
        self.imagesTableView.alwaysBounceVertical = YES;
        self.imagesTableView.showsHorizontalScrollIndicator = NO;
        self.imagesTableView.showsVerticalScrollIndicator = NO;
        self.imagesTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        self.imagesTableView.frame = CGRectMake(0, 0, GC_TABLE_WIDTH, selfHeight);
        self.imagesTableView.rowHeight = GC_FEELING_IMAGE_SIDE_LENGTH + GC_FEELING_IMAGE_MARGIN_RIGHT;
        self.imagesTableView.backgroundColor = [UIColor whiteColor];
        self.imagesTableView.opaque = YES;
        self.imagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.imagesTableView.allowsSelection = NO;
        self.imagesTableView.directionalLockEnabled = YES;
        
        self.feelingLabel = [[UILabel alloc] initWithFrame:CGRectMake(GC_FEELING_LABEL_MARGIN_LEFT, 0, labelWidth, selfHeight)];
        self.feelingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.feelingLabel.textAlignment = UITextAlignmentRight;
        self.feelingLabel.text = @"feeling";
        self.feelingLabel.font = [UIFont boldSystemFontOfSize:30.0];
        self.feelingLabel.adjustsFontSizeToFitWidth = YES;
//        self.feelingLabel.backgroundColor = [UIColor clearColor];
        [self highlightLabel:NO];
        UIView * feelingLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelContainerWidth, selfHeight)];
        feelingLabelContainer.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
//        feelingLabelContainer.backgroundColor = [UIColor clearColor];
        [feelingLabelContainer addSubview:self.feelingLabel];
        self.feelingLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.feelingLabelButton.frame = self.feelingLabel.frame;
        self.feelingLabelButton.autoresizingMask = self.feelingLabel.autoresizingMask;
        [self.feelingLabelButton addTarget:self action:@selector(feelingLabelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [feelingLabelContainer addSubview:self.feelingLabelButton];
        self.imagesTableView.tableHeaderView = feelingLabelContainer;
        
        [wrapperScrollView addSubview:self.imagesTableView];
        [self addSubview:wrapperScrollView];
        
        if (debugging) {
            feelingLabelContainer.backgroundColor = [UIColor orangeColor];
            self.feelingLabel.backgroundColor = [UIColor redColor];
            self.imagesTableView.backgroundColor = [UIColor yellowColor];
        }
        
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
    [self.imagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"GalleryFeelingCell scrollViewDidScroll, contentOffset=%@", NSStringFromCGPoint(scrollView.contentOffset));
//}

- (void)setFeelingIndex:(NSInteger)feelingIndex {
    _feelingIndex = feelingIndex;
    self.imagesTableView.tag = self.feelingIndex;
    self.feelingLabelButton.tag = self.feelingIndex;
}

- (void)feelingLabelButtonTouched:(UIButton *)button {
    [self.delegate feelingCellLabelButtonTouched:self];
}

@end
