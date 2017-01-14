//
//  ViewController.m
//  OpenGLES0204
//
//  Created by aa64mac on 10/01/2017.
//  Copyright © 2017 cyj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.openGLView.leftButton = self.leftButton;
    self.openGLView.backwardButton = self.backwardButton;
    self.openGLView.forwardButton = self.forwardButton;
    self.openGLView.rightButton = self.rightButton;
    self.openGLView.downButton = self.downButton;
    self.openGLView.upButton = self.upButton;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
