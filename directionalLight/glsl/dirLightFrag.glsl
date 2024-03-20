layout(set = 2, binding = 0) uniform texture2D DepthBuffer;
layout(set = 2, binding = 1) uniform sampler shadowSampler;  

Constants {
  mat4 LightSpaceMatrix;
  vec3 LightDirection;
};

 //shadow map requires the matrix from here
 #include "directionalLight/glsl/shadowMap.glsl"

vec4 diffuseLighting( float shadow) {
  vec3 toLight = normalize(-LightDirection);
  float NdotL = max(dot(Normal, toLight), 0.0);
  NdotL = clamp(NdotL,0,1);

  vec4 diffuse = (shadow*NdotL) * vec4(1.0, 1.0, 0.8, 1.0); 
  vec4 baseColor = Color * getPixel(ColorTexture, UV);
  vec4 ambience = vec4(0.05, 0.05, 0.1, 1.0);
  return baseColor * (ambience +  diffuse);
}


vec4 lovrmain() {
   
    float getShadow = shadowGenerate();
    vec4 diffuseLight = diffuseLighting(getShadow);

    return diffuseLight;
}
