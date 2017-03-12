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
#include "tdogl/Camera.h"
#include "ResourcePath/ResourcePath.hpp"
#define GLM_FORCE_RADIANS
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include "gfx/gfx.h"
#include <list>

OBJ *obj = NULL;
OBJMESH *objmesh = NULL;

extern void (*programBindAttribLocation)(GLuint);

#define OBJ_FILE (char *)"tree.obj"

struct ModelAsset {
    tdogl::Program* shaders;
    tdogl::Texture* texture;
    GLuint vbo;
    GLuint vao;
    GLenum drawType;
    GLint drawStart;
    GLint drawCount;
};

struct ModelInstance {
    ModelAsset* asset;
    glm::mat4 transform;
};


@interface OpenGLView() {
    tdogl::Program* gProgram;
    GLuint gVAO;
    GLuint gVBO;
    GLfloat gDegreesRotated;
    CADisplayLink * _displayLink;
    glm::mat4 _model;
    glm::mat4 projection;
    tdogl::Texture* gTexture;
    std::list<ModelInstance> gInstances;
    tdogl::Camera gCamera;
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
    
    [self LoadModels];
    
    [self Render];
}

- (void)initOpenGL
{
    glEnable( GL_DEPTH_TEST );
    glEnable( GL_CULL_FACE  );
    
    projection = glm::rotate(glm::mat4(), glm::radians(-90.0f), glm::vec3(0,0,1));
//    projection = glm::rotate(projection, glm::radians(-90.0f), glm::vec3(1,0,0));
//    projection = glm::mat4();
    _model = glm::mat4();
    
    gCamera.setFieldOfView(45.0f);
    gCamera.lookAt(glm::vec3(0, 0, 0));
    gCamera.setPosition(glm::vec3(2, 0, 7));
    gCamera.setViewportAspectRatio(self.frame.size.width / self.frame.size.height);
    gCamera.setNearAndFarPlanes(0.1, 5000);
}

- (tdogl::Program *)LoadShaders: (const char *)vShader fs:(const char *)fShader
{
    std::vector<tdogl::Shader> shaders;
    shaders.push_back(tdogl::Shader::shaderFromFile(ResourcePath(vShader, "glsl"), GL_VERTEX_SHADER));
    shaders.push_back(tdogl::Shader::shaderFromFile(ResourcePath(fShader, "glsl"), GL_FRAGMENT_SHADER));
    return new tdogl::Program(shaders);
}

void program_bind_attrib_location(GLuint pid) {
    glBindAttribLocation(pid, 0, "POSITION");
    glBindAttribLocation(pid, 1, "NORMAL");
    glBindAttribLocation(pid, 2, "TEXCOORD0");
}

- (ModelAsset *)LoadAsset:(float)dissolve
{
    ModelAsset *pAsset = new ModelAsset;//TODO: delete pAsset
    if (dissolve == 1.0f) {
        pAsset->shaders = [self LoadShaders:"VertexShader" fs:"SolidFragmentShader"];
    } else if (!dissolve) {
        pAsset->shaders = [self LoadShaders:"VertexShader" fs:"AlphaTestedFragmentShader"];
        NSLog(@"AlphaTestedFragmentShader");
    } else {
        pAsset->shaders = [self LoadShaders:"VertexShader" fs:"TransparentFragmentShader"];
    }
    return pAsset;
}

- (void)LoadModels
{
    obj = OBJ_load(OBJ_FILE, 1);
    
    unsigned int i = 0;
    while (i != obj->n_objmesh) {
        OBJ_build_mesh(obj, i);
        OBJ_free_mesh_vertex_data(obj, i);
        
        OBJMATERIAL *objmaterial = obj->objmesh[ i ].objtrianglelist[ 0 ].objmaterial;
        float dissolve = objmaterial->dissolve;

        programBindAttribLocation = program_bind_attrib_location;
        
        ModelInstance instance;
        instance.asset = [self LoadAsset: dissolve];
        
        gInstances.push_back(instance);
        NSLog(@"i:%d\tpid:%d", i, instance.asset->shaders->object());
        
        
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
        ++i;
    }
    NSLog(@"--------------------------");

    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
}

