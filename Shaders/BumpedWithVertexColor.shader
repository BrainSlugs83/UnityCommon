Shader "BrainSlugs83/BumpedWithVertexColor"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_HeightMap("Height Map", 2D) = "white" {}
		_HeightPower("Height Power", Range(0,.125)) = 0

		_Smoothness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_RimColor("Rim Color", Color) = (0.26,0.19,0.16,.25)
		_RimPower("Rim Power", Range(0.5,8.0)) = 3.0
		_NormalExtrusion("Normal Extrusion", Range(-1, 1)) = 0.0

		_AtlasWidth("Atlas Width", Int) = 1
		_AtlasHeight("Atlas Height", Int) = 1
		_AtlasBorder("Atlas Border", Range(0, 0.25)) = 0.0
		_AtlasOffsetX("Atlast X", Int) = 0
		_AtlasOffsetY("Atlast Y", Int) = 0

		//_ToonMap("Toonmap", 2D) = "transparent" {}
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
		LOD 200

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
		#include "PerlinNoise.cginc"

		TEXTURE2D(_MainTex);
		SAMPLER(sampler_MainTex);
		TEXTURE2D(_BumpMap);
		SAMPLER(sampler_BumpMap);
		TEXTURE2D(_HeightMap);
		SAMPLER(sampler_HeightMap);

		CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float4 _HeightMap_ST;
			half4 _Color;
			half4 _RimColor;
			half _Smoothness;
			half _Metallic;
			float _RimPower;
			float _NormalExtrusion;
			float _HeightPower;
			int _AtlasWidth;
			int _AtlasHeight;
			int _AtlasOffsetX;
			int _AtlasOffsetY;
			float _AtlasBorder;
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
			half4 color : COLOR;
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
			half4 color : COLOR;
			float4 positionCS : SV_POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct DepthVaryings
		{
			float2 uv : TEXCOORD0;
			float3 positionWS : TEXCOORD1;
			half3 normalWS : TEXCOORD2;
			half4 tangentWS : TEXCOORD3;
			half4 color : COLOR;
			float4 positionCS : SV_POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct MetaVaryings
		{
			float2 uv : TEXCOORD0;
			float3 positionWS : TEXCOORD1;
			half3 normalWS : TEXCOORD2;
			half4 tangentWS : TEXCOORD3;
			half4 color : COLOR;
			#ifdef EDITOR_VISUALIZATION
				float2 VizUV : TEXCOORD4;
				float4 LightCoord : TEXCOORD5;
			#endif
			float4 positionCS : SV_POSITION;
		};

		float2 FixUVs(float2 input, int ox, int oy)
		{
			if (_AtlasWidth > 1 || _AtlasHeight > 1)
			{
				input = frac(input);

				if (_AtlasBorder > 0.0)
				{
					input.x = lerp(_AtlasBorder, 1.0 - _AtlasBorder, input.x);
					input.y = lerp(_AtlasBorder, 1.0 - _AtlasBorder, input.y);
				}

				input.x /= ((float)_AtlasWidth);
				input.y /= ((float)_AtlasHeight);

				input.x += (((float)ox) / ((float)_AtlasWidth));
				input.y += (((float)oy) / ((float)_AtlasHeight));
			}

			return input;
		}

		void GetAtlasOffsets(float3 positionWS, out int ox, out int oy)
		{
			ox = _AtlasOffsetX;
			oy = _AtlasOffsetY;

			float2 rnd = Rand3Dto2D(trunc(positionWS + float3(8000, 8000, 8000)) / 100000);
			if (ox < 0 && _AtlasWidth > 1)
			{
				ox = (int)floor(rnd.x * _AtlasWidth);
			}

			if (oy < 0 && _AtlasHeight > 1)
			{
				oy = (int)floor(rnd.y * _AtlasHeight);
			}
		}

		half4 SampleBumpedAlbedo(
			float2 uv,
			float3 positionWS,
			half4 vertexColor,
			half3 viewDirTS,
			out float2 texOffset,
			out int ox,
			out int oy)
		{
			GetAtlasOffsets(positionWS, ox, oy);
			float2 heightUV = FixUVs(TRANSFORM_TEX(uv, _HeightMap), ox, oy);
			half height = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, heightUV).r;
			texOffset = ParallaxOffset1Step(height, _HeightPower, viewDirTS);
			float2 mainUV = FixUVs(TRANSFORM_TEX(uv, _MainTex) + texOffset, ox, oy);
			return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, mainUV) * _Color * vertexColor;
		}

		half3 GetViewDirectionTS(float3 positionWS, half3 normalWS, half4 tangentWS)
		{
			half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
			return GetViewDirectionTangentSpace(tangentWS, normalWS, viewDirWS);
		}

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

			input.positionOS.xyz += input.normalOS * _NormalExtrusion;
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
			output.color = input.color;
			output.positionCS = positionInputs.positionCS;
			return output;
		}

		half4 ForwardFragment(ForwardVaryings input) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

			half3 viewDirTS = GetViewDirectionTS(input.positionWS, input.normalWS, input.tangentWS);
			float2 texOffset;
			int ox;
			int oy;
			half4 albedo = SampleBumpedAlbedo(
				input.uv,
				input.positionWS,
				input.color,
				viewDirTS,
				texOffset,
				ox,
				oy);

			if (albedo.a <= 0.0)
			{
				clip(-1.0);
			}

			float2 bumpUV = FixUVs(TRANSFORM_TEX(input.uv, _BumpMap) + texOffset, ox, oy);
			half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, bumpUV));

			SurfaceData surfaceData = (SurfaceData)0;
			surfaceData.albedo = albedo.rgb;
			surfaceData.metallic = _Metallic;
			surfaceData.specular = 0.0;
			surfaceData.smoothness = _Smoothness;
			surfaceData.normalTS = normalTS;
			surfaceData.occlusion = 1.0;
			surfaceData.alpha = albedo.a;
			surfaceData.clearCoatMask = 0.0;
			surfaceData.clearCoatSmoothness = 1.0;

			if (_RimColor.a > 0.0)
			{
				half rim = 1.0 - saturate(dot(normalize(viewDirTS), normalTS));
				surfaceData.emission = (_RimColor.rgb * pow(rim, _RimPower)) * _RimColor.a;
			}

			InputData inputData = BuildInputData(input, normalTS);
			half4 color = UniversalFragmentPBR(inputData, surfaceData);
			color.rgb = MixFog(color.rgb, inputData.fogCoord);
			color.a = 1.0;
			return color;
		}

		DepthVaryings BuildDepthVaryings(Attributes input, bool applyShadowBias)
		{
			DepthVaryings output = (DepthVaryings)0;
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_TRANSFER_INSTANCE_ID(input, output);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

			input.positionOS.xyz += input.normalOS * _NormalExtrusion;
			VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
			VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
			half tangentSign = input.tangentOS.w * GetOddNegativeScale();
			float4 positionCS = positionInputs.positionCS;

			if (applyShadowBias)
			{
				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionInputs.positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif
				positionCS = TransformWorldToHClip(
					ApplyShadowBias(positionInputs.positionWS, normalInputs.normalWS, lightDirectionWS));
				positionCS = ApplyShadowClamping(positionCS);
			}

			output.uv = input.texcoord;
			output.positionWS = positionInputs.positionWS;
			output.normalWS = normalInputs.normalWS;
			output.tangentWS = half4(normalInputs.tangentWS, tangentSign);
			output.color = input.color;
			output.positionCS = positionCS;
			return output;
		}

		DepthVaryings ShadowVertex(Attributes input)
		{
			return BuildDepthVaryings(input, true);
		}

		DepthVaryings DepthVertex(Attributes input)
		{
			return BuildDepthVaryings(input, false);
		}

		half DepthFragment(DepthVaryings input) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

			half3 viewDirTS = GetViewDirectionTS(input.positionWS, input.normalWS, input.tangentWS);
			float2 texOffset;
			int ox;
			int oy;
			half4 albedo = SampleBumpedAlbedo(
				input.uv,
				input.positionWS,
				input.color,
				viewDirTS,
				texOffset,
				ox,
				oy);

			if (albedo.a <= 0.0)
			{
				clip(-1.0);
			}

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

			half3 viewDirTS = GetViewDirectionTS(input.positionWS, input.normalWS, input.tangentWS);
			float2 texOffset;
			int ox;
			int oy;
			half4 albedo = SampleBumpedAlbedo(
				input.uv,
				input.positionWS,
				input.color,
				viewDirTS,
				texOffset,
				ox,
				oy);

			if (albedo.a <= 0.0)
			{
				clip(-1.0);
			}

			float2 bumpUV = FixUVs(TRANSFORM_TEX(input.uv, _BumpMap) + texOffset, ox, oy);
			half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, bumpUV));
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
			input.positionOS.xyz += input.normalOS * _NormalExtrusion;
			VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
			VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

			output.positionCS = UnityMetaVertexPosition(
				input.positionOS.xyz,
				input.staticLightmapUV,
				input.dynamicLightmapUV);
			output.uv = input.texcoord;
			output.positionWS = positionInputs.positionWS;
			output.normalWS = normalInputs.normalWS;
			output.tangentWS =
				half4(normalInputs.tangentWS, input.tangentOS.w * GetOddNegativeScale());
			output.color = input.color;
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

		half4 BumpedMetaFragment(MetaVaryings input) : SV_Target
		{
			half3 viewDirTS = GetViewDirectionTS(input.positionWS, input.normalWS, input.tangentWS);
			float2 texOffset;
			int ox;
			int oy;
			half4 albedo = SampleBumpedAlbedo(
				input.uv,
				input.positionWS,
				input.color,
				viewDirTS,
				texOffset,
				ox,
				oy);

			if (albedo.a <= 0.0)
			{
				clip(-1.0);
			}

			float2 bumpUV = FixUVs(TRANSFORM_TEX(input.uv, _BumpMap) + texOffset, ox, oy);
			half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, bumpUV));
			half3 emission = 0.0;
			if (_RimColor.a > 0.0)
			{
				half rim = 1.0 - saturate(dot(normalize(viewDirTS), normalTS));
				emission = (_RimColor.rgb * pow(rim, _RimPower)) * _RimColor.a;
			}

			half alpha = albedo.a;
			BRDFData brdfData;
			InitializeBRDFData(
				albedo.rgb,
				_Metallic,
				0.0,
				_Smoothness,
				alpha,
				brdfData);

			MetaInput metaInput = (MetaInput)0;
			metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
			metaInput.Emission = emission;
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
			#pragma fragment BumpedMetaFragment
			#pragma shader_feature EDITOR_VISUALIZATION
			ENDHLSL
		}
	}

	FallBack "Diffuse"
}
