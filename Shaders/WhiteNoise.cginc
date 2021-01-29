// source: https://www.ronja-tutorials.com/post/024-white-noise/

#ifndef WHITE_NOISE
#define WHITE_NOISE

float Rand3Dto1D(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719))
{
    //make value smaller to avoid artefacts
    float3 smallValue = sin(value);
    //get scalar value from 3D vector
    float random = dot(smallValue, dotDir);
    //make value more random by making it bigger and then taking the factional part
    random = frac(sin(random) * 143758.5453);
    return random;
}

float Rand2Dto1D(float2 value, float2 dotDir = float2(12.9898, 78.233))
{
    float2 smallValue = sin(value);
    float random = dot(smallValue, dotDir);
    random = frac(sin(random) * 143758.5453);
    return random;
}

float Rand1Dto1D(float3 value, float mutator = 0.546)
{
    float random = frac(sin(value + mutator) * 143758.5453);
    return random;
}

//to 2D functions

float2 Rand3Dto2D(float3 value)
{
    return float2
    (
        Rand3Dto1D(value, float3(12.989, 78.233, 37.719)),
        Rand3Dto1D(value, float3(39.346, 11.135, 83.155))
    );
}

float2 Rand2Dto2D(float2 value)
{
    return float2
    (
        Rand2Dto1D(value, float2(12.989, 78.233)),
        Rand2Dto1D(value, float2(39.346, 11.135))
    );
}

float2 Rand1Dto2D(float value)
{
    return float2
    (
        Rand2Dto1D(value, 3.9812),
        Rand2Dto1D(value, 7.1536)
    );
}

//to 3D functions

float3 Rand3Dto3D(float3 value)
{
    return float3
    (
        Rand3Dto1D(value, float3(12.989, 78.233, 37.719)),
        Rand3Dto1D(value, float3(39.346, 11.135, 83.155)),
        Rand3Dto1D(value, float3(73.156, 52.235, 09.151))
    );
}

float3 Rand2Dto3D(float2 value) {
    return float3(
        Rand2Dto1D(value, float2(12.989, 78.233)),
        Rand2Dto1D(value, float2(39.346, 11.135)),
        Rand2Dto1D(value, float2(73.156, 52.235))
        );
}

float3 Rand1Dto3D(float value)
{
    return float3
    (
        Rand1Dto1D(value, 3.9812),
        Rand1Dto1D(value, 7.1536),
        Rand1Dto1D(value, 5.7241)
    );
}

#endif