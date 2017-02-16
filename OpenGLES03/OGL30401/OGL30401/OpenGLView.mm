//
//  OpenGLView.m
//  OGL30301
//
//  Created by aa64mac on 01/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#import "OpenGLView.h"

#include "tdogl/Program.h"
#include "tdogl/Texture.h"
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
    glm::mat4 _model;
    tdogl::Texture* gTexture;
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
    
    //[self LoadShaders];

    [self LoadModels];
    
    [self Render];
}

- (void)initOpenGL
{
    glEnable( GL_DEPTH_TEST );
    glEnable( GL_CULL_FACE  );
    
    _model = glm::mat4();
    _model = glm::rotate(_model, glm::radians(-90.0f), glm::vec3(1,0,0));
}

- (void)LoadShaders
{
    std::vector<tdogl::Shader> shaders;
    shaders.push_back(tdogl::Shader::shaderFromFile(ResourcePath("VertexShader"), GL_VERTEX_SHADER));
    shaders.push_back(tdogl::Shader::shaderFromFile(ResourcePath("FragmentShader"), GL_FRAGMENT_SHADER));
    gProgram = new tdogl::Program(shaders);
    
    gProgram->use();
        
//    glm::mat4 camera = glm::lookAt(glm::vec3(0,0,4), glm::vec3(0,0,0), glm::vec3(0,1,0));
//    gProgram->setUniform("camera", camera);
    
//    float aspect = self.frame.size.width/self.frame.size.height;
//    glm::mat4 projection = glm::perspective(glm::radians(45.0f), aspect, 0.1f, 100.0f);
//    gProgram->setUniform("projection", projection);
//    
    gProgram->stopUsing();
}

void program_bind_attrib_location(void *ptr) {
    PROGRAM *program = (PROGRAM *)ptr;
    
    glBindAttribLocation(program->pid, 0, "POSITION");
    glBindAttribLocation(program->pid, 2, "TEXCOORD0");
}

void material_draw_callback(void *ptr) {
    OBJMATERIAL *objmaterial = (OBJMATERIAL *)ptr;
    PROGRAM *program = objmaterial->program;
    unsigned int i = 0;
    while (i != program->uniform_count) {
        if (!strcmp(program->uniform_array[i].name, "DIFFUSE")) {
            glUniform1i(program->uniform_array[i].location, 1);
        } else if (!strcmp(program->uniform_array[i].name, "MODELVIEWPROJECTIONMATRIX")) {
            glUniformMatrix4fv(program->uniform_array[i].location, 1, GL_FALSE, (float *)GFX_get_modelview_projection_matrix());
        }
        
        
        i++;
    }
}

- (void)LoadModels
{
    GFX_set_matrix_mode(PROJECTION_MATRIX);
    GFX_load_identity();
    float aspect = self.frame.size.width/self.frame.size.height;
    GFX_set_perspective(45.0f, aspect, 0.1f, 100.0f, -90.0f);

    obj = OBJ_load(OBJ_FILE, 1);
    
    unsigned int i = 0;
    while (i != obj->n_objmesh) {
        OBJ_build_mesh(obj, i);
        OBJ_free_mesh_vertex_data(obj, i);
        ++i;
    }
    
    i = 0;
    while (i != obj->n_texture) {
        OBJ_build_texture(obj, i, obj->texture_path, TEXTURE_MIPMAP, TEXTURE_FILTER_2X, 0.0f);
        ++i;
    }
    
    i = 0;
    while (i != obj->n_objmaterial) {
        OBJ_build_material(obj, i, NULL);
        obj->objmaterial[i].program = PROGRAM_create((char *)"default", (char *)"VertexShader.glsl", (char *)"FragmentShader.glsl", 1, 1, program_bind_attrib_location, NULL);
        OBJ_set_draw_callback_material(obj, i, material_draw_callback);
        ++i;
    }
    

/*
    objmesh = &obj->objmesh[0];
    
    unsigned char *vertex_array = NULL,
    *vertex_start = NULL;
    
    unsigned int i = 0,
    index = 0,
    stride = 0,
    size = 0;

//    size = objmesh->n_objvertexdata * (sizeof(vec3) + sizeof(vec3) + sizeof(vec2));
    size = objmesh->n_objvertexdata * (sizeof(vec3) + sizeof(vec2));
    vertex_array = (unsigned char *)malloc(size);
    vertex_start = vertex_array;
    
    while (i != objmesh->n_objvertexdata) {
        index = objmesh->objvertexdata[i].vertex_index;
        
        memcpy(vertex_array, &obj->indexed_vertex[index], sizeof(vec3));
        vertex_array += sizeof(vec3);
        
//        memcpy(vertex_array, &obj->indexed_normal[index], sizeof(vec3));
//        vertex_array += sizeof(vec3);
        
        memcpy(vertex_array, &obj->indexed_uv[objmesh->objvertexdata[i].uv_index], sizeof(vec2));
        vertex_array += sizeof(vec2);
        
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
    
    stride = sizeof(vec3) + sizeof(vec2);

    glGenVertexArraysOES(1, &objmesh->vao);
    glBindVertexArrayOES(objmesh->vao);

    glBindBuffer(GL_ARRAY_BUFFER, objmesh->vbo);

    glEnableVertexAttribArray(gProgram->attrib("vPosition"));
    glVertexAttribPointer(gProgram->attrib("vPosition"), 3, GL_FLOAT, GL_FALSE, stride, NULL);

//    glEnableVertexAttribArray(gProgram->attrib("vNormal"));
//    glVertexAttribPointer(gProgram->attrib("vNormal"), 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(sizeof(vec3)));

    glEnableVertexAttribArray(gProgram->attrib("vertTexCoord"));
    glVertexAttribPointer(gProgram->attrib("vertTexCoord"), 2, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(sizeof(vec3)));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, objmesh->objtrianglelist[0].vbo);
    
    glBindVertexArrayOES(0);
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    
    char fname[ MAX_PATH ] = {""};
    get_file_path( getenv( "FILESYSTEM" ), fname );
    strcat( fname, obj->objmaterial[0].map_diffuse );
    
    tdogl::Bitmap bmp = tdogl::Bitmap::bitmapFromFile(fname);
    //bmp.flipVertically();
    gTexture = new tdogl::Texture(bmp);
*/
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
}

