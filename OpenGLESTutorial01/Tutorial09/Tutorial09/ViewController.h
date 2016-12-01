//
//  ViewController.h
//  Tutorial09
//
//  Created by aa64mac on 29/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet OpenGLView *openGLView;


- (IBAction)segmentSelectionChanged:(id)sender;

@end

