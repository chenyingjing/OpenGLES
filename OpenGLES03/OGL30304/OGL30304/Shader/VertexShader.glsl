uniform mat4 projection;
uniform mat4 camera;
uniform mat4 model;
uniform mat3 normalMatrix;
uniform vec3 LIGHTPOSITION;

attribute vec4 vPosition;
attribute vec3 vNormal;
varying vec4 fColor;

void main(void)
{
    mediump vec3 position = vec3(model * vPosition);
    vec3 normal = normalize(normalMatrix * vNormal);
    mediump vec3 lightdirection = normalize(LIGHTPOSITION - position);
    lowp float ndotl = max(dot(normal, lightdirection), 0.0);
    fColor = vec4(ndotl * vec3(1.0), 1.0) + vec4(0.1);

    gl_Position = projection * camera * model * vPosition;
}

