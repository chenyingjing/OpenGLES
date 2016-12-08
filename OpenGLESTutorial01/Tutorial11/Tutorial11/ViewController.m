//
//  ViewController.m
//  Tutorial11
//
//  Created by aa64mac on 05/12/2016.
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


- (IBAction)lightXSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSVec3 pos = self.openGLView.lightPosition;
    pos.x = value;
    self.openGLView.lightPosition = pos;
}

- (IBAction)lightYSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSVec3 pos = self.openGLView.lightPosition;
    pos.y = value;
    self.openGLView.lightPosition = pos;
}

- (IBAction)lightZSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSVec3 pos = self.openGLView.lightPosition;
    pos.z = value;
    self.openGLView.lightPosition = pos;
}

- (IBAction)diffuseRSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.r = value;
    
    self.openGLView.diffuse = diffuse;
}

- (IBAction)diffuseGSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.g = value;
    
    self.openGLView.diffuse = diffuse;
}

- (IBAction)diffuseBSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.b = value;
    
    self.openGLView.diffuse = diffuse;
}

- (IBAction)diffuseASliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.a = value;
    
    self.openGLView.diffuse = diffuse;
}

- (IBAction)shininessSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.shininess = value;
}

- (IBAction)blendModeSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    int value = [slider value];
    [slider setValue:value];
    
    self.openGLView.blendMode = value;
    
    [self updateBlendModeLabel];
}

- (IBAction)texSegmentValueChanged:(id)sender {
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
