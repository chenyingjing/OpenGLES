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

uniform mediump vec3 LIGHTPOSITION;

attribute lowp vec3 NORMAL;
attribute lowp vec3 TANGENT0;
varying lowp vec3 normal;

varying mediump vec3 position;

varying lowp vec3 lightdirection_ts;

uniform mat4 projection;
uniform mat4 camera;
uniform mat4 model;


attribute mediump vec3 POSITION;

attribute mediump vec2 TEXCOORD0;

varying mediump vec2 texcoord0;

void main( void )
{
    mediump vec3 tmp;
    
    texcoord0 = TEXCOORD0;

//    if (LIGHTING_SHADER) {
    position = vec3( model * vec4( POSITION, 1.0 ) );
    
    normal   = NORMALMATRIX * NORMAL;
    lowp vec3 tangent  = NORMALMATRIX * TANGENT0;
    lowp vec3 binormal = cross( normal, tangent );
    
        
    gl_Position = camera * projection * vec4( position, 1.0 );
    
    position = vec3(projection * vec4( position, 1.0 ));
    
    lowp vec3 lightdirection_es = normalize( LIGHTPOSITION - position );
    
    lightdirection_ts.x = dot( lightdirection_es, tangent );
    lightdirection_ts.y = dot( lightdirection_es, binormal );
    lightdirection_ts.z = dot( lightdirection_es, normal );

    tmp.x = dot( position, tangent );
    tmp.y = dot( position, binormal );
    tmp.z = dot( position, normal );
    
    position = -normalize( tmp );

//    } else {
//        gl_Position = camera * projection * model * vec4( POSITION, 1.0 );
//    }
}
