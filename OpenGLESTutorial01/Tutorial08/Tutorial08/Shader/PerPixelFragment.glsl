

varying mediump vec3 vEyeSpaceNormal;
varying mediump vec4 vDiffuse;

uniform highp vec3 vLightPosition;
uniform highp vec4 vAmbientMaterial;
uniform highp vec4 vSpecularMaterial;
uniform highp float shininess;

void main()
{
    highp vec3 N = normalize(vEyeSpaceNormal);
    highp vec3 L = normalize(vLightPosition);
    highp vec3 E = vec3(0, 0, 1);
    highp vec3 H = normalize(L + E);
    
    highp float df = max(0.0, dot(N, L));
    highp float sf = max(0.0, dot(N, H));
    sf = pow(sf, shininess);
    
    mediump vec4 color = vAmbientMaterial + df * vDiffuse + sf * vSpecularMaterial;
    gl_FragColor = color;
    //gl_FragColor = vec4(color, 1);
}


/*

void main(void)
{
    vec3 N = normalize(vEyeSpaceNormal);
    vec3 L = normalize(vLightPosition);
    vec3 E = vec3(0, 0, 1);
    
    
    vec3 surfacePos = vec3(modelView * vPosition);
    vec3 surfaceToLight = normalize(vLightPosition - surfacePos);
    vec3 incidenceVector = -surfaceToLight; //a unit vector
    vec3 reflectionVector = reflect(incidenceVector, N); //also a unit vector
    
    vec3 surfaceToCamera = normalize(E - surfacePos); //also a unit
    float cosAngle = max(0.0, dot(surfaceToCamera, reflectionVector));
    float df = max(0.0, dot(N, L));
    float sf = 0.0;
    if (cosAngle > 0.0) {
        sf = pow(cosAngle, shininess);
    }
    
    vDestinationColor = vAmbientMaterial + df * vDiffuseMaterial + sf * vSpecularMaterial;
}
*/
