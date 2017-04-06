

uniform mat4 projection;
uniform mat4 modelView;
uniform mat3 normalMatrix;

uniform highp vec3 vLightPosition;

attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec3 vTangent;
attribute vec2 vTextureCoord;

varying vec3 vEyeSpaceNormal;
varying vec4 vDiffuse;
varying vec4 vPosInWorld;
varying vec2 vTextureCoordOut;

varying vec3 position;
varying lowp vec3 lightdirection_ts;

void main(void)
{
    gl_Position = projection * modelView * vec4( vPosition, 1.0 );
    
    mediump vec3 tmp;
    
    vTextureCoordOut = vTextureCoord;
    
    position = vec3( modelView * vec4( vPosition, 1.0 ) );
    
    lowp vec3 normal   = normalMatrix * vNormal;
    lowp vec3 tangent  = normalMatrix * vTangent;
    lowp vec3 binormal = cross( normal, tangent );

    lowp vec3 lightdirection_es = normalize( vLightPosition - position );
    
    lightdirection_ts.x = dot( lightdirection_es, tangent );
    lightdirection_ts.y = dot( lightdirection_es, binormal );
    lightdirection_ts.z = dot( lightdirection_es, normal );
    
    tmp.x = dot( position, tangent );
    tmp.y = dot( position, binormal );
    tmp.z = dot( position, normal );
    
    position = -normalize( tmp );
}

