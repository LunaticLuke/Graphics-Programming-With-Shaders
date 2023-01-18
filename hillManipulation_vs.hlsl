Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);


// Light vertex shader
// Standard issue vertex shader, apply matrices, pass info to pixel shader
cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
    matrix lightViewMatrix[2];
    matrix lightProjectionMatrix[2];
    matrix pointLightViewMatrix[6];
    matrix pointProjectionMatrix;
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
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 lightViewPos : TEXCOORD1;
    float4 secondLightViewPos : TEXCOORD2;
    float3 worldPosition : TEXCOORD3;
    float4 pointLightViewPositions[6] : TEXCOORD4;
};



float getHeight(float2 uv)
{
    float4 colourOfPixel = texture0.SampleLevel(sampler0, uv, 0);
    return colourOfPixel.x * hillHeight;
}

float3 calculateNormal(float2 uv, float3 position)
{
    float distance = 1.0f;
	
    float2 VertexDataUVCoords[4];
	//North
    VertexDataUVCoords[0] = float2(uv.x, uv.y - (distance / 100.0f));
	//South
    VertexDataUVCoords[1] = float2(uv.x, uv.y + (distance / 100.0f));
	//East
    VertexDataUVCoords[2] = float2(uv.x + (distance / 100.0f), uv.y);
	//West
    VertexDataUVCoords[3] = float2(uv.x - (distance / 100.0f), uv.y);

    float3 VertexDataPosition[4];
	//North
    VertexDataPosition[0] = float3(position.x, position.y, position.z - distance);
	//South
    VertexDataPosition[1] = float3(position.x, position.y, position.z + distance);
	//East
    VertexDataPosition[2] = float3(position.x + distance, position.y, position.z);
	//West
    VertexDataPosition[3] = float3(position.x - distance, position.y, position.z);
	
    for (int i = 0; i < 4; i++)
    {
        VertexDataPosition[i] = float3(VertexDataPosition[i].x, getHeight(VertexDataUVCoords[i]), VertexDataPosition[i].z);
        VertexDataPosition[i] = VertexDataPosition[i] - position;
    }
	
    float3 north = VertexDataPosition[0];
    float3 south = VertexDataPosition[1];
    float3 east = VertexDataPosition[2];
    float3 west = VertexDataPosition[3];
	
    float3 n1 = cross(east, north);
    float3 n2 = cross(south, east);
    float3 n3 = cross(west, south);
    float3 n4 = cross(north, west);
	
    
    return (n1 + n2 + n3 + n4) * 0.25f;
}

OutputType
    main(InputType input)
{
    OutputType output;
	
    input.position.y = getHeight(input.tex);
	
	
    input.normal = calculateNormal(input.tex, float3(input.position.x, input.position.y, input.position.z));
    
	
	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    
    output.lightViewPos = mul(input.position, worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    
    output.secondLightViewPos = mul(input.position, worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);

    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(input.position, worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }

	// Store the texture coordinates for the pixel shader.
    output.tex = input.tex;

	// Calculate the normal vector against the world matrix only and normalise.
    output.normal = mul(input.normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);

    output.worldPosition = mul(input.position, worldMatrix).xyz;
    
    return output;
}