- (void)Render
{
//    static unsigned int start = get_milli_time(), fps = 0;
//    
//    if (get_milli_time() - start >= 1000) {
//        console_print("FPS: %d\n", fps);
//        start = get_milli_time();
//        fps = 0;
//    }
//    ++fps;
    
    // clear everything
    glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );

    unsigned int i = 0;
    std::list<ModelInstance>::const_iterator it;
    
    
    for(it = gInstances.begin(); it != gInstances.end(); ++it){
        OBJMATERIAL *objmaterial = obj->objmesh[ i ].objtrianglelist[ 0 ].objmaterial;
        if (objmaterial->dissolve == 1.0f) {
            [self RenderInstance:*it index: i];
        }
        ++i;
    }
    
    glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    
    i = 0;
    for(it = gInstances.begin(); it != gInstances.end(); ++it){
        OBJMATERIAL *objmaterial = obj->objmesh[ i ].objtrianglelist[ 0 ].objmaterial;
        if (objmaterial->dissolve < 1.0f) {
            
            glCullFace( GL_FRONT );
            [self RenderInstance:*it index: i];
            
            glCullFace( GL_BACK );
            [self RenderInstance:*it index: i];

        }
        ++i;
    }
    
    glDisable( GL_BLEND );
    
    // swap the display buffers (displays what was just drawn)
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void) RenderInstance: (const ModelInstance&)inst index:(unsigned int)mesh_index
{
    ModelAsset* asset = inst.asset;
    tdogl::Program* shaders = asset->shaders;
    
    //bind the shaders
    shaders->use();

    GLint samplerSlot = glGetUniformLocation(shaders->object(), "DIFFUSE");
    glUniform1i(samplerSlot, 7); //set to 7 because the texture will be bound to GL_TEXTURE7
    
    OBJMESH *objmesh = &obj->objmesh[ mesh_index ];
    glm::mat4 move = glm::mat4();
    move = glm::translate(move, glm::vec3(objmesh->location.x, objmesh->location.y, objmesh->location.z));
    move = move * _model;
    
    GLint modelSlot = glGetUniformLocation(shaders->object(), "model");
    glUniformMatrix4fv(modelSlot, 1, GL_FALSE, glm::value_ptr(move));
    
    GLint cameraSlot = glGetUniformLocation(shaders->object(), "camera");
    glUniformMatrix4fv(cameraSlot, 1, GL_FALSE, glm::value_ptr(gCamera.matrix()));
    
    GLint projectionSlot = glGetUniformLocation(shaders->object(), "projection");
    glUniformMatrix4fv(projectionSlot, 1, GL_FALSE, glm::value_ptr(projection));
    
    
    glActiveTexture(GL_TEXTURE7);

    
    glBindVertexArrayOES(objmesh->vao);
    
    unsigned int i = 0;
    
    while( i != objmesh->n_objtrianglelist )
    {
        objmesh->current_material = objmesh->objtrianglelist[ i ].objmaterial;
        
        //NSLog(@"i: %d ill: %d", i, objmesh->current_material->illumination_model);
        
        int lighting = objmesh->current_material->illumination_model ? 1 : 0;
        GLint lightingShaderSlot = glGetUniformLocation(shaders->object(), "LIGHTING_SHADER");
        glUniform1i(lightingShaderSlot, lighting);
        
        GLint dissolveSlot = glGetUniformLocation(shaders->object(), "DISSOLVE");
        glUniform1f(dissolveSlot, objmesh->current_material->dissolve);
        
        GLint ambientSlot = glGetUniformLocation(shaders->object(), "AMBIENT_COLOR");
        glUniform3fv(ambientSlot, 1, (float *)&objmesh->current_material->ambient);
        
        GLint diffuseSlot = glGetUniformLocation(shaders->object(), "DIFFUSE_COLOR");
        glUniform3fv(diffuseSlot, 1, (float *)&objmesh->current_material->diffuse);
        
        GLint specularSlot = glGetUniformLocation(shaders->object(), "SPECULAR_COLOR");
        glUniform3fv(specularSlot, 1, (float *)&objmesh->current_material->specular);
        
        GLint shininessSlot = glGetUniformLocation(shaders->object(), "SHININESS");
        glUniform1f(shininessSlot, objmesh->current_material->specular_exponent);
        
//        GLint modelviewMatrixSlot = glGetUniformLocation(shaders->object(), "MODELVIEWMATRIX");
//        glUniformMatrix4fv(modelviewMatrixSlot, 1, GL_FALSE, (float *)GFX_get_modelview_matrix());
        
//        GLint projectionMatrixSlot = glGetUniformLocation(shaders->object(), "PROJECTIONMATRIX");
//        glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (float *)GFX_get_projection_matrix());

        GLint normalMatrixSlot = glGetUniformLocation(shaders->object(), "NORMALMATRIX");
        glm::mat3 normalMatrix3 = glm::transpose(glm::inverse(glm::mat3(move)));
        glUniformMatrix3fv(normalMatrixSlot, 1, GL_FALSE, glm::value_ptr(normalMatrix3));
        
        GLint lightPositionSlot = glGetUniformLocation(shaders->object(), "LIGHTPOSITION");
//        vec3 position    = { 0.0f, -3.0f, 10.0f };
//        vec3 eyeposition = { 0.0f,  0.0f,  0.0f };
        
//        vec3_multiply_mat4( &eyeposition,
//                           &position,
//                           &gfx.modelview_matrix[ gfx.modelview_matrix_index - 1 ] );

        vec3 lightPosition    = { 0.0f, 4.0f, 2.0f };
        glUniform3fv( lightPositionSlot,
                     1,
                     (float *)&lightPosition );
        
        GLint eyePositionSlot = glGetUniformLocation(shaders->object(), "EYEPOSTITION");
        glUniform3fv( eyePositionSlot,
                     1,
                     glm::value_ptr(gCamera.position()) );
        
        
        TEXTURE *texture = objmesh->current_material->texture_diffuse;
        glBindTexture(texture->target, texture->tid);
        
        if( objmesh->vao )
        {
            if( objmesh->n_objtrianglelist != 1 )
            { glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, objmesh->objtrianglelist[ i ].vbo ); }
        }
        else
        { glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, objmesh->objtrianglelist[ i ].vbo ); }
        
        glDrawElements( objmesh->objtrianglelist[ i ].mode,
                       objmesh->objtrianglelist[ i ].n_indice_array,
                       GL_UNSIGNED_SHORT,
                       ( void * )NULL );
        
        ++i;
    }
    
    shaders->stopUsing();
}

