//
//  AboutTeamMemberCell.m
//  Emotish
//
//  Created by Dan Bretl on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutTeamMemberCell.h"
#import "ViewConstants.h"
#import "UIColor+Emotish.h"

const CGFloat ATMC_PADDING_TOP = 0.0;

@implementation AboutTeamMemberCell
//@synthesize headerButton=_headerButton;
@synthesize photoView=_photoView, linksView=_linksView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.photoView = [[PhotoView alloc] initWithFrame:CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, ATMC_PADDING_TOP, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT + PC_PHOTO_CELL_PADDING_BOTTOM)];
        self.photoView.photoImageView.clipsToBounds = YES;
        self.photoView.userInteractionEnabled = YES;
        self.photoView.photoCaptionTextField.textColor = [UIColor feelingColor];
        self.photoView.actionButtonsEnabled = NO;
        [self.photoView showInfo:NO animated:NO];
        [self addSubview:self.photoView];

//        self.headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.headerButton.frame = CGRectMake(0, 0, 320, CGRectGetMinY(self.photoView.frame));
//        self.headerButton.contentEdgeInsets = UIEdgeInsetsMake(0, self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, PC_PHOTO_CELL_MARGIN_TOP, 320 - (CGRectGetMaxX(self.photoView.frame) - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL));
//        [self.headerButton setTitleColor:[UIColor userColor] forState:UIControlStateNormal];
//        [self.headerButton setTitleColor:[UIColor userColor] forState:UIControlStateHighlighted];
//        self.headerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        self.headerButton.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
//        [self addSubview:self.headerButton];
        
        self.linksView = [[AboutLinksView alloc] initWithFrame:CGRectMake(self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, CGRectGetMaxY(self.photoView.frame), PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, 0)];
        [self addSubview:self.linksView];
        
        // Debugging
//        self.photoView.photoImageView.image = [UIImage imageNamed:@"photo_image_placeholder.png"];
//        self.photoView.photoCaptionTextField.text = @"loves the color orange";
////        [self.headerButton setTitle:@"danbretl" forState:UIControlStateNormal];
//        [self.linksView addLinkButtonWithText:@"@danbretl" target:nil selector:NULL];
//        [self.linksView addLinkButtonWithText:@"danbretl@redrawnlabs.com" target:nil selector:NULL];
                
    }
    return self;
}

//+ (CGFloat)fixedHeight {
//    return (ATMC_PADDING_TOP) + (PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT + PC_PHOTO_CELL_PADDING_BOTTOM) + (50);
//}

@end
