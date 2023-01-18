
Texture2D shaderTexture : register(t0);
Texture2D directionalDepthMap : register(t1);
Texture2D spotDepthMaps[6] : register(t2);
Texture2D pointDepthMaps[6] : register(t3);

SamplerState diffuseSampler : register(s0);
SamplerState shadowSampler : register(s1);

cbuffer LightBuffer : register(b0)
{
    float4 directionalAmbient;
    float4 directionalDiffuse;
    float4 directionalPosition;
    float4 directionalDirection;
    float4 directionalAttenuation;

    float4 spotlightAmbient[6];
    float4 spotlightDiffuse[6];
    float4 spotlightPositions[6];
    float4 spotlightDirection[6];
    float4 spotlightAttenuation[6];
    float cone;
    float3 padding;
    
    float4 pointlightAmbient[1];
    float4 pointlightDiffuse[1];
    float4 pointlightPosition[1];
    float4 pointlightDirection[1];
    float4 pointlightAttenutation[1];
};

struct InputType
{
    float4 position : SV_POSITION;
    float4 colour : COLOR;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 lightViewPos : TEXCOORD1;
    float4 secondLightViewPos : TEXCOORD2;
    float3 worldPosition : TEXCOORD3;
    float4 pointLightViewPositions[6] : TEXCOORD4;
};

// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
{
    float intensity = saturate(dot(normal, lightDirection));
    float4 colour = saturate(diffuse * intensity);
    return colour;
}


//This function will calculate the lighting of a spotlight
float4 calculateSpotlight(float3 lightPosition, float3 worldPosition, float3 normal, float4 diffuse, float4 attenuationVector, float2 tex, float4 ambient, float3 direction)
{
    float4 textureColour = shaderTexture.Sample(diffuseSampler, tex);
    
    float3 attenuationDistance = length(lightPosition - worldPosition);
    
    float3 spotlightDistance = lightPosition - worldPosition;
    
    float3 lightVector = normalize(lightPosition - worldPosition);
    
    float attenuation = 1 / (attenuationVector.x + (attenuationVector.y * attenuationDistance) + (attenuationVector.z * pow(attenuationDistance, 2)));
    
    float4 diffuseFactor = diffuse * attenuation;
    
    float4 lightColour = calculateLighting(lightVector, normal, diffuseFactor);
    
    lightColour += ambient;
    
    lightColour *= pow(max(dot(-spotlightDistance, direction), 0.0f), cone);
    
    return lightColour;
}

float4 calculatePointLight(int index, float3 worldPos, float3 normal)
{
    float3 Pos = pointlightPosition[index].xyz;
    
    float3 distance = length(Pos - worldPos);
    
    float3 lightVector = normalize(Pos - worldPos);
    
    float attenuation = 1 / (pointlightAttenutation[index].x + (pointlightAttenutation[index].y * distance) + (pointlightAttenutation[index].z * pow(distance, 2)));
    
    float4 diffuseFactor = pointlightDiffuse[index] * attenuation;
    
    float lightColour = calculateLighting(lightVector, normal, diffuseFactor);

    return lightColour;
}

// Is the gemoetry in our shadow map
bool hasDepthData(float2 uv)
{
    if (uv.x < 0.f || uv.x > 1.f || uv.y < 0.f || uv.y > 1.f)
    {
        return false;
    }
    return true;
}

bool isInShadow(Texture2D sMap, float2 uv, float4 lightViewPosition, float bias)
{
    // Sample the shadow map (get depth of geometry)
    float depthValue = sMap.Sample(shadowSampler, uv).r;
	// Calculate the depth from the light.
    float lightDepthValue = lightViewPosition.z / lightViewPosition.w;
    lightDepthValue -= bias;

	// Compare the depth of the shadow map value and the depth of the light to determine whether to shadow or to light this pixel.
    if (lightDepthValue < depthValue)
    {
        return false;
    }
    return true;
}

float2 getProjectiveCoords(float4 lightViewPosition)
{
    // Calculate the projected texture coordinates.
    float2 projTex = lightViewPosition.xy / lightViewPosition.w;
    projTex *= float2(0.5, -0.5);
    projTex += float2(0.5f, 0.5f);
    return projTex;
}

