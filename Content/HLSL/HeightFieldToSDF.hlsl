// float2 texCoords;
// float  numSamples = 10;
// float  surfaceBoundary = 0.8;
// float  DDX;
// float  DDY;
// sampler depthMap;

//////////   COPY FROM HERE //////////

static const float PI = 3.14159265;

float delta = float(1.0/numSamples);

float  shortestDist = 2.0;
float2 shortestCoord = float2(1.0, 1.0);

const float col = Texture2DSample(depthMap, depthMapSampler, texCoords).r;
if (col >= surfaceBoundary)
{
    return float3(texCoords, 0);
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

        if (texVal < surfaceBoundary)
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

// const float3 colOut = float3(shortestDist, 0, 0);
// const float3 colOut = float3(length(shortestCoord - texCoords), 0, 0);
const float3 colOut = float3(shortestCoord, 0);

return colOut;

// ---------------- SQUARE KERNEL ----------------

/*
for (float radius = 0.0; radius <= 0.5; radius = radius + delta)
{
    for (float x = -delta - radius; x <= (delta + radius); x = x + delta)
    {
        for (float y = -delta - radius; y <= (delta + radius); y = y + delta)
        {
            const float2 currTexCoords = texCoords + float2(x, y);

            if (currTexCoords.x < 0.0 || currTexCoords.x > 1.0 ||
                currTexCoords.y < 0.0 || currTexCoords.y > 1.0)
            {
                continue;
            }

            float texVal = depthMap.SampleGrad(depthMapSampler, currTexCoords, DDX, DDY).r;

            if (texVal < surfaceBoundary)
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
    }
}
*/
