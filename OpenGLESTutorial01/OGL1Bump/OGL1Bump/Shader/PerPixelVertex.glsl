

uniform mat4 projection;
uniform mat4 modelView;
uniform mat3 normalMatrix;

attribute vec4 vPosition;
attribute vec3 vNormal;
attribute vec4 vDiffuseMaterial;
attribute vec2 vTextureCoord;

varying vec3 vEyeSpaceNormal;
varying vec4 vDiffuse;
varying vec4 vPosInWorld;
varying vec2 vTextureCoordOut;

void main(void)
{
    gl_Position = projection * modelView * vPosition;
    
    vEyeSpaceNormal = normalMatrix * vNormal;
    vDiffuse = vDiffuseMaterial;
    vPosInWorld = modelView * vPosition;
    vTextureCoordOut = vTextureCoord;
}

