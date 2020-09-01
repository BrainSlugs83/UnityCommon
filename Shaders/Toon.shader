Shader "BrainSlugs83/Toon"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Tags
			{
				"RenderType" = "Opaque"
				"LightMode" = "Always"
			}
			Lighting Off
			ZWrite On
			LOD 100

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

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

			sampler2D _MainTex;

			float4 _MainTex_ST;

			half shade(half input)
			{
				/*if (input < .33f) { return (1.0f / 3.0f); }
				if (input < .67f) { return (2.0f / 3.0f); }
				return 1.0f;*/

				if (input < 0.25f) { return 0.44444444f; }
				if (input < 0.50f) { return 0.66666667f; }
				if (input < 0.75f) { return 0.86274509f; }
				return 1.0f;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//o.viewDir = WorldSpaceViewDir(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				half light = (dot(_WorldSpaceLightPos0, o.worldNormal) / 2.0f) + .5f;

				o.halfVector = normalize(_WorldSpaceLightPos0 + WorldSpaceViewDir(v.vertex));

				o.vertexColor = v.vertexColor;
				o.light = light * light * light;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//float3 normal = i.worldNormal;
				//float NdotL = dot(_WorldSpaceLightPos0, normal);
				//float lightAmount = (NdotL / 2.0f) + 0.5f;

				//float3 viewDir = normalize(i.viewDir);
				////float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
				float rim = dot(i.worldNormal, i.halfVector);
				//float NdotH = dot(normal, viewDir);

				//lightAmount = (shade(lightAmount) * 4.0f + shade(rimbo)) / 5.0f;

				half4 col = tex2D(_MainTex, i.uv) * i.vertexColor * shade(i.light + rim);
				//half4 light = lightAmount * lightAmount * _LightColor0;

				//float ra = .9;
				//ra *= ra;
				//float outline = rimDot; // smoothstep(ra - 0.01, ra + 0.01, rimDot);

				//return lightAmount;

				float l = max(shade(0), min(1, lerp(shade(i.light * 2), rim * 2, .25f)));

				return l * col; // (_AmbientColor + light + specular + rim);
			}
			ENDCG
		}
	}
}