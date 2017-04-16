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



uniform bool LIGHTING_SHADER;


//uniform mediump mat4 MODELVIEWMATRIX;

uniform mediump mat4 PROJECTIONMATRIX;

uniform mediump mat3 NORMALMATRIX;

attribute lowp vec3 NORMAL;

varying lowp vec3 normal;

varying mediump vec3 position;


uniform mat4 projection;
uniform mat4 camera;
uniform mat4 model;


attribute mediump vec3 POSITION;

attribute mediump vec2 TEXCOORD0;

varying mediump vec2 texcoord0;
varying vec3 cubeTexCoord0;

void main( void )
{
    texcoord0 = TEXCOORD0;

    if (LIGHTING_SHADER) {
        position = vec3( model * vec4( POSITION, 1.0 ) );
        
        normal = normalize( NORMALMATRIX * NORMAL );
        
        gl_Position = camera * projection * vec4( position, 1.0 );
    } else {
        gl_Position = camera * projection * model * vec4( POSITION, 1.0 );
    }
    cubeTexCoord0 = POSITION;
}
