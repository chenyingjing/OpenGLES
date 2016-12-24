//
//  ViewController.m
//  Tutorial14
//
//  Created by aa64mac on 18/12/2016.
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


- (IBAction)textureModeSegmentValueChanged:(id)sender {
    UISegmentedControl * segment = (UISegmentedControl *)sender;
    int value = (int)[segment selectedSegmentIndex];
    
    self.openglView.textureMode = value;
    
}
@end
