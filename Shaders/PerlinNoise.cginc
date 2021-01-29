
#ifndef PERLIN_NOISE
#define PERLIN_NOISE

#include "ValueNoise.cginc"

float PerlinNoise3Dto1D(float3 value)
{
	float3 fraction = frac(value);

	float interpolatorX = EaseInOut(fraction.x);
	float interpolatorY = EaseInOut(fraction.y);
	float interpolatorZ = EaseInOut(fraction.z);

	float cellNoiseZ[2];
	[unroll]
	for(int z=0;z<=1;z++){
		float cellNoiseY[2];
		[unroll]
		for(int y=0;y<=1;y++){
			float cellNoiseX[2];
			[unroll]
			for(int x=0;x<=1;x++){
				float3 cell = floor(value) + float3(x, y, z);
				float3 cellDirection = Rand3Dto3D(cell) * 2 - 1;
				float3 compareVector = fraction - float3(x, y, z);
				cellNoiseX[x] = dot(cellDirection, compareVector);
			}
			cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
		}
		cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
	}
	float noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
	return noise;
}

float3 PerlinNoise3D(float3 value)
{
	float x = PerlinNoise3Dto1D(value + float3(37189.65849, 563454.31278, 3120.9549));
	float y = PerlinNoise3Dto1D(value + float3(2318.59, 542.395, 9473.55));
	float z = PerlinNoise3Dto1D(value + float3(-3218.2001, 483.69654, -6325.4815));

	return float3(x, y, z);
}

#endif