// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
    float4 diffuseColour[2];
    float4 lightDirection[2];
	
    float4 lightType[2];
    float4 lightPos[2];
	
    float4 ambientLight;
	
    float4 spotlightAngleMin[2];
    float4 spotlightAngleMax[2];
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

float calculateSpotlight(float3 lightVector, float3 lightDirection, float spotlightAngleMin, float spotlightAngleMax)
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
    float4 lightColour = float4(0, 0, 0, 0);
    float4 finalColour;

	// Sample the texture. Calculate light intensity and colour, return light*texture for final pixel colour.
    textureColour = texture0.Sample(sampler0, input.tex);
	
    for (int i = 0; i < 2; ++i)
    {
        float3 lightVector = normalize(input.worldPos - lightPos[i].xyz);
        float spotlightStrength = 0;
        
        switch (lightType[i].x)
        {
            case 0: //directional
                lightColour += calculateLighting(-lightDirection[i].xyz, input.normal, diffuseColour[i]);
                break;
		
            case 1: //pointlight
                lightColour += calculateLighting(-lightVector, input.normal, diffuseColour[i]);
                break;
		
            case 2: //spotlight
                spotlightStrength = calculateSpotlight(-lightVector, lightDirection[i].xyz, spotlightAngleMin[i].x, spotlightAngleMax[i].y);
                lightColour += calculateLighting(-lightVector, input.normal, diffuseColour[i]) * spotlightStrength;
                break;
        }
    }
	
    finalColour = (ambientLight + lightColour) * textureColour;
	
    return finalColour;
	
	
}



