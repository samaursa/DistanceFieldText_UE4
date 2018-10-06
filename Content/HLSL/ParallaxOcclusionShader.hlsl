float layerDepth = 1.0 / numLayers;

float2 p = viewDir.xy * heightScale;
float2 deltaTexCoords = p / numLayers;

float2 currentTexCoords = texCoords;
float  currentDepthMapValue = Texture2DSample(depthMap, depthMapSampler, currentTexCoords).r;

float currentLayerDepth = 0.0;

while (currentLayerDepth < currentDepthMapValue)
{
    currentTexCoords -= deltaTexCoords;
    currentDepthMapValue = depthMap.SampleGrad(depthMapSampler, currentTexCoords, ddx, ddy).r;
    currentLayerDepth += layerDepth;
}

const float2 prevTexCoords = currentTexCoords + deltaTexCoords;
float afterDepth = currentDepthMapValue - currentLayerDepth;
float beforeDepth = Texture2DSample(depthMap, depthMapSampler, prevTexCoords).r - currentLayerDepth + layerDepth;

float weight = afterDepth / (afterDepth - beforeDepth);
float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

return finalTexCoords;