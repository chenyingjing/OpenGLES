//
//  OpenGLView.h
//  Tutorial06
//
//  Created by kesalin@gmail.com on 12-12-24.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "GLESMath.h"
#import "TextureHelper.h"

@interface DrawableVBO : NSObject

@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint lineIndexBuffer;
@property (nonatomic, assign) GLuint triangleIndexBuffer;
@property (nonatomic, assign) int vertexSize;
@property (nonatomic, assign) int lineIndexCount;
@property (nonatomic, assign) int triangleIndexCount;

- (void) cleanup;

@end

@interface OpenGLView : UIView 
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _modelViewSlot;
    GLuint _projectionSlot;
    //GLuint _colorSlot;
    GLuint _normalMatrixSlot;
    GLuint _lightPositionSlot;
    
    GLint _normalSlot;
    GLint _tangentSlot;
    GLint _ambientSlot;
    GLint _diffuseSlot;
    GLint _specularSlot;
    GLint _shininessSlot;
    
    // For texture
    //
    NSUInteger _textureCount;
//    GLuint * _textures;
    GLuint _textureSampler;
    GLuint _textureBump;
    
    GLint _textureCoordSlot;
    GLint _samplerSlot;
    GLint _bumpSlot;
    GLint _wrapMode;
    GLint _filterMode;
    NSUInteger _textureIndex;
    
    KSMatrix4 _modelViewMatrix;
    KSMatrix4 _projectionMatrix;
    
//    KSVec3 _lightPosition;
//    KSColor _ambient;
//    KSColor _diffuse;
//    KSColor _specular;
//    
//    GLfloat _shininess;
}

- (void)render;
- (void)cleanup;

- (void)setCurrentSurface:(int)index;

@property (nonatomic, assign) KSVec3 lightPosition;
@property (nonatomic, assign) KSColor ambient;
@property (nonatomic, assign) KSColor diffuse;
@property (nonatomic, assign) KSColor specular;
@property (nonatomic, assign) GLfloat shininess;

@end
