// https://www.ronja-tutorials.com/post/025-value-noise/

#ifndef VALUE_NOISE
#define VALUE_NOISE

#include "WhiteNoise.cginc"

inline float EaseIn(float interpolator) {
    return interpolator * interpolator;
}

inline float EaseOut(float interpolator) {
    return 1 - EaseIn(1 - interpolator);
}

float EaseInOut(float interpolator) {
    float easeInValue = EaseIn(interpolator);
    float easeOutValue = EaseOut(interpolator);
    return lerp(easeInValue, easeOutValue, interpolator);
}

float ValueNoise2Dto1D(float2 value) {
    float upperLeftCell = Rand2Dto1D(float2(floor(value.x), ceil(value.y)));
    float upperRightCell = Rand2Dto1D(float2(ceil(value.x), ceil(value.y)));
    float lowerLeftCell = Rand2Dto1D(float2(floor(value.x), floor(value.y)));
    float lowerRightCell = Rand2Dto1D(float2(ceil(value.x), floor(value.y)));

    float interpolatorX = EaseInOut(frac(value.x));
    float interpolatorY = EaseInOut(frac(value.y));

    float upperCells = lerp(upperLeftCell, upperRightCell, interpolatorX);
    float lowerCells = lerp(lowerLeftCell, lowerRightCell, interpolatorX);

    float noise = lerp(lowerCells, upperCells, interpolatorY);
    return noise;
}

float ValueNoise3Dto1D(float3 value) {
    float interpolatorX = EaseInOut(frac(value.x));
    float interpolatorY = EaseInOut(frac(value.y));
    float interpolatorZ = EaseInOut(frac(value.z));

    float cellNoiseZ[2];
    [unroll]
    for (int z = 0; z <= 1; z++) {
        float cellNoiseY[2];
        [unroll]
        for (int y = 0; y <= 1; y++) {
            float cellNoiseX[2];
            [unroll]
            for (int x = 0; x <= 1; x++) {
                float3 cell = floor(value) + float3(x, y, z);
                cellNoiseX[x] = Rand3Dto1D(cell);
            }
            cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
        }
        cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
    }
    float noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
    return noise;
}

float3 ValueNoise3Dto3D(float3 value) {
    float interpolatorX = EaseInOut(frac(value.x));
    float interpolatorY = EaseInOut(frac(value.y));
    float interpolatorZ = EaseInOut(frac(value.z));

    float3 cellNoiseZ[2];
    [unroll]
    for (int z = 0; z <= 1; z++) {
        float3 cellNoiseY[2];
        [unroll]
        for (int y = 0; y <= 1; y++) {
            float3 cellNoiseX[2];
            [unroll]
            for (int x = 0; x <= 1; x++) {
                float3 cell = floor(value) + float3(x, y, z);
                cellNoiseX[x] = Rand3Dto3D(cell);
            }
            cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
        }
        cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
    }
    float3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
    return noise;
}


#endif