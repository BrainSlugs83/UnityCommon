Shader "BrainSlugs83/Seamless"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bumpmap", 2D) = "bump" {}
		_AoTex("AO (R)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_CellSize("Cell Size", Range(0, 1)) = .5
		_UVScale("UV Scale", Float) = 1.0


	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
		LOD 300

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
		#include "PerlinNoise.cginc"

		TEXTURE2D(_MainTex);
		SAMPLER(sampler_MainTex);
		TEXTURE2D(_BumpMap);
		SAMPLER(sampler_BumpMap);
		TEXTURE2D(_AoTex);
		SAMPLER(sampler_AoTex);

		CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float4 _AoTex_ST;
			half4 _Color;
			half _Glossiness;
			half _Metallic;
			float _CellSize;
			float _UVScale;
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
			float3 positionWS : TEXCOORD0;
			half3 normalWS : TEXCOORD1;
			half4 tangentWS : TEXCOORD2;
			half fogFactor : TEXCOORD3;
			half3 vertexLighting : TEXCOORD4;
			DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 5);
			#ifdef DYNAMICLIGHTMAP_ON
				float2 dynamicLightmapUV : TEXCOORD6;
			#endif
			float discoloration : TEXCOORD7;
			float4 positionCS : SV_POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct DepthVaryings
		{
			float3 positionWS : TEXCOORD0;
			half3 normalWS : TEXCOORD1;
			half4 tangentWS : TEXCOORD2;
			float4 positionCS : SV_POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct MetaVaryings
		{
			float3 positionWS : TEXCOORD0;
			float discoloration : TEXCOORD1;
			#ifdef EDITOR_VISUALIZATION
				float2 VizUV : TEXCOORD2;
				float4 LightCoord : TEXCOORD3;
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
			output.discoloration = 0.0;
			output.positionCS = positionInputs.positionCS;
			return output;
		}

		half4 ForwardFragment(ForwardVaryings input) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

			float2 uv = float2(input.positionWS.x, input.positionWS.z) * _UVScale;
			half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * _Color;
			albedo.rgb += float3(input.discoloration, input.discoloration, input.discoloration);
			half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
			half4 ao = SAMPLE_TEXTURE2D(_AoTex, sampler_AoTex, uv);

			SurfaceData surfaceData = (SurfaceData)0;
			surfaceData.albedo = albedo.rgb;
			surfaceData.metallic = _Metallic;
			surfaceData.specular = 0.0;
			surfaceData.smoothness = _Glossiness;
			surfaceData.normalTS = normalTS;
			surfaceData.occlusion = ao.r;
			surfaceData.alpha = ao.a;
			surfaceData.clearCoatMask = 0.0;
			surfaceData.clearCoatSmoothness = 1.0;

			InputData inputData = BuildInputData(input, normalTS);
			half4 color = UniversalFragmentPBR(inputData, surfaceData);
			color.rgb = MixFog(color.rgb, inputData.fogCoord);
			color.a = 1.0;
			return color;
		}

		DepthVaryings ShadowVertex(Attributes input)
		{
			DepthVaryings output = (DepthVaryings)0;
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_TRANSFER_INSTANCE_ID(input, output);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

			float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
			VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
			float3 normalWS = normalInputs.normalWS;
			#if _CASTING_PUNCTUAL_LIGHT_SHADOW
				float3 lightDirectionWS = normalize(_LightPosition - positionWS);
			#else
				float3 lightDirectionWS = _LightDirection;
			#endif
			output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
			output.positionCS = ApplyShadowClamping(output.positionCS);
			output.positionWS = positionWS;
			output.normalWS = normalInputs.normalWS;
			output.tangentWS =
				half4(normalInputs.tangentWS, input.tangentOS.w * GetOddNegativeScale());
			return output;
		}

		DepthVaryings DepthVertex(Attributes input)
		{
			DepthVaryings output = (DepthVaryings)0;
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_TRANSFER_INSTANCE_ID(input, output);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
			VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
			VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
			output.positionWS = positionInputs.positionWS;
			output.normalWS = normalInputs.normalWS;
			output.tangentWS =
				half4(normalInputs.tangentWS, input.tangentOS.w * GetOddNegativeScale());
			output.positionCS = positionInputs.positionCS;
			return output;
		}

		half DepthFragment(DepthVaryings input) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
			return input.positionCS.z;
		}

		void DepthNormalsFragment(
			DepthVaryings input,
			out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out uint outRenderingLayers : SV_Target1
			#endif
		)
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

			float2 uv = float2(input.positionWS.x, input.positionWS.z) * _UVScale;
			half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
			half3 bitangentWS = input.tangentWS.w * cross(input.normalWS, input.tangentWS.xyz);
			half3 normalWS = NormalizeNormalPerPixel(
				TransformTangentToWorld(
					normalTS,
					half3x3(input.tangentWS.xyz, bitangentWS, input.normalWS)));

			#ifdef _GBUFFER_NORMALS_OCT
				float2 octNormalWS = PackNormalOctQuadEncode(normalWS);
				float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
				outNormalWS = half4(PackFloat2To888(remappedOctNormalWS), 0.0);
			#else
				outNormalWS = half4(normalWS, 0.0);
			#endif

			#ifdef _WRITE_RENDERING_LAYERS
				outRenderingLayers = EncodeMeshRenderingLayer();
			#endif
		}

		MetaVaryings MetaVertex(Attributes input)
		{
			MetaVaryings output = (MetaVaryings)0;
			output.positionCS = UnityMetaVertexPosition(
				input.positionOS.xyz,
				input.staticLightmapUV,
				input.dynamicLightmapUV);
			output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
			output.discoloration = 0.0;
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

		half4 SeamlessMetaFragment(MetaVaryings input) : SV_Target
		{
			float2 uv = float2(input.positionWS.x, input.positionWS.z) * _UVScale;
			half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb * _Color.rgb;
			albedo += float3(input.discoloration, input.discoloration, input.discoloration);

			half alpha = 1.0;
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
			Tags { "LightMode" = "UniversalForwardOnly" }
			Cull Back
			ZWrite On

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
			Name "DepthNormals"
			Tags { "LightMode" = "DepthNormalsOnly" }
			Cull Back
			ZWrite On

			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex DepthVertex
			#pragma fragment DepthNormalsFragment
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_instancing
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
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
			#pragma fragment SeamlessMetaFragment
			#pragma shader_feature EDITOR_VISUALIZATION
			ENDHLSL
		}
	}

	FallBack "Standard"
}
