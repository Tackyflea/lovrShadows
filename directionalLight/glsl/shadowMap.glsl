
vec3 pcf_offset[20] = vec3[](
vec3( 1,  1,  1), vec3( 1, -1,  1), vec3(-1, -1,  1), vec3(-1,  1,  1), 
   vec3( 1,  1, -1), vec3( 1, -1, -1), vec3(-1, -1, -1), vec3(-1,  1, -1),
   vec3( 1,  1,  0), vec3( 1, -1,  0), vec3(-1, -1,  0), vec3(-1,  1,  0),
   vec3( 1,  0,  1), vec3(-1,  0,  1), vec3( 1,  0, -1), vec3(-1,  0, -1),
   vec3( 0,  1,  1), vec3( 0, -1,  1), vec3( 0, -1, -1), vec3( 0,  1, -1)
); 
// For Poisson Disk PCF sampling
 const vec2 PoissonSamples[64] =
{
    vec2(-0.5119625f, -0.4827938f),
    vec2(-0.2171264f, -0.4768726f),
    vec2(-0.7552931f, -0.2426507f),
    vec2(-0.7136765f, -0.4496614f),
    vec2(-0.5938849f, -0.6895654f),
    vec2(-0.3148003f, -0.7047654f),
    vec2(-0.42215f, -0.2024607f),
    vec2(-0.9466816f, -0.2014508f),
    vec2(-0.8409063f, -0.03465778f),
    vec2(-0.6517572f, -0.07476326f),
    vec2(-0.1041822f, -0.02521214f),
    vec2(-0.3042712f, -0.02195431f),
    vec2(-0.5082307f, 0.1079806f),
    vec2(-0.08429877f, -0.2316298f),
    vec2(-0.9879128f, 0.1113683f),
    vec2(-0.3859636f, 0.3363545f),
    vec2(-0.1925334f, 0.1787288f),
    vec2(0.003256182f, 0.138135f),
    vec2(-0.8706837f, 0.3010679f),
    vec2(-0.6982038f, 0.1904326f),
    vec2(0.1975043f, 0.2221317f),
    vec2(0.1507788f, 0.4204168f),
    vec2(0.3514056f, 0.09865579f),
    vec2(0.1558783f, -0.08460935f),
    vec2(-0.0684978f, 0.4461993f),
    vec2(0.3780522f, 0.3478679f),
    vec2(0.3956799f, -0.1469177f),
    vec2(0.5838975f, 0.1054943f),
    vec2(0.6155105f, 0.3245716f),
    vec2(0.3928624f, -0.4417621f),
    vec2(0.1749884f, -0.4202175f),
    vec2(0.6813727f, -0.2424808f),
    vec2(-0.6707711f, 0.4912741f),
    vec2(0.0005130528f, -0.8058334f),
    vec2(0.02703013f, -0.6010728f),
    vec2(-0.1658188f, -0.9695674f),
    vec2(0.4060591f, -0.7100726f),
    vec2(0.7713396f, -0.4713659f),
    vec2(0.573212f, -0.51544f),
    vec2(-0.3448896f, -0.9046497f),
    vec2(0.1268544f, -0.9874692f),
    vec2(0.7418533f, -0.6667366f),
    vec2(0.3492522f, 0.5924662f),
    vec2(0.5679897f, 0.5343465f),
    vec2(0.5663417f, 0.7708698f),
    vec2(0.7375497f, 0.6691415f),
    vec2(0.2271994f, -0.6163502f),
    vec2(0.2312844f, 0.8725659f),
    vec2(0.4216993f, 0.9002838f),
    vec2(0.4262091f, -0.9013284f),
    vec2(0.2001408f, -0.808381f),
    vec2(0.149394f, 0.6650763f),
    vec2(-0.09640376f, 0.9843736f),
    vec2(0.7682328f, -0.07273844f),
    vec2(0.04146584f, 0.8313184f),
    vec2(0.9705266f, -0.1143304f),
    vec2(0.9670017f, 0.1293385f),
    vec2(0.9015037f, -0.3306949f),
    vec2(-0.5085648f, 0.7534177f),
    vec2(0.9055501f, 0.3758393f),
    vec2(0.7599946f, 0.1809109f),
    vec2(-0.2483695f, 0.7942952f),
    vec2(-0.4241052f, 0.5581087f),
    vec2(-0.1020106f, 0.6724468f),
};
float sampleTex(vec3 location){
    return texture( sampler2DShadow(DepthBuffer, shadowSampler), location );
}

float linstep(float min, float max, float v) {   
    return clamp((v - min) / (max - min), 0, 1); 
} 
float ReduceLightBleeding(float p_max, float Amount) {    
// Remove the [0, Amount] tail and linearly rescale (Amount, 1].    
    return linstep(Amount, 1, p_max); 
} 

float shadowGenerate(){


    vec4 PositionLightSpace =  Push.LightSpaceMatrix * vec4(PositionWorld, 1.);
    vec2 lightSpaceUV = PositionLightSpace.xy / PositionLightSpace.w * 0.5 + 0.5;
    float depth_biased = 0.0003;
    float currentDepth = PositionLightSpace.z / PositionLightSpace.w + depth_biased;
    float shadowing = 0.; // collect shadow across pcf samples
    float bias = 0.003;   
    vec3 lightDir = normalize(vec3(Push.LightSource));
    bias= max(0.05 * (1.0 - dot(Normal, lightDir)), 0.005);  
  
 
    const float Samples = 20;

    for (int i = 0; i < Samples; ++i) {
        int index = i;
        lightSpaceUV += pcf_offset[index].xy * 0.0004;
        float closestDepth2=  1e9;

        if ((lightSpaceUV.x > 0.) && (lightSpaceUV.x < 1.) && (lightSpaceUV.y > 0.) && (lightSpaceUV.y < 1.)) {
      
            closestDepth2 = sampleTex(vec3(lightSpaceUV  ,PositionLightSpace.z) );

        } 
        if (currentDepth-bias> closestDepth2){
            shadowing += 1.0 ;
        }

    }
    shadowing /= float(Samples);  
    shadowing = clamp(shadowing,0,1);
    shadowing = -0.2 + pow(1.8 * shadowing, 0.4); 
    shadowing = clamp(shadowing,0,1);

 
    shadowing = ReduceLightBleeding(shadowing,0.04);
    return shadowing;
}