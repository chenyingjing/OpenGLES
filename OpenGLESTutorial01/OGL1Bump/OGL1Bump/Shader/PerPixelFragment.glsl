

varying mediump vec3 vEyeSpaceNormal;

varying mediump vec4 vPosInWorld;
varying mediump vec2 vTextureCoordOut;

uniform highp vec3 vLightPosition;
uniform highp vec4 vAmbientMaterial;
uniform highp vec4 vSpecularMaterial;
uniform highp vec4 vDiffuseMaterial;
uniform highp float shininess;

uniform sampler2D Sampler;
uniform sampler2D Bump;

varying lowp vec3 lightdirection_ts;
varying mediump vec3 position;

void main(void)
{
    lowp vec3 normal = texture2D( Bump, vTextureCoordOut ).rgb * 2.0 - 1.0;

    lowp float intensity = max( dot( lightdirection_ts, normal ), 0.0 );
    
    gl_FragColor = vec4( 0.1 );
    
    if (intensity > 0.0) {
        lowp vec3 reflectionvector = normalize( -reflect( lightdirection_ts, normal ) );
        
        gl_FragColor += texture2D( Sampler, vTextureCoordOut ) * vDiffuseMaterial * intensity +
        
        vSpecularMaterial *
        pow( max( dot( reflectionvector, position ), 0.0 ), shininess );
    }
}

