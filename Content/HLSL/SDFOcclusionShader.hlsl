const float3 viewDirNorm = normalize(viewDir) * InHeightScale;

const float minDistance = InMinDistance;
const float maxHeight = InHeight;

float currDis = 1.0;

float3 prevTexCoord;
float3 currTexCoord = float3(texCoords, 0);

for (int i = 0; i < InSamples; i++)
{
    currDis = SDFMap.SampleGrad(SDFMapSampler, currTexCoord.xy, DDX, DDY).r;
    prevTexCoord = currTexCoord;
    currTexCoord = prevTexCoord + (viewDirNorm * currDis);

    if (currDis < minDistance)
    {
        break;
    }

    if (abs(currTexCoord.z) > maxHeight)
    {
        break;
    }

    if (currTexCoord.x > 1.0 || currTexCoord.y > 1.0 ||
        currTexCoord.x < 0.0 || currTexCoord.y < 0.0)
    {
        return texCoords;
    }
}

currTexCoord = saturate(currTexCoord);

float afterDis = Texture2DSample(SDFMap, SDFMapSampler, currTexCoord).r;
float weight = afterDis / (afterDis - currDis);
float2 finalTexCoord = prevTexCoord * weight + currTexCoord * (1.0 - weight);

return prevTexCoord;