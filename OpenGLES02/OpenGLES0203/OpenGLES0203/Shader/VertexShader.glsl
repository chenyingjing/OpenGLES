uniform mat4 projection;
uniform mat4 camera;
uniform mat4 model;

attribute vec3 vert;
attribute vec2 vertTexCoord;
varying vec2 fragTexCoord;

void main(void)
{
    fragTexCoord = vertTexCoord;
    
    gl_Position = projection * camera * model * vec4(vert, 1);
}

