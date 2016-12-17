//
//  OpenGLView.m
//  Tutorial06
//
//  Created by kesalin@gmail.com on 12-12-24.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"
#import "ParametricEquations.h"
#import "Quaternion.h"
#include "Cube.h"
#import "ModelSurface.h"
#import "ParametricEquations.h"

enum LightMode {
    PerVertex,
    PerPixel,
    PerPixelToon,
    PerPixelSelfShadowing
};
const enum LightMode CurrentLightMode = PerVertex;



//
// OpenGLView anonymous category
//
@interface OpenGLView()
{
    NSMutableArray * _vboArray;
    DrawableVBO * _currentVBO;
    
    ivec2 _fingerStart;
    Quaternion _orientation;
    Quaternion _previousOrientation;
    KSMatrix4 _rotationMatrix;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)setupProjection;

- (DrawableVBO *)createVBO:(int)surfaceType;
- (void)setupVBOs;
- (void)destoryVBOs;

- (ISurface *)createSurface:(int)surfaceType;
- (vec3) mapToSphere:(ivec2) touchpoint;
- (void)updateSurfaceTransform;
- (void)resetRotation;

@end

//
// OpenGLView implementation
//
@implementation OpenGLView

#pragma mark- Initilize GL

+ (Class)layerClass {
    // Support for OpenGL ES
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // Make CALayer visibale
    _eaglLayer.opaque = YES;
    
    // Set drawable properties
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext
{
    // Set OpenGL version, here is OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@" >> Error: Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // Set OpenGL context
    if (![EAGLContext setCurrentContext:_context]) {
        _context = nil;
        NSLog(@" >> Error: Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupBuffers
{
    // Setup color render buffer
    //
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    // Setup depth render buffer
    //
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    // Create a depth buffer & stencil buffer that has the same size as the color buffer.
    // NOTES:
    // In OpenGL ES 2.0 on iOS, you have to create a combined depth and stencil renderbuffer
    // using GL_DEPTH24_STENCIL8_OES, and then attach it to the bound framebuffer as both
    // GL_DEPTH_ATTACHMENT and GL_STENCIL_ATTACHMENT.
    //
    glGenRenderbuffers(1, &_depthStencilRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthStencilRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, width, height);
    
    // Setup frame buffer
    //
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // Attach color render buffer and depth render buffer to frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, _depthStencilRenderBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT,
                              GL_RENDERBUFFER, _depthStencilRenderBuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to setup framebuffer.");
    }
    
    //    // Create a depth buffer that has the same size as the color buffer.
    //    //
    //    glGenRenderbuffers(1, &_depthRenderBuffer);
    //    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    //    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    //
    //    // Create a stencil buffer.
    //    //
    //    glGenRenderbuffers(1, &_stencilRenderBuffer);
    //    glBindRenderbuffer(GL_RENDERBUFFER, _stencilRenderBuffer);
    //    glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8, width, height);
    //
    //    // Setup frame buffer
    //    //
    //    glGenFramebuffers(1, &_frameBuffer);
    //    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //
    //    // Attach color render buffer and depth render buffer to frameBuffer
    //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
    //                              GL_RENDERBUFFER, _colorRenderBuffer);
    //
    //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
    //                              GL_RENDERBUFFER, _depthRenderBuffer);
    //
    //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT,
    //                              GL_RENDERBUFFER, _stencilRenderBuffer);
    
    // Set color render buffer as current render buffer
    //
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    
}

- (void)destoryBuffers
{
    if (_colorRenderBuffer != 0) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
    
    if (_frameBuffer != 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_depthStencilRenderBuffer != 0) {
        glDeleteFramebuffers(1, &_depthStencilRenderBuffer);
        _depthStencilRenderBuffer = 0;
    }
}

- (void)cleanup
{
    [self destoryVBOs];
    
    [self destoryBuffers];
    
    if (_programHandle != 0) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
    if (_context && [EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    _context = nil;
}

- (void)setupProgram
{
    // Load shaders
    //
    
    NSString * vertexShaderPath = nil;
    NSString * fragmentShaderPath = nil;
    
    
    if (CurrentLightMode == PerVertex) {
        vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader"
                                                           ofType:@"glsl"];
        fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader"
                                                             ofType:@"glsl"];
    }
    else if (CurrentLightMode == PerPixelToon) {
        vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"PerPixelVertex"
                                                           ofType:@"glsl"];
        fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"PerPixelToonFragment"
                                                             ofType:@"glsl"];
    }
    else  {
        // default per-pixel light
        vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"PerPixelVertex"
                                                           ofType:@"glsl"];
        fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"PerPixelFragment"
                                                             ofType:@"glsl"];
    }
    
    _programHandle = [GLESUtils loadProgram:vertexShaderPath
                 withFragmentShaderFilepath:fragmentShaderPath];
    if (_programHandle == 0) {
        NSLog(@" >> Error: Failed to setup program.");
        return;
    }
    
    glUseProgram(_programHandle);
    
    [self getSlotsFromProgram];
}

