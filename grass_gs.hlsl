// triangle_gs
// Geometry shader that generates a triangle for every vertex.
Texture2D noiseTexture : register(t0);
SamplerState samplerState : register(s0);


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

cbuffer VertexBuffer : register(b1)
{
    float4 cameraPos;
    float4 wind;
};

struct InputType
{
    float3 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float4 colour : COLOR;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 lightViewPos : TEXCOORD1;
    float4 secondLightViewPos: TEXCOORD2;
    float3 worldPosition : TEXCOORD3;
    float4 pointLightViewPositions[6] : TEXCOORD4;
};



[maxvertexcount(7)]
void main(point InputType input[1], inout TriangleStream<OutputType> triStream)
{
    

    float halfWidth = 0.25f;
    float halfHeight = 2;
    
    //Calculate the billboard's normal (campos - position of billboard)
    float3 planeNormal = cameraPos.xyz - input[0].position.xyz;
    //Dont want it rotating on the y axis.
    
    planeNormal.y = 0.0f;
    planeNormal = normalize(planeNormal);
    
    float3 upVector = float3(0.0f, 1.0f, 0.0f);
    float3 rightVector = normalize(cross(planeNormal, upVector));
    
    float4 noiseValue = noiseTexture.SampleLevel(samplerState, input[0].tex,0.0);
    
    
    rightVector = rightVector * halfWidth;
    upVector = float3(0.0f, halfHeight * 2, 0.0f);

    float yHeight = input[0].position.y;
    OutputType output;
    
    float4 colour = float4(0.0f, 0.5f, 0.0f, 1.0f);

    float windDirection = wind.y;
    float windStrength = wind.x;
    float windSpeed = wind.z;
    float totalTime = wind.w;
    
    //If there is no strength to the wind
    if (windStrength == 0)
    {
        //No displacement
        windDirection = 0;
    }
        
   
     
        // Move the vertex away from the point position
    output.position = float4(input[0].position.xyz + upVector, 1.0f);
    
    float sineWave = sin((windStrength * totalTime) * (noiseValue.x * 5));
    
    output.position.x += (sineWave * (noiseValue.x * windSpeed)) + (windDirection);
    output.position.z += (sineWave * (noiseValue.x * windSpeed)) + (windDirection);
    
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    output.lightViewPos = mul(float4(input[0].position,1.0f), worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    output.secondLightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);
    output.worldPosition = mul(float4(input[0].position, 1.0f), worldMatrix).xyz;
    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(float4(input[0].position, 1.0f), worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }
    output.tex = float2(0.5f, 0.0f);
    output.colour = float4(1.0f, 1.0f, 1.0f, 1.0f);
    output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    triStream.Append(output);
    

    output.position = float4(input[0].position.xyz + (upVector / 3) - (rightVector / 2), 1.0f);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    output.lightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    output.secondLightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);
    output.worldPosition = mul(float4(input[0].position, 1.0f), worldMatrix).xyz;
    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(float4(input[0].position, 1.0f), worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }
    output.tex = float2(0.0f, 0.66f);
    output.colour = float4(0.0f, 0.4f, 0.3f, 1.0f);
    output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    triStream.Append(output);

	    // Move the vertex away from the point position
    output.position = float4(input[0].position.xyz + (upVector / 3) + (rightVector / 2), 1.0f);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    output.lightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    output.secondLightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);
    output.worldPosition = mul(float4(input[0].position, 1.0f), worldMatrix).xyz;
    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(float4(input[0].position, 1.0f), worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }
    output.tex = float2(1.0f, 0.66f);
    output.colour = float4(0.0f, 0.4f, 0.3f, 1.0f);
    output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    triStream.Append(output);
    
    output.position = float4(input[0].position.xyz + (upVector / 3) - (rightVector / 2), 1.0f);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    output.lightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    output.secondLightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);
    output.worldPosition = mul(float4(input[0].position, 1.0f), worldMatrix).xyz;
    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(float4(input[0].position, 1.0f), worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }
    output.tex = float2(0.0f, 0.66f);
    output.colour = float4(0.0f, 0.4f, 0.3f, 1.0f);
    output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    triStream.Append(output);

	    // Move the vertex away from the point position

      
    output.position = float4(input[0].position.xyz - rightVector, 1.0f);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    output.lightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    output.secondLightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);
    output.worldPosition = mul(float4(input[0].position, 1.0f), worldMatrix).xyz;
    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(float4(input[0].position, 1.0f), worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }
    output.tex = float2(0.0f, 1.0f);
    output.colour = float4(0.0f, 0.4f, 0.3f, 1.0f);
    output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    triStream.Append(output);
    
    output.position = float4(input[0].position.xyz + rightVector, 1.0f);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    output.lightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    output.secondLightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);
    output.worldPosition = mul(float4(input[0].position, 1.0f), worldMatrix).xyz;
    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(float4(input[0].position, 1.0f), worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }
    output.tex = float2(1.0f, 1.0f);
    output.colour = float4(0.0f, 0.4f, 0.3f, 1.0f);
    output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    triStream.Append(output);
    
    output.position = float4(input[0].position.xyz + (upVector / 3) + (rightVector / 2), 1.0f);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    output.lightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.lightViewPos = mul(output.lightViewPos, lightViewMatrix[0]);
    output.lightViewPos = mul(output.lightViewPos, lightProjectionMatrix[0]);
    output.secondLightViewPos = mul(float4(input[0].position, 1.0f), worldMatrix);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightViewMatrix[1]);
    output.secondLightViewPos = mul(output.secondLightViewPos, lightProjectionMatrix[1]);
    output.worldPosition = mul(float4(input[0].position,1.0f), worldMatrix).xyz;
    for (int i = 0; i < 6; i++)
    {
        output.pointLightViewPositions[i] = mul(float4(input[0].position, 1.0f), worldMatrix);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointLightViewMatrix[i]);
        output.pointLightViewPositions[i] = mul(output.pointLightViewPositions[i], pointProjectionMatrix);
    }
    output.tex = float2(1.0f, 0.66f);
    output.colour = float4(0.0f, 0.4f, 0.3f, 1.0f);
    output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    triStream.Append(output);


      
    triStream.RestartStrip();
}