- (void)Update: (float)secondsElapsed
{
    //move position of camera based on WASD keys
    const float moveSpeed = 2.0; //units per second
    if (self.backwardButton.highlighted){
        gCamera.offsetPosition(secondsElapsed * moveSpeed * -gCamera.forward());
    } else if (self.forwardButton.highlighted){
        gCamera.offsetPosition(secondsElapsed * moveSpeed * gCamera.forward());
    }
    if (self.leftButton.highlighted){
        gCamera.offsetPosition(secondsElapsed * moveSpeed * -gCamera.right());
    } else if (self.rightButton.highlighted){
        gCamera.offsetPosition(secondsElapsed * moveSpeed * gCamera.right());
    }
    if (self.downButton.highlighted){
        gCamera.offsetPosition(secondsElapsed * moveSpeed * -gCamera.up());
    } else if (self.upButton.highlighted){
        gCamera.offsetPosition(secondsElapsed * moveSpeed * gCamera.up());
    }
    
    const float mouseSensitivity = 0.1f;
    gCamera.offsetOrientation(mouseSensitivity * self.moveY, mouseSensitivity * self.moveX);
    
    float fieldOfView = 50;
    fieldOfView *= self.scale;
    if(fieldOfView < 5.0f) fieldOfView = 5.0f;
    if(fieldOfView > 130.0f) fieldOfView = 130.0f;
    gCamera.setFieldOfView(fieldOfView);

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