#pragma mark

-(void)setupProjection
{
    // Generate a perspective matrix with a 60 degree FOV
    //
    float aspect = self.frame.size.width / self.frame.size.height;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksMatrixLoadIdentity(&_mirrorProjectionMatrix);
    
    ksPerspective(&_projectionMatrix, 60.0, aspect, 1.0f, 20.0f);
    ksCopyMatrix4(&_mirrorProjectionMatrix, &_projectionMatrix);
    ksScale(&_mirrorProjectionMatrix, 1.0, -1.0, 1.0);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    //glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
}

//const int SurfaceSphere = 0;
//const int SurfaceCone = 0;
//const int SurfaceTorus = 2;
//const int SurfaceTrefoilKnot = 3;
//const int SurfaceKleinBottle = 1;
//const int SurfaceMobiusStrip = 5;
//const int SurfaceCube = 0;

//const int SurfaceMaxCount = 7;
const int SurfaceMaxCount = 2;

- (ISurface *)createSurface:(int)type
{
    ISurface * surface = NULL;
    
    if (type == SurfaceKleinBottle) {
        surface = new KleinBottle(0.2);
    }
    else {
        surface = new Cone(0.1, 2.5);
    }
    
    return surface;
}

- (void)setCurrentSurface:(int)index
{
    index = index % [_vboArray count];
    _currentVBO = [_vboArray objectAtIndex:index];
    
    [self resetRotation];
    
    [self render];
}

- (DrawableVBO *)createVBO:(int)surfaceType
{
    ISurface * surface = [self createSurface:surfaceType];
    
    surface->SetVertexFlags(VertexFlagsNormals| VertexFlagsTexCoords);
    
    // Get vertice from surface.
    //
    int vertexSize = surface->GetVertexSize();
    int vBufSize = surface->GetVertexCount() * vertexSize;
    GLfloat * vbuf = new GLfloat[vBufSize];
    surface->GenerateVertices(vbuf);
    
    // Get triangle indice from surface
    //
    int triangleIndexCount = surface->GetTriangleIndexCount();
    unsigned short * triangleBuf = new unsigned short[triangleIndexCount];
    surface->GenerateTriangleIndices(triangleBuf);
    
    // Get line indice from surface
    //
    int lineIndexCount = surface->GetLineIndexCount();
    unsigned short * lineBuf = new unsigned short[lineIndexCount];
    surface->GenerateLineIndices(lineBuf);
    
    // Create the VBO for the vertice.
    //
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, vBufSize * sizeof(GLfloat), vbuf, GL_STATIC_DRAW);
    
    // Create the VBO for the line indice
    //
    GLuint lineIndexBuffer;
    glGenBuffers(1, &lineIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lineIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, lineIndexCount * sizeof(GLushort), lineBuf, GL_STATIC_DRAW);
    
    // Create the VBO for the triangle indice
    //
    GLuint triangleIndexBuffer;
    glGenBuffers(1, &triangleIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, triangleIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, triangleIndexCount * sizeof(GLushort), triangleBuf, GL_STATIC_DRAW);
    
    delete [] vbuf;
    delete [] lineBuf;
    delete [] triangleBuf;
    delete surface;
    
    DrawableVBO * vbo = [[DrawableVBO alloc] init];
    vbo.vertexBuffer = vertexBuffer;
    vbo.lineIndexBuffer = lineIndexBuffer;
    vbo.triangleIndexBuffer = triangleIndexBuffer;
    vbo.vertexSize = vertexSize;
    vbo.lineIndexCount = lineIndexCount;
    vbo.triangleIndexCount = triangleIndexCount;
    
    return vbo;
}

