//
//  SendFeedbackViewController.h
//  Emotish
//
//  Created by Dan Bretl on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarView.h"

@interface SendFeedbackViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet TopBarView *topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * headerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *textViewContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView * textView;

@end
