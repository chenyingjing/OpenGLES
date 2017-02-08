uniform mat4 projection;
uniform mat4 camera;
uniform mat4 model;

attribute vec4 vPosition;
attribute vec4 vColor;
varying vec4 fColor;

void main(void)
{
    fColor = vColor;
    gl_Position = projection * camera * model * vPosition;
}

