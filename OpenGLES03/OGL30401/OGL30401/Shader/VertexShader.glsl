/*
uniform mat4 projection;
uniform mat4 camera;
uniform mat4 model;
uniform sampler2D materialTex;

attribute vec2 vertTexCoord;
attribute vec4 vPosition;
varying vec4 fColor;


void main(void)
{    
    fColor = texture2D(materialTex, vertTexCoord);
    gl_Position = projection * camera * model * vPosition;
}
*/

uniform mediump mat4 MODELVIEWPROJECTIONMATRIX;
attribute mediump vec3 POSITION;
attribute mediump vec2 TEXCOORD0;
varying mediump vec2 texcoord0;

void main(void) {
    texcoord0 = TEXCOORD0;
    gl_Position = MODELVIEWPROJECTIONMATRIX * vec4(POSITION, 1.0);
}
