// Tessellation domain shader
// After tessellation the domain shader processes the all the vertices

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


cbuffer timeBuffer : register(b1)
{
    float4 direction;
    float4 directionWaveTwo;
    float totalTime;
    float3 padding;
}
static const float PI = 3.14159265f;

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
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 lightViewPos : TEXCOORD1;
    float4 secondLightViewPos : TEXCOORD2;
    float3 worldPosition : TEXCOORD3;
    float4 pointLightViewPositions[6] : TEXCOORD4;
};

float3 GernsterWave(float4 wave, float3 position, inout float3 tangent, inout float3 binormal)
{
    float steepness = wave.z;
    
    
    float waveLength = wave.w;
    
    
    float k = 2 * PI / waveLength; // Wave Number
    float c = sqrt(9.8 / k);
    float a = steepness / k;
    float2 dirNorm = normalize(wave.xy);
    float f = k * (dot(dirNorm, position.xz) - c * totalTime);
    float xAmount, yAmount, zAmount;
    
    if (wave.x == 0 && wave.y == 0)
    {
        position = position;
    }
    else
    {
        xAmount = dirNorm.x * (a * cos(f));
        yAmount = a * sin(f);
        zAmount = dirNorm.y * (a * cos(f));
    }
    
    tangent += float3(1 - dirNorm.x * dirNorm.x * (steepness * sin(f)), steepness * cos(f), -dirNorm.x * dirNorm.y * (steepness * sin(f)));
    
    binormal += float3(-dirNorm.x * dirNorm.y * (steepness * sin(f)), dirNorm.y * (steepness * cos(f)), 1 - dirNorm.y * dirNorm.y * (steepness * sin(f)));
    
    return float3(xAmount, yAmount, zAmount);
}


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
    float3 tangent = float3(1, 0, 0);
    float3 binormal = float3(0, 0, 1);
    float4 totalPos = float4(vertexPosition.xyz, 1.0f);
    
    totalPos.xyz += GernsterWave(direction, vertexPosition, tangent, binormal);
    totalPos.xyz += GernsterWave(directionWaveTwo, vertexPosition, tangent, binormal);
    normal = normalize(cross(binormal, tangent));
		    
    // Calculate the position of the new vertex against the world, view, and projection matrices.
    
    float4 finalPos = float4(totalPos.xyz, 1.0f);
    
    
    
    output.position = mul(finalPos, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);

    output.lightViewPos = mul(finalPos, worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    
    output.secondLightViewPos = mul(finalPos, worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);
    
    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(finalPos, worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }
    
    //output.position = float4(vertexPosition.x, vertexPosition.y, vertexPosition.z, 1.0f);

    // Send the input color into the pixel shader.
    
    output.tex = texCoord;
    
    output.worldPosition = mul(finalPos, worldMatrix).xyz;
    
    output.normal = normal;
   

    return output;
}

