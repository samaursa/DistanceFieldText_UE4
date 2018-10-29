//////////   COPY FROM HERE //////////

static const float PI = 3.14159265;

float delta = float(1.0/numSamples);

float  shortestDist = 2.0;
float2 shortestCoord = float2(1.0, 1.0);

float col = Texture2DSample(depthMap, depthMapSampler, texCoords).r;

if (InInvertDepthMap > 0.0)
{
    col = 1 - col;
}

for (float radius = 0; radius <= 1.0; radius = radius + delta)
{
    for (float x = 0.0; x <= PI * 2; x = x + ((PI * 2)/ numKernelSamples))
    {
        float currX = sin(x);
        float currY = sin(x - (PI/2));

        float2 dirVec = normalize(float2(currX, currY)) * radius;

        float2 currTexCoords = texCoords + dirVec;
        if (currTexCoords.x < 0.0 || currTexCoords.x > 1.0 ||
            currTexCoords.y < 0.0 || currTexCoords.y > 1.0)
        {
            continue;
        }

        float texVal = depthMap.SampleGrad(depthMapSampler, currTexCoords, DDX, DDY).r;

        if (InInvertDepthMap > 0.0)
        {
            texVal = 1 - texVal;
        }

        if (texVal > surfaceBoundary)
        {
            continue;
        }

        float dist = length(currTexCoords - texCoords);
        if (dist < shortestDist)
        {
            shortestDist = dist;
            shortestCoord = currTexCoords;
        }
    }

    if (shortestDist < 1.0)
    {
        break;
    }
}

// const float3 colOut = float3(length(shortestCoord - texCoords), 0, 0);
//float2 normalizedCol = (shortestCoord - texCoords) + 1) / 2;
float2 normalizedCol = (normalize(shortestCoord - texCoords) + 1) / 2;
const float3 colOut = float3(normalizedCol, shortestDist);
// const float3 colOut = float3(0, 0, shortestDist);

return colOut * ColorMultiplier;