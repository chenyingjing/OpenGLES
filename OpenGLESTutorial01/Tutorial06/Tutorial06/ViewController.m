//
//  ViewController.m
//  Tutorial06
//
//  Created by aa64mac on 12/11/2016.
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


- (IBAction)segmentSelectionChanged:(id)sender {
    UISegmentedControl * segment = (UISegmentedControl *)sender;
    int index = (int)[segment selectedSegmentIndex];
    
    [self.openGLView setCurrentSurface:index];
}
@end
