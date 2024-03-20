 layout( push_constant ) uniform constants {
  mat4 LightSpaceMatrix;  
} ; 
layout(location = 2) out VertexData
{
  mat4 LightSpaceMatrix;  
  vec4 vShadowCoordinates;  
} outData;
vec4 lovrmain() { 

  //send matrix over to frag
  outData.LightSpaceMatrix= LightSpaceMatrix;  
  outData.vShadowCoordinates = LightSpaceMatrix* DefaultPosition;
  return Projection * View * Transform * VertexPosition;
}