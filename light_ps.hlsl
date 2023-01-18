// Light pixel shader

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
    float4 ambient[3];
    float4 diffuse[3];
    float4 position[2];
    float4 attenuationVector[2];
    float3 direction;
    float cone;
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOORD1;
};

// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 ldiffuse)
{
    float intensity = saturate(dot(normal, lightDirection));
    float4 colour = saturate(ldiffuse * intensity);
    return colour;
}

float4 main(InputType input) : SV_TARGET
{
    float3 position1 = float3(position[0].x, position[0].y, position[0].z);
    float3 position2 = float3(position[1].x, position[1].y, position[1].z);
	
	// Sample the texture. Calculate light intensity and colour, return light*texture for final pixel colour.
	
    float4 textureColour = texture0.Sample(sampler0, input.tex);
    float3 distance1 = length(position1 - input.worldPosition);
    float3 distance2 = length(position2 - input.worldPosition);
    float3 spotlightDistance = position2 - input.worldPosition;
	
    float3 lightVector1 = normalize(position1 - input.worldPosition);
    float3 lightVector2 = normalize(position2 - input.worldPosition);
	
    float attenuation1 = 1 / (attenuationVector[0].x + (attenuationVector[0].y * distance1) + (attenuationVector[0].z * pow(distance1, 2)));
    float attenuation2 = 1 / (attenuationVector[1].x + (attenuationVector[1].y * distance2) + (attenuationVector[1].z * pow(distance2, 2)));
	
	
    float4 diffuseFactor1 = diffuse[0] * attenuation1;
    float4 diffuseFactor2 = diffuse[1] * attenuation2;
	
    float4 lightColour1 = calculateLighting(lightVector1, input.normal, diffuseFactor1);
    float4 lightColour2 = calculateLighting(lightVector2, input.normal, diffuseFactor2);
	
    lightColour1 += ambient[0];
    lightColour2 += ambient[1];
	
    lightColour2 *= pow(max(dot(-spotlightDistance, direction), 0.0f), cone);
	
    float4 directionalLightColour = calculateLighting(-direction, input.normal, diffuse[2]);
	
    float4 totalLightColour = saturate(lightColour2 + lightColour1);

   
    return totalLightColour * textureColour;
}



