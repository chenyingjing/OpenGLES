
uniform bool LIGHTING_SHADER;

uniform mediump vec3 LIGHTPOSITION;

uniform lowp vec3 AMBIENT_COLOR;

uniform lowp vec3 DIFFUSE_COLOR;

uniform lowp vec3 SPECULAR_COLOR;

uniform mediump float SHININESS;

uniform lowp float DISSOLVE;

varying mediump vec3 position;

varying lowp vec3 normal;

uniform mediump vec3 EYEPOSTITION;

uniform samplerCube samplerForCube;
uniform sampler2D DIFFUSE;

varying mediump vec2 texcoord0;
varying mediump vec3 cubeTexCoord0;

uniform mediump int textureMode;

void main( void )
{
//    lowp vec4 diffuse_color = texture2D( DIFFUSE, texcoord0 );
//
    if (textureMode == 0) {
        gl_FragColor = textureCube(samplerForCube, cubeTexCoord0);
    } else {
        gl_FragColor = texture2D( DIFFUSE, texcoord0 );
    }
}
