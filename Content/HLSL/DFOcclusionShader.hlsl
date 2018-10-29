const float3 viewDirNorm = normalize(viewDir) * InHeightScale;

const float minDistance = InMinDistance;
const float maxHeight = InHeight;

float currDis = 1.0;

float3 prevTexCoord;
float3 currTexCoord = float3(texCoords, 0);

float selectedMinDistance = 1.0;
float2 selectedTexCoord;

for (int i = 0; i < InSamples; i++)
{
    currDis = SDFMap.SampleGrad(SDFMapSampler, currTexCoord.xy, DDX, DDY).r;
    prevTexCoord = currTexCoord;
    currTexCoord = prevTexCoord + (viewDirNorm * currDis);

    if (currDis < minDistance)
    {
        selectedTexCoord = currTexCoord;
        break;
    }

    if (abs(currTexCoord.z) > maxHeight)
    {
        selectedTexCoord = currTexCoord;
        break;
    }

    if (currTexCoord.x > 1.0 || currTexCoord.y > 1.0 ||
        currTexCoord.x < 0.0 || currTexCoord.y < 0.0)
    {
        selectedTexCoord = saturate(currTexCoord);
        break;
    }

    if (currDis < selectedMinDistance)
    {
        selectedMinDistance = currDis;
        selectedTexCoord = currTexCoord;
    }
}

return selectedTexCoord;