//
//  SubmitPhotoViewController.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubmitPhotoViewController.h"
#import "ViewConstants.h"

@implementation SubmitPhotoViewController
@synthesize topBar=_topBar, feelingTextField=_feelingTextField, photoView=_photoView, bottomBar=_bottomBar;
@synthesize feelingImage=_feelingImage, feelingWord=_feelingWord, userName=_userName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    // Do any additional setup after loading the view from its nib.
    
    self.photoView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT + PC_PHOTO_CELL_PADDING_BOTTOM);
    
//    self.feelingTextField.frame = CGRectMake(self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, cgrectgetmaxy, <#CGFloat width#>, <#CGFloat height#>)
    // THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE 
}

- (void)viewDidUnload
{
    [self setTopBar:nil];
    [self setFeelingTextField:nil];
    [self setBottomBar:nil];
    [self setPhotoView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
