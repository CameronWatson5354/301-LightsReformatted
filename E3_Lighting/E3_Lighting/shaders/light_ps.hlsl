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

float calculateAttenuation(float distance)
{
    float attConst = 1;
    float attLinear = 0.05;
    float attQuadratic = 0.001;
    
    float attenuation;
    
    attenuation = 1 / (attConst + attLinear * distance + attQuadratic * distance * distance);
    
    return attenuation;
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
        //variables that have to be recalculated for each light
        float3 lightVector = normalize(input.worldPos - lightPos[i].xyz);
        float distanceFromLight = length(lightPos[i].xyz - input.worldPos);
        float spotlightStrength = 0;
        float attenuation = 0;
        
        switch (lightType[i].x)
        {
            case 0: //none
                break;
            
            case 1: //directional
                lightColour += calculateLighting(-lightDirection[i].xyz, input.normal, diffuseColour[i]);
                break;
		
            case 2: //pointlight
                attenuation = calculateAttenuation(distanceFromLight);
            
                lightColour += calculateLighting(-lightVector, input.normal, diffuseColour[i]) * attenuation;
                break;
		
            case 3: //spotlight
                spotlightStrength = calculateSpotlight(-lightVector, lightDirection[i].xyz, spotlightAngleMin[i].x, spotlightAngleMax[i].x);
                attenuation = calculateAttenuation(distanceFromLight);
            
                lightColour += calculateLighting(-lightVector, input.normal, diffuseColour[i]) * spotlightStrength * attenuation;
                break;
        }
    }
	
    finalColour = (ambientLight + lightColour) * textureColour;
	
    return finalColour;
	
	
}



