//
//  ViewController.h
//  Tutorial03
//
//  Created by aa64mac on 06/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet OpenGLView *openGLView;

@property (weak, nonatomic) IBOutlet UISlider *posXSlider;
@property (weak, nonatomic) IBOutlet UISlider *posYSlider;
@property (weak, nonatomic) IBOutlet UISlider *posZSlider;

@property (weak, nonatomic) IBOutlet UISlider *rotateXSlider;
@property (weak, nonatomic) IBOutlet UISlider *scaleZSlider;


- (IBAction)xSliderValueChanged:(id)sender;
- (IBAction)ySliderValueChanged:(id)sender;
- (IBAction)zSliderValueChanged:(id)sender;

- (IBAction)rotateXSliderValueChanged:(id)sender;
- (IBAction)scaleZSliderValueChanged:(id)sender;

- (IBAction)autoButtonClick:(id)sender;
- (IBAction)resetButtonClick:(id)sender;

@end

