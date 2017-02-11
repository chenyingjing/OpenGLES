//
//  OpenGLView.m
//  Tutorial01
//
//  Created by aa64mac on 01/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import "OpenGLView.h"

#include "tdogl/Program.h"
#include "ResourcePath/ResourcePath.hpp"
#define GLM_FORCE_RADIANS
#include <glm/gtc/matrix_transform.hpp>
#include "gfx/gfx.h"

@interface OpenGLView() {
    tdogl::Program* gProgram;
    GLuint gVAO;
    GLuint gVBO;
    GLfloat gDegreesRotated;
    CADisplayLink * _displayLink;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupRenderBuffer;
- (void)setupFrameBuffer;
- (void)destoryRenderAndFrameBuffer;

@end

@implementation OpenGLView

+ (Class)layerClass {
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer
{
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)layoutSubviews {
    
    [self setupLayer];
    
    [self setupContext];
    
    
    
    [self destoryRenderAndFrameBuffer];
    
    [self setupRenderBuffer];
    
    [self setupFrameBuffer];
    
    [self LoadShaders];

    [self LoadTriangle];
    
    [self Render];
}

- (void)LoadShaders
{
    std::vector<tdogl::Shader> shaders;
    shaders.push_back(tdogl::Shader::shaderFromFile(ResourcePath("VertexShader"), GL_VERTEX_SHADER));
    shaders.push_back(tdogl::Shader::shaderFromFile(ResourcePath("FragmentShader"), GL_FRAGMENT_SHADER));
    gProgram = new tdogl::Program(shaders);
    
    gProgram->use();
        
    glm::mat4 camera = glm::lookAt(glm::vec3(0,0,5), glm::vec3(0,0,0), glm::vec3(0,1,0));
    gProgram->setUniform("camera", camera);
    
    float aspect = self.frame.size.width/self.frame.size.height;
    glm::mat4 projection = glm::perspective(glm::radians(50.0f), aspect, 0.1f, 50.0f);
    gProgram->setUniform("projection", projection);
    
    gProgram->stopUsing();
}

- (void)LoadTriangle
{
    // make and bind the VAO
    glGenVertexArraysOES(1, &gVAO);
    glBindVertexArrayOES(gVAO);
    
    // make and bind the VBO
    glGenBuffers(1, &gVBO);
    glBindBuffer(GL_ARRAY_BUFFER, gVBO);
    
    // Put the three triangle verticies into the VBO
    GLfloat vertexData[] = {
        //  X     Y     Z       R     G     B     A
        -0.5f, -0.5f, 0.0f,     1.0f, 0.0f, 0.0f, 1.0f,
         0.5f, -0.5f, 0.0f,     0.0f, 1.0f, 0.0f, 1.0f,
        -0.5f,  0.5f, 0.0f,     0.0f, 0.0f, 1.0f, 1.0f,
         0.5f,  0.5f, 0.0f,     1.0f, 1.0f, 0.0f, 1.0f
    };
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);

    
    // connect the xyz to the "vert" attribute of the vertex shader
    glEnableVertexAttribArray(gProgram->attrib("vPosition"));
    glVertexAttribPointer(gProgram->attrib("vPosition"), 3, GL_FLOAT, GL_FALSE, sizeof(vertexData[0]) * 7, NULL);

    glEnableVertexAttribArray(gProgram->attrib("vColor"));
    glVertexAttribPointer(gProgram->attrib("vColor"), 4, GL_FLOAT, GL_FALSE, sizeof(vertexData[0]) * 7, (const GLvoid* )(sizeof(vertexData[0]) * 3));

    
    // unbind the VBO and VAO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    
}

- (void)Render
{
    // clear everything
    glClearColor(0.5, 0.5, 0.5, 1); // grey
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // bind the program (the shaders)
    glUseProgram(gProgram->object());
    
    glm::mat4 model = glm::mat4();
    static float z = 0.0f;
    z -= 0.01f;
    model = glm::translate(model, glm::vec3(0, 0, z));
    float scale = 0.8;
    model = glm::scale(model, glm::vec3(scale, scale, scale));
    model = glm::rotate(model, glm::radians(gDegreesRotated), glm::vec3(1,1,1));
    gProgram->setUniform("model", model);
    
    // bind the VAO (the triangle)
    glBindVertexArrayOES(gVAO);
    
    // draw the VAO
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // unbind the VAO
    glBindVertexArrayOES(0);
    
    // unbind the program
    glUseProgram(0);
    
    // swap the display buffers (displays what was just drawn)
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)Update: (float)secondsElapsed
{
    const GLfloat degreesPerSecond = 180.0f;
    gDegreesRotated += secondsElapsed * degreesPerSecond;
    
    //don't go over 360 degrees
    while(gDegreesRotated > 360.0f) gDegreesRotated -= 360.0f;
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    [self Update:displayLink.duration];
    
    [self Render];
}

- (void)toggleDisplayLink
{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        [_displayLink invalidate];
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        
        [self toggleDisplayLink];
        
    }
    
    return self;
}

@end
