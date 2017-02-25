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
    // Do any additional setup after loading the view, typically from a nib.
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

@end
