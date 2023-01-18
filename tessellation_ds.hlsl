// Tessellation domain shader
// After tessellation the domain shader processes the all the vertices

cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
};

cbuffer timeBuffer : register(b1)
{
    float totalTime;
    float3 padding;
}

struct ConstantOutputType
{
    float edges[4] : SV_TessFactor;
    float inside[2] : SV_InsideTessFactor;
};

struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

struct OutputType
{
    float3 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

[domain("quad")]
OutputType main(ConstantOutputType input, float2 uvwCoord : SV_DomainLocation, const OutputPatch<InputType, 4> patch)
{
    float2 texCoord;
    float3 vertexPosition;
    float3 normal;
    OutputType output;
 
    // Determine the position of the new vertex.
	// Invert the y and Z components of uvwCoord as these coords are generated in UV space and therefore y is positive downward.
	// Alternatively you can set the output topology of the hull shader to cw instead of ccw (or vice versa).
    
    float3 v1 = lerp(patch[0].position, patch[1].position, uvwCoord.y);
    float3 v2 = lerp(patch[3].position, patch[2].position, uvwCoord.y);
    vertexPosition = lerp(v1, v2, uvwCoord.x);
    
    
    float2 t1 = lerp(patch[0].tex, patch[1].tex, uvwCoord.y);
    float2 t2 = lerp(patch[3].tex, patch[2].tex, uvwCoord.y);
    texCoord = lerp(t1, t2, uvwCoord.x);
    
    float3 n1 = lerp(patch[0].normal, patch[1].normal, uvwCoord.y);
    float3 n2 = lerp(patch[3].normal, patch[2].normal, uvwCoord.y);
    normal = lerp(n1, n2, uvwCoord.x);
    
    //vertexPosition.z = sin((vertexPosition.x + totalTime));
   //vertexPosition = uvwCoord.x * patch[0].position + -uvwCoord.y * patch[1].position + -uvwCoord.z * patch[2].position;
		    
    // Calculate the position of the new vertex against the world, view, and projection matrices.
    
    output.position = vertexPosition;

    //output.position = float4(vertexPosition.x, vertexPosition.y, vertexPosition.z, 1.0f);

    // Send the input color into the pixel shader.
    
    output.tex = texCoord;
    
    output.normal = normal;

    return output;
}