- (void)setupVBOs
{
    if (_vboArray == nil) {
        _vboArray = [[NSMutableArray alloc] init];
        
        DrawableVBO * vbo = [DrawableVBOFactory createDrawableVBO:SurfaceCone];
        [_vboArray addObject:vbo];
        vbo = nil;
        
        vbo = [DrawableVBOFactory createDrawableVBO:SurfaceKleinBottle];
        [_vboArray addObject:vbo];
        vbo = nil;
    }
}

- (void)destoryVBOs
{
    for (DrawableVBO * vbo in _vboArray) {
        [vbo cleanup];
    }
    _vboArray = nil;
    
    _currentVBO = nil;
}

- (void)resetRotation
{
    ksMatrixLoadIdentity(&_rotationMatrix);
    _previousOrientation.ToIdentity();
    _orientation.ToIdentity();
}

- (void)updateSurfaceTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -8);
    
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
    // Load the normal matrix.
    // It's orthogonal, so its Inverse-Transpose is itself!
    //
    KSMatrix3 normalMatrix3;
    ksMatrix4ToMatrix3(&normalMatrix3, &_modelViewMatrix);
    glUniformMatrix3fv(_normalMatrixSlot, 1, GL_FALSE, (GLfloat*)&normalMatrix3.m[0][0]);
    
    [self updateLights];
}

- (void)drawSurface:(DrawableVBO *)vbo
{
    if (vbo == nil)
        return;
    
    int stride = [vbo vertexSize] * sizeof(GLfloat);
    const GLvoid* normalOffset = (const GLvoid*)(3 * sizeof(GLfloat));
    const GLvoid* texCoordOffset = (const GLvoid*)(6 * sizeof(GLfloat));
    
    glBindBuffer(GL_ARRAY_BUFFER, [vbo vertexBuffer]);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, stride, 0);
    glVertexAttribPointer(_normalSlot, 3, GL_FLOAT, GL_FALSE, stride, normalOffset);
    
    glVertexAttribPointer(_textureCoordSlot, 2, GL_FLOAT, GL_FALSE, stride, texCoordOffset);
    
    // Update textures for stage 0
    //
    //    if (_textures != NULL) {
    //        glActiveTexture(GL_TEXTURE1);
    //        glBindTexture(GL_TEXTURE_2D, _textures[_textureIndex]);
    //        [self updateTextureParameter];
    //    }
    
    // Draw the triangles.
    //
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [vbo triangleIndexBuffer]);
    glDrawElements(GL_TRIANGLES, [vbo triangleIndexCount], GL_UNSIGNED_SHORT, 0);
    
    
}

