float layerDepth = 1.0 / numLayers;

float2 p = viewDir.xy * heightScale;
float2 deltaTexCoords = p / numLayers;

float2 currentTexCoords = texCoords;
float  currentDepthMapValue = 1.0 - Texture2DSample(depthMap, depthMapSampler, currentTexCoords).r;

float currentLayerDepth = 0.0;

while (currentLayerDepth < currentDepthMapValue)
{
    currentTexCoords -= deltaTexCoords;
    currentDepthMapValue = 1.0 - depthMap.SampleGrad(depthMapSampler, currentTexCoords, ddx, ddy).r;
    currentLayerDepth += layerDepth;
}

return currentTexCoords;