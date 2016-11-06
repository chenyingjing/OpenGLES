//
//  ViewController.m
//  Tutorial03
//
//  Created by aa64mac on 06/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)xSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    _openGLView.posX = currentValue;
    
    NSLog(@" >> current x is %f", currentValue);
}

- (IBAction)ySliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    _openGLView.posY = currentValue;
    
    NSLog(@" >> current y is %f", currentValue);
}

- (IBAction)zSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    _openGLView.posZ = currentValue;
    
    NSLog(@" >> current z is %f", currentValue);
}

- (IBAction)rotateXSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    self.openGLView.rotateX = currentValue;
    
    NSLog(@" >> current x rotation is %f", currentValue);
}

- (IBAction)scaleZSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    _openGLView.scaleZ = currentValue;
    
    NSLog(@" >> current z scale is %f", currentValue);
}

- (IBAction)autoButtonClick:(id)sender {
    [self.openGLView toggleDisplayLink];
    
    UIButton * button = (UIButton *)sender;
    NSString * text = button.titleLabel.text;
    if ([text isEqualToString:@"Auto"]) {
        [button setTitle: @"Stop" forState: UIControlStateNormal];
    }
    else {
        [button setTitle: @"Auto" forState: UIControlStateNormal];
    }
}

- (IBAction)resetButtonClick:(id)sender {
    [self.openGLView resetTransform];
    [self.openGLView render];
    
    [self resetControls];
}

- (void)resetControls
{
    [_posXSlider setValue:self.openGLView.posX];
    [_posYSlider setValue:self.openGLView.posY];
    [_posZSlider setValue:self.openGLView.posZ];
    
    [_scaleZSlider setValue:self.openGLView.scaleZ];
    [_rotateXSlider setValue:self.openGLView.rotateX];
}

@end
