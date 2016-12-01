

varying mediump vec3 vEyeSpaceNormal;
varying mediump vec4 vDiffuse;
varying mediump vec4 vPosInWorld;

uniform highp vec3 vLightPosition;
uniform highp vec4 vAmbientMaterial;
uniform highp vec4 vSpecularMaterial;
uniform highp float shininess;

/*
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
*/



void main(void)
{
    highp vec3 N = normalize(vEyeSpaceNormal);
    highp vec3 L = normalize(vLightPosition);
    highp vec3 E = vec3(0, 0, 1);
    
    
    highp vec3 surfacePos = vec3(vPosInWorld);
    highp vec3 surfaceToLight = normalize(vLightPosition - surfacePos);
    highp vec3 incidenceVector = -surfaceToLight; //a unit vector
    highp vec3 reflectionVector = reflect(incidenceVector, N); //also a unit vector
    
    highp vec3 surfaceToCamera = normalize(E - surfacePos); //also a unit
    highp float cosAngle = max(0.0, dot(surfaceToCamera, reflectionVector));
    highp float df = max(0.0, dot(N, L));
    highp float sf = 0.0;
    if (cosAngle > 0.0) {
        sf = pow(cosAngle, shininess);
    }
    
    gl_FragColor = vAmbientMaterial + df * vDiffuse + sf * vSpecularMaterial;
}

