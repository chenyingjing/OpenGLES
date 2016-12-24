//
//  ViewController.h
//  Tutorial14
//
//  Created by aa64mac on 18/12/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

- (IBAction)textureModeSegmentValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet OpenGLView *openglView;


@end

