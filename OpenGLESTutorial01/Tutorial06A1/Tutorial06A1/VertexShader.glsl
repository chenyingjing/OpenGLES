uniform mat4 projection;
attribute vec4 vPosition;

void main(void)
{
    gl_Position = projection * vPosition;
}

