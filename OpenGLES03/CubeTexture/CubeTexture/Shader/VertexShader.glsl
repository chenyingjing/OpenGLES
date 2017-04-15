uniform mat4 projection;
uniform mat4 modelView;
uniform mat3 model;
attribute vec4 vPosition;
attribute vec2 vTextureCoord;

uniform mat3 normalMatrix;
uniform vec3 vLightPosition;
uniform vec4 vAmbientMaterial;
uniform vec4 vSpecularMaterial;
uniform float shininess;

attribute vec3 vNormal;
attribute vec4 vDiffuseMaterial;

varying vec4 vDestinationColor;
varying vec2 vTextureCoordOut;
uniform vec3 vEyePosition;
varying vec3 vReflectDirection;


void main(void)
{
    gl_Position = projection * modelView * vPosition;
    
//    vec3 N = normalMatrix * vNormal;
//    vec3 L = normalize(vLightPosition);
//    vec3 E = vEyePosition;
//    
//    
//    vec3 surfacePos = vec3(modelView * vPosition);
//    vec3 surfaceToLight = normalize(vLightPosition - surfacePos);
//    vec3 incidenceVector = -surfaceToLight; //a unit vector
//    vec3 reflectionVector = reflect(incidenceVector, N); //also a unit vector
//    
//    vec3 surfaceToCamera = normalize(E - surfacePos); //also a unit
//    float cosAngle = max(0.0, dot(surfaceToCamera, reflectionVector));
//    float df = max(0.0, dot(N, L));
//    float sf = 0.0;
//    if (cosAngle > 0.0) {
//        sf = pow(cosAngle, shininess);
//    } 
//    
//    vDestinationColor = vAmbientMaterial + df * vDiffuseMaterial + sf * vSpecularMaterial;
    vTextureCoordOut = vTextureCoord;
//
//    // compute relect direction
//    //
//    vec3 eyeDirection = normalize(vPosition.xyz - vEyePosition);
//    vReflectDirection = reflect(eyeDirection, vNormal); // Reflection in object space
//    vReflectDirection = model * vReflectDirection;      // Transform to world sapce
    vReflectDirection = vPosition.xyz;
}
