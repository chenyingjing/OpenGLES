
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


uniform sampler2D DIFFUSE;
uniform sampler2D BUMP;

varying mediump vec2 texcoord0;

varying lowp vec3 lightdirection_ts;

void main( void )
{
    //lowp vec4 diffuse_color = texture2D( DIFFUSE, texcoord0 );

    lowp vec3 normal = texture2D( BUMP, texcoord0 ).rgb * 2.0 - 1.0;
    
    lowp float intensity = max( dot( lightdirection_ts, normal ), 0.0 );
    
    gl_FragColor = vec4( 0.1 );
    
    if( intensity > 0.0 ) {
        lowp vec3 reflectionvector = normalize( -reflect( lightdirection_ts, normal ) );
        
        gl_FragColor += texture2D( DIFFUSE, texcoord0 ) * vec4( DIFFUSE_COLOR, 1.0 ) * intensity +
        
        vec4( SPECULAR_COLOR, 1.0 ) *
        pow( max( dot( reflectionvector, position ), 0.0 ), SHININESS );
    }
    
}
