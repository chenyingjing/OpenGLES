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

