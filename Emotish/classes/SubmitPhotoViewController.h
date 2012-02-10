//
//  SubmitPhotoViewController.h
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarView.h"
#import "PhotoView.h"

@interface SubmitPhotoViewController : UIViewController <UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField * feelingTextField;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView * photoView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView * bottomBar;

@property (strong, nonatomic) UIImage * feelingImage;
@property (strong, nonatomic) NSString * feelingWord;
@property (strong, nonatomic) NSString * userName;

@end