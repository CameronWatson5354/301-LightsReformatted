// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
    float4 diffuseColour[8];
    float4 lightDirection[8]; //originates from light
	
    float4 lightType[8];
    float4 lightPos[8];
	
    float4 ambientLight;
	
    float4 spotlightAngleMin[8];
    float4 spotlightAngleMax[8];
    
    float4 specular[8];
    float4 specularPower[8];
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
	
    float3 worldPos : POSITION;
    float3 viewVector : VECTOR;
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

float4 calculateSpecular(float3 pixelLightDirection, float3 viewVector, float3 normal, float4 specular, float specularPower)
{  
    
    float4 specularLight;
    
    float3 halfway = normalize(pixelLightDirection + viewVector);
    
    float specularIntensity = pow(max(dot(normal, halfway), 0.0), specularPower);
    
    specularLight = saturate(specular * specularIntensity);
    
    return specularLight;
}

float4 main(InputType input) : SV_TARGET
{
    float4 textureColour;
    float4 lightColour = float4(0, 0, 0, 0);
    float4 finalColour;
    float4 specularColour = float4(0, 0, 0, 0);

	// Sample the texture. Calculate light intensity and colour, return light*texture for final pixel colour.
    textureColour = texture0.Sample(sampler0, input.tex);
    
    for (int i = 0; i < 8; ++i)
    {
        //variables that have to be recalculated for each light
        float3 lightVector = normalize(input.worldPos - lightPos[i].xyz); //originates from light
        float distanceFromLight = length(lightPos[i].xyz - input.worldPos);
        float spotlightStrength = 1;
        float attenuationStrength = 1;
       
        
        switch (lightType[i].x)
        {
            case 0: //none
                break;
            
            case 1: //directional
                specularColour += calculateSpecular(-lightDirection[i].xyz, input.viewVector, input.normal, specular[0], specularPower[i].x);
                //lightColour += calculateLighting(-lightDirection[i].xyz, input.normal, diffuseColour[i]);
                break;
		
            case 2: //pointlight
                attenuationStrength = calculateAttenuation(distanceFromLight);
            
                specularColour += calculateSpecular(-lightVector, input.viewVector, input.normal, specular[i], specularPower[i].x) * attenuationStrength;
                //lightColour += (calculateLighting(-lightVector, input.normal, diffuseColour[i]) * attenuationStrength);
                break;
		
            case 3: //spotlight
                spotlightStrength = calculateSpotlight(-lightVector, lightDirection[i].xyz, spotlightAngleMin[i].x, spotlightAngleMax[i].x);
                attenuationStrength = calculateAttenuation(distanceFromLight);
            
                specularColour += calculateSpecular(-lightVector, input.viewVector, input.normal, specular[i], specularPower[i].x) * attenuationStrength * spotlightStrength;
                //lightColour += (calculateLighting(-lightVector, input.normal, diffuseColour[i]) * spotlightStrength * attenuationStrength);
                break;
        }
        
        lightColour += (calculateLighting(-lightVector, input.normal, diffuseColour[i]) * spotlightStrength * attenuationStrength);
    }
    
    
	
    finalColour = (ambientLight + lightColour) * textureColour + specularColour;
	
    return finalColour;
	
	
}



