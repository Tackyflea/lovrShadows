float PCF_FILTER_SAMPLES = 64;
float BLOCKER_SAMPLES = 32;

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
mediump vec2 poissonDisk[64] = vec2[]( // don't use 'const' b/c of OSX GL compiler bug
    vec2(0.511749, 0.547686), vec2(0.58929, 0.257224), vec2(0.165018, 0.57663), vec2(0.407692, 0.742285),
    vec2(0.707012, 0.646523), vec2(0.31463, 0.466825), vec2(0.801257, 0.485186), vec2(0.418136, 0.146517),
    vec2(0.579889, 0.0368284), vec2(0.79801, 0.140114), vec2(-0.0413185, 0.371455), vec2(-0.0529108, 0.627352),
    vec2(0.0821375, 0.882071), vec2(0.17308, 0.301207), vec2(-0.120452, 0.867216), vec2(0.371096, 0.916454),
    vec2(-0.178381, 0.146101), vec2(-0.276489, 0.550525), vec2(0.12542, 0.126643), vec2(-0.296654, 0.286879),
    vec2(0.261744, -0.00604975), vec2(-0.213417, 0.715776), vec2(0.425684, -0.153211), vec2(-0.480054, 0.321357),
    vec2(-0.0717878, -0.0250567), vec2(-0.328775, -0.169666), vec2(-0.394923, 0.130802), vec2(-0.553681, -0.176777),
    vec2(-0.722615, 0.120616), vec2(-0.693065, 0.309017), vec2(0.603193, 0.791471), vec2(-0.0754941, -0.297988),
    vec2(0.109303, -0.156472), vec2(0.260605, -0.280111), vec2(0.129731, -0.487954), vec2(-0.537315, 0.520494),
    vec2(-0.42758, 0.800607), vec2(0.77309, -0.0728102), vec2(0.908777, 0.328356), vec2(0.985341, 0.0759158),
    vec2(0.947536, -0.11837), vec2(-0.103315, -0.610747), vec2(0.337171, -0.584), vec2(0.210919, -0.720055),
    vec2(0.41894, -0.36769), vec2(-0.254228, -0.49368), vec2(-0.428562, -0.404037), vec2(-0.831732, -0.189615),
    vec2(-0.922642, 0.0888026), vec2(-0.865914, 0.427795), vec2(0.706117, -0.311662), vec2(0.545465, -0.520942),
    vec2(-0.695738, 0.664492), vec2(0.389421, -0.899007), vec2(0.48842, -0.708054), vec2(0.760298, -0.62735),
    vec2(-0.390788, -0.707388), vec2(-0.591046, -0.686721), vec2(-0.769903, -0.413775), vec2(-0.604457, -0.502571),
    vec2(-0.557234, 0.00451362), vec2(0.147572, -0.924353), vec2(-0.0662488, -0.892081), vec2(0.863832, -0.407206)
);

float interleavedGradientNoise(vec2 w) {
    const vec3 m = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(m.z * fract(dot(w, m.xy)));
}
mat2 getRandomRotationMatrix( vec2 fragCoord) {
    // rotate the poisson disk randomly
    float randomAngle = interleavedGradientNoise(fragCoord) * (2.0 * PI);
    vec2 randomBase = vec2(cos(randomAngle), sin(randomAngle));
    mat2 R = mat2(randomBase.x, randomBase.y, -randomBase.y, randomBase.x);
    return R;
}
vec2 Rotate(vec2 pos, vec2 rotationTrig)
{
	return vec2(pos.x * rotationTrig.x - pos.y * rotationTrig.y, pos.y * rotationTrig.x + pos.x * rotationTrig.y);
}

vec2 FindBlocker(vec2 uv, float depth, float scale, float searchUV, vec2 receiverPlaneDepthBias, vec2 rotationTrig)
{
	float avgBlockerDepth = 0.0;
	float numBlockers = 0.0;
	float blockerSum = 0.0;

	for (int i = 0; i < BLOCKER_SAMPLES; i++)
	{
		vec2 offset = PoissonSamples[i] * searchUV * scale;

		offset = Rotate(offset, rotationTrig);

		//float shadowMapDepth =sampleTex(vec3(uv + offset , depth));
        
		float shadowMapDepth =getPixel(DepthBuffer, uv + offset).r;
	    float biasedDepth = depth;
		if (shadowMapDepth < biasedDepth)
		{
			blockerSum += shadowMapDepth;
			numBlockers += 1.0;
		}
	
	}

	avgBlockerDepth = blockerSum / numBlockers;

	return vec2(avgBlockerDepth, numBlockers);
}

vec2 getReceiverPlaneDepthBias (vec3 shadowCoord)
{
	vec2 biasUV;
	vec3 dx = dFdx  (shadowCoord);
	vec3 dy = dFdy  (shadowCoord);

	biasUV.x = dy.y * dx.z - dx.y * dy.z;
    biasUV.y = dx.x * dy.z - dy.x * dx.z;
    biasUV *= 1.0f / ((dx.x * dy.y) - (dx.y * dy.x));
    return biasUV;
}
float PCF_Filter(vec2 uv, float depth, float scale, float filterRadiusUV, vec2 receiverPlaneDepthBias, float penumbra, vec2 rotationTrig)
{
	float sum = 0.0f;  
	for (int i = 0; i < PCF_FILTER_SAMPLES; i++)
	{
		vec2 offset = poissonDisk[i] * filterRadiusUV * scale;
 
		offset = Rotate(offset, rotationTrig); 

		float biasedDepth = depth;
 

		float value = sampleTex(vec3(uv.xy + offset, biasedDepth));

		sum += value;
	}

	//sum /= samples;
	sum /= PCF_FILTER_SAMPLES;

	return sum;
}
float shadowGenerate(){

    //PCSS ported from https://github.com/TheMasonX/UnityPCSS/blob/master/Assets/PCSS/Shaders/PCSS.shader#L482
    vec4 PositionLightSpace =  LightSpaceMatrix * vec4(PositionWorld, 1.);
    vec2 lightSpaceUV = PositionLightSpace.xy / PositionLightSpace.w * 0.5 + 0.5;    
    vec3 lightDir = normalize(vec3(LightSource)); 
    

    float depth = PositionLightSpace.z;    
    float random =  fract(sin(dot(PositionWorld.xy, vec2(12.9898,78.233))) * 43758.5453123);

	float rotationAngle = random * 3.1415926;
	vec2 rotationTrig = vec2(cos(rotationAngle), sin(rotationAngle));
    vec2 receiverPlaneDepthBias = getReceiverPlaneDepthBias(PositionLightSpace.xyz);

    float Softness= 1.2;
    float SoftnessFalloff = 0.09;
    float scale = 0.01;

    float searchSize  = Softness * (depth - .02) / depth;
    vec2 blockerInfo = FindBlocker(lightSpaceUV, depth, scale, searchSize, receiverPlaneDepthBias, rotationTrig);

    if (blockerInfo.y < 0)
	{
		//There are no occluders so early out (this saves filtering)
		return 1.0;
	}
    float penumbra = depth - blockerInfo.x; 
    penumbra = 1.0 - pow(1.0 - penumbra, SoftnessFalloff);
	float filterRadiusUV = penumbra * Softness;
    float shadow = PCF_Filter(lightSpaceUV, depth, scale, filterRadiusUV, receiverPlaneDepthBias, penumbra, rotationTrig);
    shadow = -0.2 + pow(1.8 * shadow, 0.4); 
    shadow = clamp(shadow,0,1);
    return 1-shadow;
}
