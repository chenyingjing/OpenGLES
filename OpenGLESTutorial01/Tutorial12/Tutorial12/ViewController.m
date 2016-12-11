//
//  ViewController.m
//  Tutorial12
//
//  Created by aa64mac on 11/12/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateBlendModeLabel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)blendModeSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    NSUInteger value = [slider value];
    [slider setValue:value];
    
    self.openGLView.blendMode = value;
    
    [self updateBlendModeLabel];
}

- (IBAction)alphaSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.a = value;
    
    self.openGLView.diffuse = diffuse;
}

- (IBAction)textureSegmentValueChanged:(id)sender {
    UISegmentedControl * seg = (UISegmentedControl *)sender;
    NSUInteger value = [seg selectedSegmentIndex];
    
    self.openGLView.textureIndex = value;
}

- (void)updateBlendModeLabel
{
    NSString * modeName = [self.openGLView currentBlendModeName];
    self.blendModeLabel.text = modeName;
}

@end
