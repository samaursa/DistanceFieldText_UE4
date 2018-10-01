float layerDepth = 1.0 / numLayers;

float2 p = viewDir.xy * heightScale;
float2 deltaTexCoords = p / numLayers;

float2 currentTexCoords = texCoords;
float  currentDepthMapValue = Texture2DSample(depthMap, depthMapSampler, currentTexCoords).r;

float currentLayerDepth = 0.0;

float2 dx = ddx(texCoords);
float2 dy = ddy(texCoords);

while (currentLayerDepth < currentDepthMapValue)
{
    currentTexCoords -= deltaTexCoords;
    currentDepthMapValue = depthMap.SampleGrad(depthMapSampler, currentTexCoords, dx, dy).r;
    currentLayerDepth += layerDepth;
}

return currentTexCoords;