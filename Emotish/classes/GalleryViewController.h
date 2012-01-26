//
//  GalleryViewController.h
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryFeelingCell.h"

@interface GalleryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
    
    BOOL debugging;
    
}

@property (unsafe_unretained, nonatomic) GalleryFeelingCell * activeFeelingCell;
//@property (strong, nonatomic) NSMutableArray * activeFeelingCells;

@end
