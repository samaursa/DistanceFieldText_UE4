const float3 viewDirNorm = normalize(viewDir) * InHeightScale;

const float minDistance = InMinDistance;
const float maxHeight = InHeight;

float prevDis = 1.0;
float currDis = 1.0;

float3 prevTexCoord;
float3 currTexCoord = float3(texCoords, 0);

float selectedMinDistance = 1.0;
float2 selectedTexCoord;

for (int i = 0; i < InSamples; i++)
{
    float2 dirToSurf = SDFMap.SampleGrad(SDFMapSampler, currTexCoord.xy, DDX, DDY).rg;
    dirToSurf = (dirToSurf * 2) - 1; // * -1 because we want to inverse dir vector
    dirToSurf = normalize(viewDirNorm.xy);

    prevDis = currDis;
    currDis = SDFMap.SampleGrad(SDFMapSampler, currTexCoord.xy, DDX, DDY).b;

    const float t = currDis / (dot(viewDirNorm, float3(dirToSurf, 0)));

/*
    const float d = currDis;
    const float3 P0 = currTexCoord;
    const float3 N = normalize(float3(dirToSurf, 0)) * -1;
    const float3 V = viewDirNorm;

    const float t_num = -(d + dot(P0, N));
    const float t_den = dot(V, N);
    const float t = t_num / t_den;
    */

/*
    const float3 P0 = currTexCoord + (float3(dirToSurf, 0) * currDis);
    const float3 L0 = currTexCoord;
    const float3 N = float3(dirToSurf, 0) * -1;
    const float3 L = viewDirNorm;

    const float t = ( dot((P0 - L0), N) / dot(L, N));
    */

    prevTexCoord = currTexCoord;
    // currTexCoord = prevTexCoord + (viewDirNorm * t);
    currTexCoord = prevTexCoord + (viewDirNorm * currDis * T_Multiplier);

    if (currDis < minDistance)
    {
        float weight = currDis / (currDis - prevDis);
        selectedTexCoord = prevTexCoord * weight + currTexCoord * (1.0 - weight);
        break;
    }

    if (abs(currTexCoord.z) > maxHeight)
    {
        float weight = currTexCoord.z / (currTexCoord.z - prevTexCoord.z);
        selectedTexCoord = prevTexCoord * weight + currTexCoord * (1.0 - weight);
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