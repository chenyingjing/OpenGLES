//
//  OpenGLView.h
//  Tutorial01
//
//  Created by aa64mac on 01/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "GLESUtils.h"
#include "ksMatrix.h"

@interface OpenGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _modelViewSlot;
    GLuint _projectionSlot;
    
    ksMatrix4 _modelViewMatrix;
    ksMatrix4 _projectionMatrix;
       
}

@property (nonatomic, assign) float rotateShoulder;
@property (nonatomic, assign) float rotateElbow;

- (void)render;
- (void)toggleDisplayLink;

@end
