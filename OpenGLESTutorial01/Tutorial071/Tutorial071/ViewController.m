//
//  ViewController.m
//  Tutorial071
//
//  Created by aa64mac on 16/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    KSVec3 lightPosition;
    KSColor ambient;
    KSColor diffuse;
    KSColor specular;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lightPosition.x = 0;
    lightPosition.y = 0;
    lightPosition.z = 0;
    
    KSColor defaultValue = {0, 0, 0, 0};
    ambient = diffuse = specular = defaultValue;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)segmentSelectionChanged:(id)sender {
    UISegmentedControl * segment = (UISegmentedControl *)sender;
    int index = (int)[segment selectedSegmentIndex];
    
    [self.openGLView setCurrentSurface:index];
}

- (IBAction)lightXSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = [slider value];
    NSLog(@"lightX:%f", value);
    lightPosition.x = value;
    [self.openGLView setLightPosition:lightPosition];
}

- (IBAction)lightYSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = [slider value];
    NSLog(@"lightY:%f", value);
    lightPosition.y = value;
    [self.openGLView setLightPosition:lightPosition];
}

- (IBAction)lightZSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = [slider value];
    NSLog(@"lightZ:%f", value);
    lightPosition.z = value;
    [self.openGLView setLightPosition:lightPosition];
}

- (IBAction)ambientRSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"ambient red:%f", value);
    ambient.r = value;
    [self.openGLView setAmbient:ambient];
}

- (IBAction)ambientGSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"ambient green:%f", value);
    ambient.g = value;
    [self.openGLView setAmbient:ambient];
}

- (IBAction)ambientBSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"ambient blue:%f", value);
    ambient.b = value;
    [self.openGLView setAmbient:ambient];
}

- (IBAction)specularRSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"specular red:%f", value);
    specular.r = value;
    [self.openGLView setSpecular:specular];
}

- (IBAction)specularGSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"specular green:%f", value);
    specular.g = value;
    [self.openGLView setSpecular:specular];
}

- (IBAction)specularBSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"specular blue:%f", value);
    specular.b = value;
    [self.openGLView setSpecular:specular];
}

- (IBAction)diffuseRSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"diffuse red:%f", value);
    diffuse.r = value;
    [self.openGLView setDiffuse:diffuse];
}

- (IBAction)diffuseGSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"diffuse green:%f", value);
    diffuse.g = value;
    [self.openGLView setDiffuse:diffuse];
}

- (IBAction)diffuseBSliderValueChanged:(id)sender {
    float value = [(UISlider *)sender value];
    NSLog(@"diffuse blue:%f", value);
    diffuse.b = value;
    [self.openGLView setDiffuse:diffuse];
}

- (IBAction)shininessSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = [slider value];
    NSLog(@"shininess:%f", value);
    [self.openGLView setShininess:value];
}

@end
