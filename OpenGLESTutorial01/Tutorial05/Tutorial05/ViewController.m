//
//  ViewController.m
//  Tutorial05
//
//  Created by aa64mac on 08/11/2016.
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


- (IBAction)OnShoulderSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    NSLog(@" >> current shoulder is %f", currentValue);
    
    self.openGLView.rotateShoulder = currentValue;
}

- (IBAction)OnElbowSliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    NSLog(@" >> current elbow is %f", currentValue);
    
    self.openGLView.rotateElbow = currentValue;
}

- (IBAction)OnRotateButtonClick:(id)sender {
    [self.openGLView toggleDisplayLink];
    
    UIButton * button = (UIButton *)sender;
    NSString * text = button.titleLabel.text;
    if ([text isEqualToString:@"Rotate"]) {
        [button setTitle: @"Stop" forState: UIControlStateNormal];
    }
    else {
        [button setTitle: @"Rotate" forState: UIControlStateNormal];
    }
}
@end
