//
//  ViewController.h
//  Tutorial12
//
//  Created by aa64mac on 11/12/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

- (IBAction)blendModeSliderValueChanged:(id)sender;
- (IBAction)alphaSliderValueChanged:(id)sender;
- (IBAction)textureSegmentValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet OpenGLView *openGLView;

@property (weak, nonatomic) IBOutlet UILabel *blendModeLabel;

@end

