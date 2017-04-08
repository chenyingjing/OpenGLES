precision mediump float;

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


varying mediump vec3 vNormal0;
varying mediump vec3 vTangent0;

mediump vec3 CalcBumpedNormal()
{
    mediump vec3 Normal = normalize(vNormal0);
    mediump vec3 Tangent = normalize(vTangent0);
    Tangent = normalize(Tangent - dot(Tangent, Normal) * Normal);
    mediump vec3 Bitangent = cross(Tangent, Normal);
    mediump vec3 BumpMapNormal = texture2D(Bump, vTextureCoordOut).xyz;
    BumpMapNormal = 2.0 * BumpMapNormal - vec3(1.0, 1.0, 1.0);
    mediump vec3 NewNormal;
    mediump mat3 TBN = mat3(Tangent, Bitangent, Normal);
    NewNormal = TBN * BumpMapNormal;
    NewNormal = normalize(NewNormal);
    return NewNormal;
}

void main(void)
{
/*
    lowp vec3 normal = texture2D( Bump, vTextureCoordOut ).rgb * 2.0 - 1.0;

    lowp float intensity = max( dot( lightdirection_ts, normal ), 0.0 );
    
    gl_FragColor = vec4( 0.1 );
    
    if (intensity > 0.0) {
        lowp vec3 reflectionvector = normalize( -reflect( lightdirection_ts, normal ) );
        
        gl_FragColor += texture2D( Sampler, vTextureCoordOut ) * vDiffuseMaterial * intensity +
        
        vSpecularMaterial *
        pow( max( dot( reflectionvector, position ), 0.0 ), shininess );
    }
*/
    mediump vec3 Normal = CalcBumpedNormal();
    
    vec3 cameraPosition = vec3(0, 0, 8);
    vec3 surfaceToCamera = normalize(cameraPosition - position);
    vec3 lightDirection = normalize(vLightPosition - position);
    
    
    //diffuse
    float diffuseCoefficient = max(0.0, dot(lightDirection, Normal));
    vec3 diffuse = diffuseCoefficient * texture2D( Sampler, vTextureCoordOut ).rgb;
    
    //specular
    float specularCoefficient = 0.0;
    if(diffuseCoefficient > 0.0)
        specularCoefficient = pow(max(0.0, dot(surfaceToCamera, reflect(-lightDirection, Normal))), shininess);
    vec3 specular = specularCoefficient * vSpecularMaterial.rgb;
    
    gl_FragColor = vec4(diffuse + specular, 1);
    
    
//    float intensity = max( dot( lightDirection, Normal ), 0.0 );
//    
//    gl_FragColor = vec4( 0.03 );
//    
//    if (intensity > 0.0) {
//        vec3 reflectionvector = normalize( -reflect( lightDirection, Normal ) );
//        
//        gl_FragColor += texture2D( Sampler, vTextureCoordOut ) * vDiffuseMaterial * intensity +
//        
//        vSpecularMaterial *
//        //pow( max( dot( reflectionvector, position ), 0.0 ), shininess );
//        pow( 0.5, shininess );
//    }
    
}

