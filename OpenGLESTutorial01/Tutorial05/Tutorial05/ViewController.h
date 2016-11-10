//
//  ViewController.h
//  Tutorial05
//
//  Created by aa64mac on 08/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet OpenGLView *openGLView;
- (IBAction)OnShoulderSliderValueChanged:(id)sender;
- (IBAction)OnElbowSliderValueChanged:(id)sender;
- (IBAction)OnRotateButtonClick:(id)sender;

@end

