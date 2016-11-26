

varying mediump vec3 vEyeSpaceNormal;
varying mediump vec4 vDiffuse;
varying mediump vec4 vPosInWorld;

uniform highp vec3 vLightPosition;
uniform highp vec4 vAmbientMaterial;
uniform highp vec4 vSpecularMaterial;
uniform highp float shininess;


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
    
    if (df < 0.1)
        df = 0.0;
    else if (df < 0.2)
        df = 0.2;
    else if (df < 0.4)
        df = 0.4;
    else if (df < 0.6)
        df = 0.6;
    else if (df < 0.8)
        df = 0.8;
    else
        df = 1.0;
    
    highp float sf = 0.0;
    if (cosAngle > 0.0) {
        sf = pow(cosAngle, shininess);
    }
    
    gl_FragColor = vAmbientMaterial + df * vDiffuse + sf * vSpecularMaterial;
}

