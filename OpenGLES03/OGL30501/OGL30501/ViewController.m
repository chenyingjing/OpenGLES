//
//  ViewController.m
//  OpenGLES0201
//
//  Created by aa64mac on 02/01/2017.
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
    
    self.openGLView.scale = 1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)panAction:(UIPanGestureRecognizer *)sender {
    CGPoint position = [sender translationInView:self.view];
    
    self.openGLView.moveX = position.x;
    self.openGLView.moveY = position.y;
    
    [sender setTranslation:CGPointZero inView:self.view];
}

- (IBAction)pinchAction:(UIPinchGestureRecognizer *)sender {
    self.openGLView.scale = sender.scale;
}

@end
