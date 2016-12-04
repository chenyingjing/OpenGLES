//
//  ViewController.h
//  Tutorial10
//
//  Created by aa64mac on 03/12/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet OpenGLView *openGLView;

- (IBAction)textureSegmentSelectionChanged:(id)sender;
- (IBAction)wrapSegmentSelectionChanged:(id)sender;
- (IBAction)filterSegmentSelectionChanged:(id)sender;
- (IBAction)surfaceSegmentSelectionChanged:(id)sender;


@end

