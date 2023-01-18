// Texture pixel/fragment shader
// Basic fragment shader for rendering textured geometry

// Texture and sampler registers
Texture2D sceneTexture : register(t0);
Texture2D thresholdTexture : register(t1);

SamplerState Sampler0 : register(s0);

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};


float4 main(InputType input) : SV_TARGET
{
    const float gamma = 2.2;
    
    float3 sceneColour = sceneTexture.Sample(Sampler0, input.tex).rgb;
    
    float3 bloomColour = thresholdTexture.Sample(Sampler0, input.tex).rgb;
    
    sceneColour += bloomColour;
    
    float3 result = float3(1.0f, 1.0f, 1.0f) - exp(-sceneColour * 2);
    
    //result = pow(result, float3(1.0 / gamma,1.0 / gamma,1.0f/gamma));
    
    float4 colour =  float4(result.x, result.y, result.z, 1.0f);
    return colour;
}