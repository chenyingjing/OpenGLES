precision mediump float;

uniform highp mat4 model;
uniform mat3 normalMatrix;
uniform sampler2D tex;

uniform struct Light {
    vec3 position;
    vec3 intensities; //a.k.a the color of the light
} light;

varying vec2 fragTexCoord;
varying vec3 fragNormal;
varying vec3 fragVert;

void main()
{
    //mat3 normalMatrix = transpose(inverse(mat3(model)));
    vec3 normal = normalize(normalMatrix * fragNormal);
    
    vec3 fragPosition = vec3(model * vec4(fragVert, 1));
    
    vec3 surfaceToLight = light.position - fragPosition;
    
    float brightness = dot(normal, surfaceToLight) / (length(surfaceToLight) * length(normal));
    brightness = clamp(brightness, 0.0, 1.0);

    vec4 surfaceColor = texture2D(tex, fragTexCoord);
    gl_FragColor = vec4(brightness * light.intensities * surfaceColor.rgb, surfaceColor.a);
}
