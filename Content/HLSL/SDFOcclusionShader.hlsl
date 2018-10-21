const float3 viewDirNorm = normalize(viewDir);

const float minDistance = 0.1;

float currDis = Texture2DSample(SDFMap, SDFMapSampler, texCoords).r;
if (currDis < minDistance)
{
    return texCoords;
}

float3 nextTexCoord = float3(texCoords, 0);

for (int i = 0; i < 50; i++)
{
    nextTexCoord = nextTexCoord + (viewDirNorm * currDis);

    if (nextTexCoord.z > 0.1)
    {
        nextTexCoord = nextTexCoord - (viewDirNorm * currDis);
        break;
    }

    if (nextTexCoord.x > 1.0 || nextTexCoord.y > 1.0 ||
        nextTexCoord.x < 0.0 || nextTexCoord.y < 0.0)
    {
        nextTexCoord = nextTexCoord - (viewDirNorm * currDis);
        break;
    }

    currDis = SDFMap.SampleGrad(SDFMapSampler, nextTexCoord.xy, DDX, DDY).r;

    if (currDis < minDistance)
    {
        break;
    }
}

return saturate(nextTexCoord.xy);