- (void)render
{
    if (_context == nil)
        return;
    
    const float mirrorY = -1.5f;
    const float objectY = 2.5f;
    
    DrawableVBO *mirror = [_vboArray objectAtIndex:0];
    DrawableVBO *object = [_vboArray objectAtIndex:1];
    
    GLuint mirrorTexture = _textures[0];
    GLuint objectTexture = _textures[1];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    //    [self updateSurfaceTransform];
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -8);
    ksRotate(&_modelViewMatrix, 30, 1, 0, 0);
    
    
    glDisable(GL_TEXTURE_2D);
    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_ALWAYS, 0xff, 0xff);
    glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
    
    glDepthMask(GL_FALSE);
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    
    ksTranslate(&_modelViewMatrix, 0.0, mirrorY, 0.0);
    
    [self disableLight:YES disableTexture:YES];
    [self updateTransform:&_projectionMatrix modelView:&_modelViewMatrix];
    [self drawSurface:mirror];
    
    
    
    ksTranslate(&_modelViewMatrix, 0.0, -mirrorY, 0.0);
    
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_TRUE);
    glEnable(GL_TEXTURE_2D);
    
    
    // Render the reflection floating object.
    //
    glStencilFunc(GL_EQUAL, 0xff, 0xff);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    glBindTexture(GL_TEXTURE_2D, objectTexture);
    
    ksTranslate(&_modelViewMatrix, 0, objectY, 0);
    KSMatrix4 reflectionModelView;
    ksCopyMatrix4(&reflectionModelView, &_modelViewMatrix);
    ksMatrixMultiply(&reflectionModelView, &_rotationMatrix, &reflectionModelView);
    
    _diffuse.r = _diffuse.g = _diffuse.b = 0.4;
    _diffuse.a = 0.6;
    [self updateLights];
    
    glBindTexture(GL_TEXTURE_2D, objectTexture);
    [self disableLight:NO disableTexture:NO];
    [self updateTransform:&_mirrorProjectionMatrix modelView:&reflectionModelView];
    [self drawSurface:object];

    
    
    glDisable(GL_STENCIL_TEST);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    // Render the floating object.
    //
    _diffuse.r = _diffuse.g = _diffuse.b = 1.0;
    _diffuse.a = 0.0;
    [self updateLights];
    
    KSMatrix4 knotModelView;
    ksCopyMatrix4(&knotModelView, &_modelViewMatrix);
    ksMatrixMultiply(&knotModelView, &_rotationMatrix, &knotModelView);
    [self updateTransform:&_projectionMatrix modelView:&knotModelView];
    [self drawSurface:object];
    
    
    
    // Render the mirror with front-to-back blending.
    //
    glEnable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, mirrorTexture);
//    glBlendFuncSeparate(GL_DST_ALPHA, GL_ONE,                   // RGB factors
//                        GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);    // Alpha factors
//    glBlendFuncSeparate(GL_ZERO, GL_ONE,                   // RGB factors
//                        GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);    // Alpha factors
//    glBlendFunc(GL_ZERO, GL_ONE);
//    glBlendFunc(GL_ONE, GL_ZERO);
    glBlendFunc(GL_ONE, GL_ONE);
    glBlendEquation(GL_FUNC_SUBTRACT);
    //glBlendEquationSeparate(GL_FUNC_SUBTRACT, GL_FUNC_SUBTRACT);
    
    ksTranslate(&_modelViewMatrix, 0, mirrorY - objectY, 0);
    [self disableLight:YES disableTexture:NO];
    [self updateTransform:&_projectionMatrix modelView:&_modelViewMatrix];
    [self drawSurface:mirror];
    
    glDisable(GL_BLEND);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
        [self setupProjection];
        [self setupLights];
        [self setupTextures];
        
        [self resetRotation];
        
        //_vboArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    glUseProgram(_programHandle);
    
    [self destoryBuffers];
    
    [self setupBuffers];
    
    [self setupVBOs];
    
    [self render];
}

#pragma mark

#pragma mark - Touch events

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    
    _fingerStart = ivec2(location.x, location.y);
    _previousOrientation = _orientation;
}

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    ivec2 touchPoint = ivec2(location.x, location.y);
    
    vec3 start = [self mapToSphere:_fingerStart];
    vec3 end = [self mapToSphere:touchPoint];
    Quaternion delta = Quaternion::CreateFromVectors(start, end);
    _orientation = delta.Rotated(_previousOrientation);
    _orientation.ToMatrix4(&_rotationMatrix);
    
    [self render];
}

- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    ivec2 touchPoint = ivec2(location.x, location.y);
    
    vec3 start = [self mapToSphere:_fingerStart];
    vec3 end = [self mapToSphere:touchPoint];
    Quaternion delta = Quaternion::CreateFromVectors(start, end);
    _orientation = delta.Rotated(_previousOrientation);
    _orientation.ToMatrix4(&_rotationMatrix);
    
    [self render];
}

