

uniform mat4 projection;
uniform mat4 modelView;
uniform mat3 normalMatrix;

attribute vec4 vPosition;
attribute vec3 vNormal;
attribute vec4 vDiffuseMaterial;

varying vec3 vEyeSpaceNormal;
varying vec4 vDiffuse;
varying vec4 vPosInWorld;

void main(void)
{
    gl_Position = projection * modelView * vPosition;
    
    vEyeSpaceNormal = normalMatrix * vNormal;
    vDiffuse = vDiffuseMaterial;
    vPosInWorld = modelView * vPosition;
}

