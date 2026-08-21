Shader "BrainSlugs83/Toon"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"RenderPipeline" = "UniversalPipeline"
		}

		Pass
		{
			Tags { "LightMode" = "UniversalForwardOnly" }
			Lighting Off
			ZWrite On
			LOD 100

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				half3 normal : NORMAL;
				half4 vertexColor : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				half3 worldNormal : NORMAL;
				half3 halfVector : TEXCOORD1;
				half4 vertexColor : COLOR;
				half light : DERP;
			};

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
			CBUFFER_END

			half shade(half input)
			{
				if (input < 0.25f) { return 0.44444444f; }
				if (input < 0.50f) { return 0.66666667f; }
				if (input < 0.75f) { return 0.86274509f; }
				return 1.0f;
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				o.worldNormal = TransformObjectToWorldNormal(v.normal);
				Light mainLight = GetMainLight();
				half light = (dot(mainLight.direction, o.worldNormal) / 2.0f) + 0.5f;

				float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 viewDir = GetCameraPositionWS() - worldPos;
				o.halfVector = normalize(mainLight.direction + viewDir);

				o.vertexColor = v.vertexColor;
				o.light = light * light * light;
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				float rim = dot(i.worldNormal, i.halfVector);
				half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv)
					* i.vertexColor * shade(i.light + rim);

				float l = max(shade(0), min(1, lerp(shade(i.light * 2), rim * 2, 0.25f)));

				return l * col;
			}
			ENDHLSL
		}
	}
}
