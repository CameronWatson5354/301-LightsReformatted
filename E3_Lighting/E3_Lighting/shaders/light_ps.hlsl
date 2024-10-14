// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
	float4 diffuseColour;
	float3 lightDirection;
	float padding;
	
    float lightType;
    float3 lightPos;
	
    float4 ambientLight;
	
    float spotlightAngleMin;
    float spotlightAngleMax;
    float2 padding2;
};

struct InputType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	
    float3 worldPos : POSITION;
};

// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
{
	float intensity = saturate(dot(normal, lightDirection));
	float4 colour = saturate(diffuse * intensity);
	
	return colour;
}

float calculateSpotlight(float3 lightVector)
{
    float4 spotLightValue;
	
    float minCos = cos(radians(spotlightAngleMin));
    float maxCos = cos(radians(spotlightAngleMax));
    float cosAngle = dot(lightVector, -lightDirection);
	
    spotLightValue = smoothstep(minCos, maxCos, cosAngle);
	
    return spotLightValue;
}

float4 main(InputType input) : SV_TARGET
{
	float4 textureColour;
	float4 lightColour;
    float4 finalColour;

	// Sample the texture. Calculate light intensity and colour, return light*texture for final pixel colour.
	textureColour = texture0.Sample(sampler0, input.tex);
	
    float3 lightVector = normalize(input.worldPos - lightPos);
    float spotlightStrength = 0;
	
    switch (lightType)
    {
		case 0: //directional
            lightColour = calculateLighting(-lightDirection, input.normal, diffuseColour);
            break;
		
		case 1: //pointlight
            lightColour = calculateLighting(-lightVector, input.normal, diffuseColour);
            break;
		
		case 2: //spotlight
            spotlightStrength = calculateSpotlight(-lightVector);
            lightColour = calculateLighting(-lightVector, input.normal, diffuseColour) * spotlightStrength;
            break;
    }
	
    finalColour = (ambientLight + lightColour) * textureColour;
	
    return finalColour;
	
	
}



