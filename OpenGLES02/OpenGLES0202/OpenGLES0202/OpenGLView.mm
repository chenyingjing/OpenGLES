//
//  OpenGLView.m
//  Tutorial01
//
//  Created by aa64mac on 01/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import "OpenGLView.h"

#include "Program.h"
#include "ResourcePath/ResourcePath.hpp"
#include "tdogl/Texture.h"
#include "common/thirdparty/stb_image/stb_image.h"

@interface OpenGLView() {
    tdogl::Program* gProgram;
    GLuint gVAO;
    GLuint gVBO;
    //tdogl::Texture* gTexture;
    GLuint gTex;
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
    
    [self LoadTexture];
    
    [self LoadShaders];

    [self LoadTriangle];
    
    [self Render];
}

- (void)LoadTexture
{
//    tdogl::Bitmap bmp = tdogl::Bitmap::bitmapFromFile(ResourcePath("hazard", "png"));
//    bmp.flipVertically();
//    gTexture = new tdogl::Texture(bmp);
//    
    std::string filePath = ResourcePath("hazard", "png");
    int width, height, channels;
    unsigned char* pixels = stbi_load(filePath.c_str(), &width, &height, &channels, 0);
    if (!pixels)
    {
        throw std::runtime_error(stbi_failure_reason());
    }
    unsigned long rowSize = channels *width;
    unsigned char* rowBuffer = new unsigned char[rowSize];
    unsigned halfRows = height / 2;
    
    for (unsigned rowIdx = 0; rowIdx < halfRows; ++rowIdx) {
        unsigned char* row = pixels + (rowIdx * width + 0) * channels;//GetPixelOffset(0, rowIdx, _width, _height, _format);
        unsigned char* oppositeRow = pixels + ((height - rowIdx - 1) * width + 0) * channels;//GetPixelOffset(0, _height - rowIdx - 1, _width, _height, _format);
        
        memcpy(rowBuffer, row, rowSize);
        memcpy(row, oppositeRow, rowSize);
        memcpy(oppositeRow, rowBuffer, rowSize);
    }
    
    delete[] rowBuffer;

    glGenTextures(1, &gTex);
    glBindTexture(GL_TEXTURE_2D, gTex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    GLint internalformat;
    switch (channels) {
        case 1: internalformat = GL_LUMINANCE; break;
        case 2: internalformat = GL_LUMINANCE_ALPHA; break;
        case 3: internalformat = GL_RGB; break;
        case 4: internalformat = GL_RGBA; break;
        default: throw std::runtime_error("Unrecognised Bitmap::Format");
    }
    
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 internalformat,
                 (GLsizei)width,
                 (GLsizei)height,
                 0,
                 internalformat,
                 GL_UNSIGNED_BYTE,
                 pixels);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    stbi_image_free(pixels);
}

- (void)LoadShaders
{
    std::vector<tdogl::Shader> shaders;
    shaders.push_back(tdogl::Shader::shaderFromFile(ResourcePath("VertexShader", "glsl"), GL_VERTEX_SHADER));
    shaders.push_back(tdogl::Shader::shaderFromFile(ResourcePath("FragmentShader", "glsl"), GL_FRAGMENT_SHADER));
    gProgram = new tdogl::Program(shaders);
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
        //  X     Y     Z       U     V
        0.0f, 0.8f, 0.0f,   0.5f, 1.0f,
        -0.8f,-0.8f, 0.0f,   0.0f, 0.0f,
        0.8f,-0.8f, 0.0f,   1.0f, 0.0f,
    };

    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);

    
    // connect the xyz to the "vert" attribute of the vertex shader
    glEnableVertexAttribArray(gProgram->attrib("vert"));
    glVertexAttribPointer(gProgram->attrib("vert"), 3, GL_FLOAT, GL_FALSE, 5*sizeof(GLfloat), NULL);
    
    glEnableVertexAttribArray(gProgram->attrib("vertTexCoord"));
    glVertexAttribPointer(gProgram->attrib("vertTexCoord"), 2, GL_FLOAT, GL_TRUE,  5*sizeof(GLfloat), (const GLvoid*)(3 * sizeof(GLfloat)));

    // unbind the VBO and VAO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    
}

- (void)Render
{
    // clear everything
    glClearColor(0, 0, 0, 1); // black
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // bind the program (the shaders)
    glUseProgram(gProgram->object());
    
    
    glActiveTexture(GL_TEXTURE0);
    //glBindTexture(GL_TEXTURE_2D, gTexture->object());
    glBindTexture(GL_TEXTURE_2D, gTex);
//    gProgram->setUniform("tex", 0);
    GLint samplerSlot = glGetUniformLocation(gProgram->object(), "tex");
    glUniform1i(samplerSlot, 0);
    
    // bind the VAO (the triangle)
    glBindVertexArrayOES(gVAO);
    
    // draw the VAO
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    // unbind the VAO
    glBindVertexArrayOES(0);
    
    // unbind the program
    glUseProgram(0);
    
    // swap the display buffers (displays what was just drawn)
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
