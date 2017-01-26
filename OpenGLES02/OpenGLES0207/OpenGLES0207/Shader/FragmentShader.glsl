precision mediump float;

uniform highp mat4 model;
uniform mat3 normalMatrix;
uniform vec3 cameraPosition;

// material settings
uniform sampler2D materialTex;
uniform float materialShininess;
uniform vec3 materialSpecularColor;

uniform struct Light {
    vec3 position;
    vec3 intensities; //a.k.a the color of the light
    float attenuation;
    float ambientCoefficient;
} light;

varying vec2 fragTexCoord;
varying vec3 fragNormal;
varying vec3 fragVert;

void main() {
    vec3 normal = normalize(normalMatrix * fragNormal);
    vec3 surfacePos = vec3(model * vec4(fragVert, 1));
    vec4 surfaceColor = texture2D(materialTex, fragTexCoord);
    vec3 surfaceToLight = normalize(light.position - surfacePos);
    vec3 surfaceToCamera = normalize(cameraPosition - surfacePos);
    
    //ambient
    vec3 ambient = light.ambientCoefficient * surfaceColor.rgb * light.intensities;
    
    //diffuse
    float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
    vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * light.intensities;
    
    //specular
    float specularCoefficient = 0.0;
    if(diffuseCoefficient > 0.0)
        specularCoefficient = pow(max(0.0, dot(surfaceToCamera, reflect(-surfaceToLight, normal))), materialShininess);
    vec3 specular = specularCoefficient * materialSpecularColor * light.intensities;
    
    //attenuation
    float distanceToLight = length(light.position - surfacePos);
    float attenuation = 1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2.0));
    
    //linear color (color before gamma correction)
    vec3 linearColor = ambient + attenuation*(diffuse + specular);
    
    //final color (after gamma correction)
//    vec3 gamma = vec3(1.0/2.2);
//    gl_FragColor = vec4(pow(linearColor, gamma), surfaceColor.a);

    gl_FragColor = vec4(linearColor, surfaceColor.a);
}