- (vec3) mapToSphere:(ivec2) touchpoint
{
    ivec2 centerPoint = ivec2(self.frame.size.width/2, self.frame.size.height/2);
    float radius = self.frame.size.width/3;
    float safeRadius = radius - 1;
    
    vec2 p = touchpoint - centerPoint;
    
    // Flip the Y axis because pixel coords increase towards the bottom.
    p.y = -p.y;
    
    if (p.Length() > safeRadius) {
        float theta = atan2(p.y, p.x);
        p.x = safeRadius * cos(theta);
        p.y = safeRadius * sin(theta);
    }
    
    float z = sqrt(radius * radius - p.LengthSquared());
    vec3 mapped = vec3(p.x, p.y, z);
    return mapped / radius;
}

#pragma mark


-(void)setAmbient:(KSColor)ambient
{
    _ambient = ambient;
    [self render];
}

-(void)setSpecular:(KSColor)specular
{
    _specular = specular;
    [self render];
}

- (void)setLightPosition:(KSVec3)lightPosition
{
    _lightPosition = lightPosition;
    [self render];
}

-(void)setDiffuse:(KSColor)diffuse
{
    _diffuse = diffuse;
    [self render];
}

-(void)setShininess:(GLfloat)shininess
{
    _shininess = shininess;
    [self render];
}

- (void)getSlotsFromProgram
{
    // Get the attribute and uniform slot from program
    //
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    _normalMatrixSlot = glGetUniformLocation(_programHandle, "normalMatrix");
    _lightPositionSlot = glGetUniformLocation(_programHandle, "vLightPosition");
    _ambientSlot = glGetUniformLocation(_programHandle, "vAmbientMaterial");
    _specularSlot = glGetUniformLocation(_programHandle, "vSpecularMaterial");
    _shininessSlot = glGetUniformLocation(_programHandle, "shininess");
    
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _normalSlot = glGetAttribLocation(_programHandle, "vNormal");
    _diffuseSlot = glGetAttribLocation(_programHandle, "vDiffuseMaterial");
    
    _textureCoordSlot = glGetAttribLocation(_programHandle, "vTextureCoord");
    _sampler0Slot = glGetUniformLocation(_programHandle, "Sampler0");
    _sampler1Slot = glGetUniformLocation(_programHandle, "Sampler1");
    //_samplerSlot = glGetUniformLocation(_programHandle, "Sampler");
    _blendModeSlot = glGetUniformLocation(_programHandle, "BlendMode");
    _alphaSlot = glGetUniformLocation(_programHandle, "Alpha");
    
    _disableTextureSlot = glGetUniformLocation(_programHandle, "disableTexture");
    _disableLightSlot = glGetUniformLocation(_programHandle, "disableLight");
    
}

- (void)setupLights
{
    // Initialize various state.
    //
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_normalSlot);
    
    // Set up some default material parameters.
    //
    _lightPosition.x = _lightPosition.y = 1.0;
    _lightPosition.z = 5.0;
    
    _ambient.r = _ambient.g = _ambient.b = 0.04;
    _specular.r = _specular.g = _specular.b = 0.5;
    _diffuse.r = 0.8;
    _diffuse.g = 0.8;
    _diffuse.b = 0.8;
    
    _shininess = 10;
    _blendMode = 0;
}

- (void)updateLights
{
    glUniform1i(_blendModeSlot, (GLint)_blendMode);
    glUniform3f(_lightPositionSlot, _lightPosition.x, _lightPosition.y, _lightPosition.z);
    glUniform4f(_ambientSlot, _ambient.r, _ambient.g, _ambient.b, _ambient.a);
    glUniform4f(_specularSlot, _specular.r, _specular.g, _specular.b, _specular.a);
    glVertexAttrib4f(_diffuseSlot, _diffuse.r, _diffuse.g, _diffuse.b, _diffuse.a);
    glUniform1f(_shininessSlot, _shininess);
    glUniform1f(_alphaSlot, _diffuse.a);
}

