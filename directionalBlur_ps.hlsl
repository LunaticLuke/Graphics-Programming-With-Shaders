Texture2D shaderTexture : register(t0);
SamplerState SampleType : register(s0);

cbuffer ScreenSizeBuffer : register(b0)
{
    float screenWidth;
    float screenHeight;
    float numerator;
    float denominator;
    float dis;
    float3 padding;
};


struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
};

float4 main(InputType input) : SV_TARGET
{
    //Initialise the colour variable
    float4 colour = float4(0.0f, 0.0f, 0.0f, 0.0f);
    
    //Find the dimensions of each texel
    float texelWidth = 1.0f / screenWidth;
    float texelHeight = 1.0f / screenHeight;
    
    //Direction Of The Blur
    float2 direction = float2(numerator, denominator);
    float2 texCoord = input.tex;
    float distance = dis;
    
    //return colour;
    direction *= float2(texelWidth, texelHeight);
    
    texCoord += direction;
    float weighting = 1.0f / distance + 1;
    colour = weighting * shaderTexture.Sample(SampleType, texCoord);
    
    for (int i = 0; i < distance; ++i, texCoord += direction)
    {
        float4 currentColour = weighting * shaderTexture.Sample(SampleType, texCoord);
        colour += currentColour;
    }
    
    colour /= distance;
    colour.a = 1.0f;
    
    
    return colour;
    
}