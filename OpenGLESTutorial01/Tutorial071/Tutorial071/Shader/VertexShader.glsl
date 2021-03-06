uniform mat4 projection;
uniform mat4 modelView;
attribute vec4 vPosition;

uniform mat3 normalMatrix;
uniform vec3 vLightPosition;
uniform vec4 vAmbientMaterial;
uniform vec4 vSpecularMaterial;
uniform float shininess;

attribute vec3 vNormal;
attribute vec4 vDiffuseMaterial;

varying vec4 vDestinationColor;

/*
void main(void)
{
    gl_Position = projection * modelView * vPosition;
    
    vec3 N = normalMatrix * vNormal;
    vec3 L = normalize(vLightPosition);
    vec3 E = vec3(0, 0, 1);
    vec3 H = normalize(L + E);
    
    float df = max(0.0, dot(N, L));
    float sf = max(0.0, dot(N, H));
    sf = pow(sf, shininess);
    
    vDestinationColor = vAmbientMaterial + df * vDiffuseMaterial + sf * vSpecularMaterial;
    
    //vDestinationColor = vec4(1.0, 0.0, 0.0, 1.0);
}
*/

void main(void)
{
    gl_Position = projection * modelView * vPosition;
    
    vec3 N = normalMatrix * vNormal;
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