- (void)updateTextureParameter
{
    // It can be GL_NICEST or GL_FASTEST or GL_DONT_CARE. GL_DONT_CARE by default.
    //
    glHint(GL_GENERATE_MIPMAP_HINT, GL_NICEST);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _filterMode);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _filterMode);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _wrapMode);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _wrapMode);
}

- (void)setupTextures
{
    NSArray * textureFiles = [NSArray arrayWithObjects:
                              @"detail.png",
                              @"wooden.png",
                              nil];
    _textureCount = [textureFiles count];
    _textures = new GLuint[_textureCount];
    
    // Load texture for stage 0
    //
    glActiveTexture(GL_TEXTURE0);
    
    for (NSUInteger i = 0; i < _textureCount; i++) {
        NSString * file = [textureFiles objectAtIndex:i];
        _textures[i] = [TextureHelper createTexture:file isPVR:FALSE];
    }
    
    _textureIndex = 0;              // Current texture index for texture stage 1
    
    glUniform1i(_sampler0Slot, 0);  // texture stage 0
    glEnableVertexAttribArray(_textureCoordSlot);   // Enable texture coord
    
}

-(void)setTextureIndex:(NSUInteger)textureIndex
{
    _textureIndex = textureIndex % _textureCount;
    [self render];
}

-(void)setWrapMode:(GLint)wrapMode
{
    if (wrapMode == 0) {
        _wrapMode = GL_REPEAT;
    }
    else if (wrapMode == 1) {
        _wrapMode = GL_CLAMP_TO_EDGE;
    }
    else {
        _wrapMode = GL_MIRRORED_REPEAT;
    }
    
    [self render];
}

-(void)setFilterMode:(GLint)filterMode
{
    if (filterMode == 0) {
        _filterMode = GL_LINEAR;
    }
    else if (filterMode == 1) {
        _filterMode = GL_NEAREST;
    }
    else if (filterMode == 2){
        _filterMode = GL_LINEAR_MIPMAP_NEAREST;
    }
    else if (filterMode == 3){
        _filterMode = GL_NEAREST_MIPMAP_LINEAR;
    }
    else if (filterMode == 4){
        _filterMode = GL_LINEAR_MIPMAP_LINEAR;
    }
    else {
        _filterMode = GL_NEAREST_MIPMAP_NEAREST;
    }
    
    [self render];
}

-(void)setBlendMode:(NSUInteger)blendMode
{
    _blendMode = blendMode;
    [self render];
}

-(NSString *)currentBlendModeName
{
    const NSArray * nameList = [NSArray arrayWithObjects:
                                @"0 Multiply",
                                @"1 Add",
                                @"2 Subtract",
                                @"3 Darken",
                                @"4 Color Burn",
                                @"5 Linear Burn",
                                @"6 Lighten",
                                @"7 Screen",
                                @"8 Color Dodge",
                                @"9 Overlay",
                                @"10 Soft Light",
                                @"11 Hard Light",
                                @"12 Vivid Light",
                                @"13 Linear Light",
                                @"14 Pin Light",
                                @"15 Difference",
                                @"16 Exclusion",
                                @"17 Interpolate",
                                @"18 Add Signed",
                                nil];
    
    NSUInteger index = _blendMode % [nameList count];
    NSString * name = [nameList objectAtIndex:index];
    return name;
}

- (void)updateTransform:(const KSMatrix4 *)projection modelView:(const KSMatrix4 *) modelView
{
    // Load the projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&(projection->m[0][0]));
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&(modelView->m[0][0]));
    
    // Load the normal matrix.
    // It's orthogonal, so its Inverse-Transpose is itself!
    //
    KSMatrix3 normalMatrix3;
    ksMatrix4ToMatrix3(&normalMatrix3, modelView);
    glUniformMatrix3fv(_normalMatrixSlot, 1, GL_FALSE, (GLfloat*)&normalMatrix3.m[0][0]);
}

- (void)disableLight:(Boolean)disableLight disableTexture:(Boolean)disableTexture
{
    glUniform1i(_disableLightSlot, (disableLight ? 1 : 0));
    glUniform1i(_disableTextureSlot, (disableTexture ? 1 : 0));
}

@end
