//
//  OpenGLView.m
//  OGL30301
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

OBJ *obj = NULL;
OBJMESH *objmesh = NULL;

#define OBJ_FILE (char *)"model.obj"

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

- (void)setupDepthBuffer
{
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, _depthRenderBuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    
}

- (void)destoryRenderAndFrameBuffer
{
    if (_colorRenderBuffer != 0) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
    
    if (_frameBuffer != 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_depthRenderBuffer != 0) {
        glDeleteFramebuffers(1, &_depthRenderBuffer);
        _depthRenderBuffer = 0;
    }
}

- (void)layoutSubviews {
    
    [self setupLayer];
    
    [self setupContext];
    
    
    
    [self destoryRenderAndFrameBuffer];
    
    [self setupRenderBuffer];
    
    [self setupFrameBuffer];
    
    [self setupDepthBuffer];
    
    [self initOpenGL];
    
    [self LoadShaders];

    [self LoadModels];
    
    [self Render];
}

- (void)initOpenGL
{
    glEnable( GL_DEPTH_TEST );
    glEnable( GL_CULL_FACE  );
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

- (void)LoadModels
{
    obj = OBJ_load(OBJ_FILE, 1);
    objmesh = &obj->objmesh[0];
    
    unsigned char *vertex_array = NULL,
    *vertex_start = NULL;
    
    unsigned int i = 0,
    index = 0,
    stride = 0,
    size = 0;

    size = objmesh->n_objvertexdata * (sizeof(vec3) + sizeof(vec3));
    vertex_array = (unsigned char *)malloc(size);
    vertex_start = vertex_array;
    
    while (i != objmesh->n_objvertexdata) {
        index = objmesh->objvertexdata[i].vertex_index;
        memcpy(vertex_array, &obj->indexed_vertex[index], sizeof(vec3));
        vertex_array += sizeof(vec3);
        memcpy(vertex_array, &obj->indexed_normal[index], sizeof(vec3));
        vertex_array += sizeof(vec3);
        
        i++;
    }

    glGenBuffers(1, &objmesh->vbo);
    glBindBuffer(GL_ARRAY_BUFFER, objmesh->vbo);
    glBufferData(GL_ARRAY_BUFFER, size, vertex_start, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    free(vertex_start);
    
    glGenBuffers(1, &objmesh->objtrianglelist[0].vbo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, objmesh->objtrianglelist[0].vbo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, objmesh->objtrianglelist[0].n_indice_array * sizeof(unsigned short), objmesh->objtrianglelist[0].indice_array, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    stride = sizeof(vec3) + sizeof(vec3);

    glGenVertexArraysOES(1, &objmesh->vao);
    glBindVertexArrayOES(objmesh->vao);

    glBindBuffer(GL_ARRAY_BUFFER, objmesh->vbo);

    glEnableVertexAttribArray(gProgram->attrib("vPosition"));
    glVertexAttribPointer(gProgram->attrib("vPosition"), 3, GL_FLOAT, GL_FALSE, stride, NULL);

    glEnableVertexAttribArray(gProgram->attrib("vColor"));
    glVertexAttribPointer(gProgram->attrib("vColor"), 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(sizeof(vec3)));

    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, objmesh->objtrianglelist[0].vbo);
    
    glBindVertexArrayOES(0);
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    
}

- (void)Render
{
    // clear everything
    glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // bind the program (the shaders)
    glUseProgram(gProgram->object());
    
    glm::mat4 model = glm::mat4();
//    static float z = 0.0f;
//    z -= 0.01f;
//    model = glm::translate(model, glm::vec3(0, 0, z));
//    float scale = 0.8;
//    model = glm::scale(model, glm::vec3(scale, scale, scale));
    model = glm::rotate(model, glm::radians(-90.0f), glm::vec3(1,0,0));
    gProgram->setUniform("model", model);
    
    // bind the VAO (the triangle)
    glBindVertexArrayOES(objmesh->vao);
    
    // draw the VAO
    glDrawElements(GL_TRIANGLES, objmesh->objtrianglelist[0].n_indice_array, GL_UNSIGNED_SHORT, (void *)NULL);
    
    // unbind the VAO
    glBindVertexArrayOES(0);
    
    // unbind the program
    glUseProgram(0);
    
    // swap the display buffers (displays what was just drawn)
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)Update: (float)secondsElapsed
{
    const GLfloat degreesPerSecond = 0;//180.0f;
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
