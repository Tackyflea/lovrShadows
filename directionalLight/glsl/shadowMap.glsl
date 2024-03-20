float PCF_FILTER_SAMPLES = 64;
float BLOCKER_SAMPLES = 32;

vec3 pcf_offset[20] = vec3[](
vec3( 1,  1,  1), vec3( 1, -1,  1), vec3(-1, -1,  1), vec3(-1,  1,  1), 
   vec3( 1,  1, -1), vec3( 1, -1, -1), vec3(-1, -1, -1), vec3(-1,  1, -1),
   vec3( 1,  1,  0), vec3( 1, -1,  0), vec3(-1, -1,  0), vec3(-1,  1,  0),
   vec3( 1,  0,  1), vec3(-1,  0,  1), vec3( 1,  0, -1), vec3(-1,  0, -1),
   vec3( 0,  1,  1), vec3( 0, -1,  1), vec3( 0, -1, -1), vec3( 0,  1, -1)
);
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
float SampleShadowmapDepth(vec2 uv)
{
	return getPixel(DepthBuffer, uv ).r; 
}
vec2 FindBlocker(vec2 uv, float depth, float scale, float searchUV, vec2 rotationTrig)
{
	float avgBlockerDepth = 0.0;
	float numBlockers = 0.0;
	float blockerSum = 0.0;

	for (int i = 0; i < BLOCKER_SAMPLES; i++)
	{
		vec2 offset = poissonDisk[i] * searchUV * scale;

		offset = Rotate(offset, rotationTrig);
		float shadowMapDepth =sampleTex(vec3(uv + offset , depth));

        float biasedDepth = depth;
		if (shadowMapDepth > biasedDepth)
		{
			blockerSum += shadowMapDepth;
			numBlockers += 1.0;
		}
	
	}

	avgBlockerDepth = blockerSum / numBlockers;

	return vec2(avgBlockerDepth, numBlockers);
}


float PCF_Filter(vec2 uv, float depth, float scale, float filterRadiusUV, float penumbra, vec2 rotationTrig)
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
    

    float depth = PositionLightSpace.z;    
    float random =  fract(sin(dot(PositionWorld.xy, vec2(12.9898,78.233))) * 43758.5453123);

	float rotationAngle = random * 3.1415926;
	vec2 rotationTrig = vec2(cos(rotationAngle), sin(rotationAngle));

    float Softness= 1.2;
    float SoftnessFalloff = 0.49;
    float scale = 0.01;

    float searchSize  = Softness * (depth - .02) / depth;
    vec2 blockerInfo = FindBlocker(lightSpaceUV, depth, scale, searchSize, rotationTrig);

  
	if (blockerInfo.y < 1)
	{
		//There are no occluders so early out (this saves filtering)
		return 1.0;
	}

    float penumbra = depth - blockerInfo.x; 
    penumbra = 1.0 - pow(1.0 - penumbra, SoftnessFalloff);
	float filterRadiusUV = penumbra * Softness;
    float shadow = PCF_Filter(lightSpaceUV, depth, scale, filterRadiusUV, penumbra, rotationTrig);
    shadow = -0.2 + pow(1.8 * shadow, 0.4); 
    shadow = clamp(shadow,0,1);
    return 1-shadow;
}
