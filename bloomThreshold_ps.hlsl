// Texture pixel/fragment shader
// Basic fragment shader for rendering textured geometry

// Texture and sampler registers
Texture2D texture0 : register(t0);
SamplerState Sampler0 : register(s0);

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};


float4 main(InputType input) : SV_TARGET
{
    float4 colour = texture0.Sample(Sampler0, input.tex);
    
    float brightness = dot(colour.rgb, float3(0.2126, 0.7152, 0.0722)); //Convert to grayscale 
    
    float4 brightColour = float4(0.0f, 0.0f, 0.0f, 1.0f);
    if(brightness > 0.75f)
    {
        brightColour = float4(colour.rgb, 1.0);
    }
    
    
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
    return brightColour;
}