- (void)Render
{
    // clear everything
    glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
/*
    // bind the program (the shaders)
    glUseProgram(gProgram->object());
    
    
//    static float z = 0.0f;
//    z -= 0.01f;
//    model = glm::translate(model, glm::vec3(0, 0, z));
//    float scale = 0.8;
//    model = glm::scale(model, glm::vec3(scale, scale, scale));
//    _model = glm::rotate(_model, glm::radians(-90.0f), glm::vec3(1,0,0));
    gProgram->setUniform("model", _model);
    
//    glm::mat3 normalMatrix3 = glm::transpose(glm::inverse(glm::mat3(_model)));
//    gProgram->setUniform("normalMatrix", normalMatrix3);
    
//    gProgram->setUniform("LIGHTPOSITION", glm::vec3(10,0,3));
    
    GLint samplerSlot = glGetUniformLocation(gProgram->object(), "materialTex");
    glUniform1i(samplerSlot, 0); //set to 0 because the texture will be bound to GL_TEXTURE0

    //bind the texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, gTexture->object());
    
    // bind the VAO (the triangle)
    glBindVertexArrayOES(objmesh->vao);
    
    // draw the VAO
    glDrawElements(GL_TRIANGLES, objmesh->objtrianglelist[0].n_indice_array, GL_UNSIGNED_SHORT, (void *)NULL);
    
    // unbind the VAO
    glBindVertexArrayOES(0);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // unbind the program
    glUseProgram(0);
*/
    GFX_set_matrix_mode(MODELVIEW_MATRIX);
    GFX_load_identity();
    vec3 e = {0.0f, -6.0f, 1.35f},
    c = {0.0f, -5.0f, 1.35f},
    u = {0.0f, 0.0f, 1.0f};
//    vec3 e = {0.0f, 1.35f, -6.0f},
//    c = {0.0f, 1.35f, -5.0f},
//    u = {0.0f, 1.0f, 0.0f};
    GFX_look_at(&e, &c, &u);
    
    unsigned int i = 0;
    
    while (i != obj->n_objmesh) {
        
        GFX_push_matrix();
        GFX_translate(obj->objmesh[i].location.x,
                      obj->objmesh[i].location.y,
                      obj->objmesh[i].location.z);
        OBJ_draw_mesh(obj, i);
        
        GFX_pop_matrix();
        
        ++i;
    }
    
    // swap the display buffers (displays what was just drawn)
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)Update: (float)secondsElapsed
{
//    const GLfloat degreesPerSecond = 0;//180.0f;
//    gDegreesRotated += secondsElapsed * degreesPerSecond;
//    
//    //don't go over 360 degrees
//    while(gDegreesRotated > 360.0f) gDegreesRotated -= 360.0f;
    
    const float sensitivity = 0.008f;
    glm::mat4 r = glm::mat4();
    r = glm::rotate(r, self.moveX * sensitivity, glm::vec3(0,1,0));
    r = glm::rotate(r, self.moveY * sensitivity, glm::vec3(1,0,0));
    _model = r * _model;
    
    
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
