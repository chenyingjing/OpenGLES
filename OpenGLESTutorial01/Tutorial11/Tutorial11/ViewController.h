//
//  ViewController.h
//  Tutorial11
//
//  Created by aa64mac on 05/12/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLESMath.h"
#import "OpenGLView.h"

@interface ViewController : UIViewController


- (IBAction)lightXSliderValueChanged:(id)sender;
- (IBAction)lightYSliderValueChanged:(id)sender;
- (IBAction)lightZSliderValueChanged:(id)sender;
- (IBAction)diffuseRSliderValueChanged:(id)sender;
- (IBAction)diffuseGSliderValueChanged:(id)sender;
- (IBAction)diffuseBSliderValueChanged:(id)sender;
- (IBAction)diffuseASliderValueChanged:(id)sender;
- (IBAction)shininessSliderValueChanged:(id)sender;
- (IBAction)blendModeSliderValueChanged:(id)sender;
- (IBAction)texSegmentValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet OpenGLView *openGLView;
@property (weak, nonatomic) IBOutlet UILabel *blendModeLabel;

@end

