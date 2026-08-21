Shader "BrainSlugs83/Flashy"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Color2 ("FlashColor", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bumpmap", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_FlashSpeed("Flash Speed", Range(.01, 100)) = 1
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
		LOD 200

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

		TEXTURE2D(_MainTex);
		SAMPLER(sampler_MainTex);
		TEXTURE2D(_BumpMap);
		SAMPLER(sampler_BumpMap);

		CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			half4 _Color;
			half4 _Color2;
			half _Glossiness;
			half _Metallic;
			float _FlashSpeed;
		CBUFFER_END

		float3 _LightDirection;
		float3 _LightPosition;

		struct Attributes
		{
			float4 positionOS : POSITION;
			float3 normalOS : NORMAL;
			float4 tangentOS : TANGENT;
			float2 texcoord : TEXCOORD0;
			float2 staticLightmapUV : TEXCOORD1;
			float2 dynamicLightmapUV : TEXCOORD2;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct ForwardVaryings
		{
			float2 uv : TEXCOORD0;
			float3 positionWS : TEXCOORD1;
			half3 normalWS : TEXCOORD2;
			half4 tangentWS : TEXCOORD3;
			half fogFactor : TEXCOORD4;
			half3 vertexLighting : TEXCOORD5;
			DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 6);
			#ifdef DYNAMICLIGHTMAP_ON
				float2 dynamicLightmapUV : TEXCOORD7;
			#endif
			float4 positionCS : SV_POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct DepthVaryings
		{
			float4 positionCS : SV_POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct MetaVaryings
		{
			float2 uv : TEXCOORD0;
			#ifdef EDITOR_VISUALIZATION
				float2 VizUV : TEXCOORD1;
				float4 LightCoord : TEXCOORD2;
			#endif
			float4 positionCS : SV_POSITION;
		};

		InputData BuildInputData(ForwardVaryings input, half3 normalTS)
		{
			InputData inputData = (InputData)0;
			half3 bitangentWS = input.tangentWS.w * cross(input.normalWS, input.tangentWS.xyz);
			half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangentWS, input.normalWS);

			inputData.positionWS = input.positionWS;
			inputData.positionCS = input.positionCS;
			inputData.normalWS = NormalizeNormalPerPixel(TransformTangentToWorld(normalTS, tangentToWorld));
			inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
			inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
			inputData.fogCoord = input.fogFactor;
			inputData.vertexLighting = input.vertexLighting;
			#ifdef DYNAMICLIGHTMAP_ON
				inputData.bakedGI = SAMPLE_GI(
					input.staticLightmapUV,
					input.dynamicLightmapUV,
					input.vertexSH,
					inputData.normalWS);
			#else
				inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
			#endif
			inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
			inputData.tangentToWorld = tangentToWorld;
			return inputData;
		}

		ForwardVaryings ForwardVertex(Attributes input)
		{
			ForwardVaryings output = (ForwardVaryings)0;
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_TRANSFER_INSTANCE_ID(input, output);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

			VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
			VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
			half tangentSign = input.tangentOS.w * GetOddNegativeScale();

			output.uv = input.texcoord;
			output.positionWS = positionInputs.positionWS;
			output.normalWS = normalInputs.normalWS;
			output.tangentWS = half4(normalInputs.tangentWS, tangentSign);
			output.fogFactor = ComputeFogFactor(positionInputs.positionCS.z);
			output.vertexLighting = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
			OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
			#ifdef DYNAMICLIGHTMAP_ON
				output.dynamicLightmapUV =
					input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
			#endif
			OUTPUT_SH(normalInputs.normalWS, output.vertexSH);
			output.positionCS = positionInputs.positionCS;
			return output;
		}

		half4 ForwardFragment(ForwardVaryings input) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

			half4 c1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
			half4 c2 = c1 * _Color2;
			c1 *= _Color;
			float t = sin(_Time.y * _FlashSpeed) * .5 + .5;
			half3 normalTS =
				UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(input.uv, _BumpMap)));

			SurfaceData surfaceData = (SurfaceData)0;
			surfaceData.albedo = lerp(c1.rgb, c2.rgb, t);
			surfaceData.metallic = _Metallic;
			surfaceData.specular = 0.0;
			surfaceData.smoothness = _Glossiness;
			surfaceData.normalTS = normalTS;
			surfaceData.occlusion = 1.0;
			surfaceData.alpha = lerp(c1.a, c2.a, t);
			surfaceData.clearCoatMask = 0.0;
			surfaceData.clearCoatSmoothness = 1.0;

			InputData inputData = BuildInputData(input, normalTS);
			half4 color = UniversalFragmentPBR(inputData, surfaceData);
			color.rgb = MixFog(color.rgb, inputData.fogCoord);
			return color;
		}

		DepthVaryings ShadowVertex(Attributes input)
		{
			DepthVaryings output = (DepthVaryings)0;
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_TRANSFER_INSTANCE_ID(input, output);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

			float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
			float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
			#if _CASTING_PUNCTUAL_LIGHT_SHADOW
				float3 lightDirectionWS = normalize(_LightPosition - positionWS);
			#else
				float3 lightDirectionWS = _LightDirection;
			#endif
			output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
			output.positionCS = ApplyShadowClamping(output.positionCS);
			return output;
		}

		DepthVaryings DepthVertex(Attributes input)
		{
			DepthVaryings output = (DepthVaryings)0;
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_TRANSFER_INSTANCE_ID(input, output);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
			output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
			return output;
		}

		half DepthFragment(DepthVaryings input) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
			return input.positionCS.z;
		}

		MetaVaryings MetaVertex(Attributes input)
		{
			MetaVaryings output = (MetaVaryings)0;
			output.positionCS = UnityMetaVertexPosition(
				input.positionOS.xyz,
				input.staticLightmapUV,
				input.dynamicLightmapUV);
			output.uv = input.texcoord;
			#ifdef EDITOR_VISUALIZATION
				UnityEditorVizData(
					input.positionOS.xyz,
					input.texcoord,
					input.staticLightmapUV,
					input.dynamicLightmapUV,
					output.VizUV,
					output.LightCoord);
			#endif
			return output;
		}

		half4 FlashyMetaFragment(MetaVaryings input) : SV_Target
		{
			half4 c1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
			half4 c2 = c1 * _Color2;
			c1 *= _Color;
			float t = sin(_Time.y * _FlashSpeed) * .5 + .5;
			half3 albedo = lerp(c1.rgb, c2.rgb, t);

			half alpha = lerp(c1.a, c2.a, t);
			BRDFData brdfData;
			InitializeBRDFData(
				albedo,
				_Metallic,
				0.0,
				_Glossiness,
				alpha,
				brdfData);

			MetaInput metaInput = (MetaInput)0;
			metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
			metaInput.Emission = 0.0;
			#ifdef EDITOR_VISUALIZATION
				metaInput.VizUV = input.VizUV;
				metaInput.LightCoord = input.LightCoord;
			#endif
			return UnityMetaFragment(metaInput);
		}
		ENDHLSL

		Pass
		{
			Name "UniversalForward"
			Tags { "LightMode" = "UniversalForward" }
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ZWrite Off

			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex ForwardVertex
			#pragma fragment ForwardFragment
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _LIGHT_LAYERS
			#pragma multi_compile _ _CLUSTER_LIGHT_LOOP
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			Cull Back
			ZWrite On
			ZTest LEqual
			ColorMask 0

			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex ShadowVertex
			#pragma fragment DepthFragment
			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
			#pragma multi_compile_instancing
			ENDHLSL
		}

		Pass
		{
			Name "DepthOnly"
			Tags { "LightMode" = "DepthOnly" }
			Cull Back
			ZWrite On
			ColorMask R

			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex DepthVertex
			#pragma fragment DepthFragment
			#pragma multi_compile_instancing
			ENDHLSL
		}

		Pass
		{
			Name "Meta"
			Tags { "LightMode" = "Meta" }
			Cull Off

			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex MetaVertex
			#pragma fragment FlashyMetaFragment
			#pragma shader_feature EDITOR_VISUALIZATION
			ENDHLSL
		}
	}

	FallBack "Diffuse"
}
