
uniform mat4 projection;
uniform mat4 camera;
uniform mat4 model;

attribute mediump vec3 POSITION;
attribute mediump vec2 TEXCOORD0;
varying mediump vec2 texcoord0;

void main(void) {
    texcoord0 = TEXCOORD0;
    gl_Position = camera * projection * model * vec4(POSITION, 1.0);
}
