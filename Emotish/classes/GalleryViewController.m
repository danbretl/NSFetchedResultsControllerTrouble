//
//  GalleryViewController.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"
#import "GalleryConstants.h"
#import "GalleryFeelingCell.h"
#import "GalleryFeelingImageCell.h"

@interface GalleryViewController()
@property (strong, nonatomic) IBOutlet UITableView * feelingsTableView;
@end

@implementation GalleryViewController

@synthesize feelingsTableView=_feelingsTableView;
@synthesize activeFeelingCell=_activeFeelingCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        debugging = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"GalleryViewController self.view.frame = %@", NSStringFromCGRect(self.view.frame));
    
    self.feelingsTableView.rowHeight = GC_FEELING_IMAGE_SIDE_LENGTH + 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
    self.feelingsTableView.contentOffset = CGPointMake(0, 0);
    self.feelingsTableView.tag = -1;
    
    if (debugging) {
        self.feelingsTableView.backgroundColor = [UIColor greenColor];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"cellForRowAtIndexPath:%d-%d", indexPath.section, indexPath.row);
    
    if (tableView == self.feelingsTableView) {
        
        static NSString * FeelingCellID = @"FeelingCellID";
        
        GalleryFeelingCell * cell = (GalleryFeelingCell *)[tableView dequeueReusableCellWithIdentifier:FeelingCellID];
        if (cell == nil) {
            cell = [[GalleryFeelingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeelingCellID];
        }
        
        cell.feelingLabel.text = [NSString stringWithFormat:@"feel%ding", indexPath.row];
        cell.imagesTableView.delegate = self;
        cell.imagesTableView.dataSource = self;
        cell.imagesTableView.tag = indexPath.row;
        [cell.imagesTableView reloadData];
        cell.imagesTableView.contentOffset = CGPointMake(0, 0);
        
        if (indexPath.section == 0 && indexPath.row == 0) { self.activeFeelingCell = cell; }
        
        return cell;
        
    } else {
        
        static NSString * FeelingImageCellID = @"FeelingImageCellID";
        
        GalleryFeelingImageCell * cell = (GalleryFeelingImageCell *)[tableView dequeueReusableCellWithIdentifier:FeelingImageCellID];
        if (cell == nil) {
            cell = [[GalleryFeelingImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeelingImageCellID];
        }
        cell.feelingImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"protoImage%d.jpg", ((indexPath.row + tableView.tag) % 4) + 1]];
        // Customize cell...
        // ...
        // ...
        // ...
        
        return cell;
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrollView(%d)DidScroll, contentOffset=%@, \nisDecelerating=%d, isTracking=%d, isDragging=%d", scrollView.tag, NSStringFromCGPoint(scrollView.contentOffset), scrollView.isDecelerating, scrollView.isTracking, scrollView.isDragging);
    if (scrollView == self.feelingsTableView) {
        GalleryFeelingCell * oldActiveFeelingCell = self.activeFeelingCell;
        self.activeFeelingCell = nil;
//        NSLog(@"oldActiveFeelingCell.imagesTableView.contentOffset.y = %f", oldActiveFeelingCell.imagesTableView.contentOffset.y);
        if (oldActiveFeelingCell.imagesTableView.contentOffset.y > 0) {
            [oldActiveFeelingCell scrollToOriginAnimated:YES];
        } else {
            [oldActiveFeelingCell highlightLabel:NO];
        }
    } else {
        if (scrollView == self.activeFeelingCell.imagesTableView) {
//            if (scrollView.contentOffset.y == 0) {
//                [self.activeFeelingCell highlightLabel:NO];
//                self.activeFeelingCell = nil;
//            }
        } else {
            if (scrollView.isTracking) {
                GalleryFeelingCell * oldActiveFeelingCell = self.activeFeelingCell;
                self.activeFeelingCell = nil;
                if (oldActiveFeelingCell.imagesTableView.contentOffset.y > 0) {
                    [oldActiveFeelingCell scrollToOriginAnimated:YES];
                } else {
                    [oldActiveFeelingCell highlightLabel:NO];
                }
                self.activeFeelingCell = (GalleryFeelingCell *)scrollView.superview.superview; // Totally unsafe, based on insider knowledge that might become untrue at some point.
                [self.activeFeelingCell highlightLabel:YES];
                //            [self.activeFeelingCell highlightLabel:YES animated:YES];   
            }
        }
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.feelingsTableView) {
////        NSLog(@"feelingsTableView.contentOffset.y=%f", scrollView.contentOffset.y);
//        [self.activeFeelingImagesTableView setContentOffset:CGPointZero animated:YES];
//        self.activeFeelingImagesTableView = nil;
//    } else {
//        self.activeFeelingImagesTableView = scrollView;
////        NSLog(@"imagesTableView(%d).contentOffset.y=%f", scrollView.tag, scrollView.contentOffset.y);
//    }
//}

@end
