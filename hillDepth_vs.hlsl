Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);


cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
};


cbuffer hillBuffer : register(b1)
{
    float hillHeight;
    float3 padding;
}


struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float4 depthPosition : TEXCOORD0;
};



float getHeight(float2 uv)
{
    float4 colourOfPixel = texture0.SampleLevel(sampler0, uv, 0);
    return colourOfPixel.x * hillHeight;
}


OutputType
    main(InputType input)
{
    OutputType output;
	
    input.position.y = getHeight(input.tex);
	  
	
	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    
    output.depthPosition = output.position;
    
    return output;
}