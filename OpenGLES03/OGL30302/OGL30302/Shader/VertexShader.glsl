uniform mat4 projection;
uniform mat4 camera;
uniform mat4 model;

attribute vec4 vPosition;
attribute vec3 vColor;
varying vec4 fColor;

void main(void)
{
    fColor = vec4((vColor + 1.0) * 0.5, 1.0);
    gl_Position = projection * camera * model * vPosition;
}

