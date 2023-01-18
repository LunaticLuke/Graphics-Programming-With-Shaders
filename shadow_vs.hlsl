
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


OutputType main(InputType input)
{
    OutputType output;

	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    
	// Calculate the position of the vertice as viewed by the light source.
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
    
    output.tex = input.tex;
    output.normal = mul(input.normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    
    output.worldPosition = mul(input.position, worldMatrix).xyz;

    return output;
}