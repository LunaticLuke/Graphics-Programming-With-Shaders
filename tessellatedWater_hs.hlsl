cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
};

cbuffer tessBuffer : register(b1)
{
    int tessFactor;
    float3 cameraPosition;
    int dynamic;
    float3 padding;
};


struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

struct ConstantOutputType
{
    float edges[4] : SV_TessFactor;
    float inside[2] : SV_InsideTessFactor;
};

struct OutputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

ConstantOutputType PatchConstantFunction(InputPatch<InputType, 4> inputPatch, uint patchId : SV_PrimitiveID)
{
    ConstantOutputType output;
    
    
    matrix rotationMatrix = worldMatrix;
    

    float3 centre = 0.25f * (inputPatch[0].position + inputPatch[1].position + inputPatch[2].position + inputPatch[3].position);
    float4 worldCentre = mul(float4(centre, 1.0f), worldMatrix);
    
    float4 theCam = float4(cameraPosition.x, cameraPosition.y, cameraPosition.z, 1.0f);
    
    //theCam = mul(theCam, worldMatrix);
   

    

    float d = distance(worldCentre.xyz, theCam.xyz);
    
    const float d0 = 5.0f;
    const float d1 = 50.0f;
    
    float tess;
    
    //if dynamically tessellating
    if (dynamic)
    {
        tess = 64.0f * saturate((d1 - d) / (d1 - d0)); //Tesselation is 0 if distance > 50 and tesselation is 64 if less than 5
    }
    else
    {
        //Otherwise use the user defined value.
        tess = tessFactor;
    }
    


    if (tess < 1)
    {
        tess = 1;
    }
    // Set the tessellation factors for the three edges of the triangle.
    output.edges[0] = tess;
    output.edges[1] = tess;
    output.edges[2] = tess;
    output.edges[3] = tess;

    // Set the tessellation factor for tessallating inside the triangle.
    output.inside[0] = tess;
    output.inside[1] = tess;
    
    return output;
}


[domain("quad")]
[partitioning("integer")]
[outputtopology("triangle_ccw")]
[outputcontrolpoints(4)]
[patchconstantfunc("PatchConstantFunction")]
OutputType main(InputPatch<InputType, 4> patch, uint pointId : SV_OutputControlPointID, uint patchId : SV_PrimitiveID)
{
    OutputType output;


    // Set the position for this control point as the output position.
    output.position = patch[pointId].position;

    
    output.tex = patch[pointId].tex;
    
    output.normal = patch[pointId].normal;
    
    return output;
}