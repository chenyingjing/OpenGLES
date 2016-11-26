//
//  ViewController.h
//  Tutorial071
//
//  Created by aa64mac on 16/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet OpenGLView *openGLView;

- (IBAction)segmentSelectionChanged:(id)sender;


- (IBAction)lightXSliderValueChanged:(id)sender;
- (IBAction)lightYSliderValueChanged:(id)sender;
- (IBAction)lightZSliderValueChanged:(id)sender;

- (IBAction)ambientRSliderValueChanged:(id)sender;
- (IBAction)ambientGSliderValueChanged:(id)sender;
- (IBAction)ambientBSliderValueChanged:(id)sender;

- (IBAction)specularRSliderValueChanged:(id)sender;
- (IBAction)specularGSliderValueChanged:(id)sender;
- (IBAction)specularBSliderValueChanged:(id)sender;

- (IBAction)diffuseRSliderValueChanged:(id)sender;
- (IBAction)diffuseGSliderValueChanged:(id)sender;
- (IBAction)diffuseBSliderValueChanged:(id)sender;

- (IBAction)shininessSliderValueChanged:(id)sender;

@end