float4 main(InputType input) : SV_TARGET
{
    float shadowMapBias = 0.005f;
    float4 directionalColour = float4(0.0f, 0.0f, 0.0f, 1.0f);
    float4 spotlightColours[6];
    for (int i = 0; i < 6; i++)
    {
        spotlightColours[i] = float4(0.0f, 0.0f, 0.0f, 1.0f);
    }
    float4 pointLightColour = float4(0.0f, 0.0f, 0.0f, 1.0f);
    float4 textureColour = shaderTexture.Sample(diffuseSampler, input.tex);
	// Calculate the projected texture coordinates.
    float2 pTexCoord = getProjectiveCoords(input.lightViewPos);
    float2 pTexCoord2 = getProjectiveCoords(input.secondLightViewPos);
    float2 pTexCoordsPoint[6];
    
    
    int theMapIndex = 0;
    for (int j = 0; j < 1; j++)
    {
        for (int i = 0; i < 6; i++)
        {
            pTexCoordsPoint[i] = getProjectiveCoords(input.pointLightViewPositions[theMapIndex]);
            theMapIndex++;
        }
    }
    
    // Shadow test. Is or isn't in shadow
    if (hasDepthData(pTexCoord))
    {
        // Has depth map data
        if (!isInShadow(directionalDepthMap, pTexCoord, input.lightViewPos, shadowMapBias))
        {
            // is NOT in shadow, therefore light
            //Apply directional lighting as this is the directional light
            directionalColour = calculateLighting(-directionalDirection.xyz, input.normal, directionalDiffuse);
            directionalColour = saturate(directionalColour + directionalAmbient);
        }
    }
        
    if (hasDepthData(pTexCoord2))
    {
        if (!isInShadow(spotDepthMaps[0], pTexCoord2, input.secondLightViewPos, shadowMapBias))
        {
            //colour2 = combinedLighting(input.worldPosition, input.normal, input.tex);
            //colour2 = calculateSpotlight(position[1].xyz, input.worldPosition, input.normal, diffuse[1], attenuation[1], input.tex, ambient[1], direction2);
            spotlightColours[0] = calculateSpotlight(spotlightPositions[0].xyz, input.worldPosition, input.normal, spotlightDiffuse[0], spotlightAttenuation[0], input.tex, spotlightAmbient[0], spotlightDirection[0].xyz);
           
        }
    }else
    {
            spotlightColours[0] = calculateSpotlight(spotlightPositions[0].xyz, input.worldPosition, input.normal, spotlightDiffuse[0], spotlightAttenuation[0], input.tex, spotlightAmbient[0], spotlightDirection[0].xyz);
    }
    
    int mapIndex = 0;
    for (int numOfPointLights = 0; numOfPointLights < 1; numOfPointLights++)
    {
        for (int i = 0; i < 6; i++)
        {
            if (hasDepthData(pTexCoordsPoint[mapIndex]))
            {
                if (!isInShadow(pointDepthMaps[mapIndex], pTexCoordsPoint[mapIndex], input.pointLightViewPositions[mapIndex], shadowMapBias))
                {
                    pointLightColour = calculatePointLight(numOfPointLights, input.worldPosition, input.normal);
                }
            }
           
                
            mapIndex++;
        }
    }
    
    
    float4 finalColour = float4(0.0f, 0.0f, 0.0f, 1.0f);
    finalColour += directionalColour;
    finalColour += spotlightColours[0];
    finalColour += pointLightColour;
     //colour2 = calculateSpotlight(position[1].xyz, input.worldPosition, input.normal, diffuse[1], attenuation[1], input.tex, ambient[1], direction2);
    
    
    for (int i = 1; i < 6; i++)
    {
        spotlightColours[i] = calculateSpotlight(spotlightPositions[i].xyz, input.worldPosition, input.normal, spotlightDiffuse[i], spotlightAttenuation[i], input.tex, spotlightAmbient[i], spotlightDirection[i].xyz);
        spotlightColours[i] = saturate(spotlightColours[i] + spotlightAmbient[i]);
        finalColour += spotlightColours[i];
    }

    finalColour *= input.colour;
   
     
    return saturate(finalColour) * textureColour;
}