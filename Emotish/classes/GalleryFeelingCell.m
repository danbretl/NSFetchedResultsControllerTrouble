//
//  GalleryFeelingCell.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryFeelingCell.h"
#import "GalleryConstants.h"

@implementation GalleryFeelingCell

@synthesize imagesTableView=_imagesTableView;
@synthesize feelingLabel=_feelingLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        BOOL debugging = NO;
        
        CGFloat selfHeight = GC_FEELING_IMAGE_SIDE_LENGTH + 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
        CGFloat labelContainerWidth = GC_TABLE_WIDTH - (GC_FEELING_IMAGE_SIDE_LENGTH + GC_FEELING_IMAGE_MARGIN_RIGHT + floorf(GC_FEELING_IMAGE_SIDE_LENGTH * 0.2));
        CGFloat labelWidth = labelContainerWidth - (GC_FEELING_LABEL_MARGIN_LEFT + GC_FEELING_LABEL_MARGIN_RIGHT);
        
        UIScrollView * wrapperScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, GC_TABLE_WIDTH, selfHeight)]; // This fixes a bug where bouncing does not work from the edge of the table view.
        [self addSubview:wrapperScrollView];
        
        self.imagesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, selfHeight, GC_TABLE_WIDTH)];
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
        self.feelingLabel.textAlignment = UITextAlignmentRight;
        self.feelingLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        self.feelingLabel.text = @"feeling";
        self.feelingLabel.font = [UIFont boldSystemFontOfSize:36.0];
        self.feelingLabel.adjustsFontSizeToFitWidth = YES;
        UIView * feelingLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelContainerWidth, selfHeight)];
        feelingLabelContainer.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        [feelingLabelContainer addSubview:self.feelingLabel];
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

@end
