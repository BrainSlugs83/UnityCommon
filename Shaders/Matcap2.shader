Shader "BrainSlugs83/Matcap2"
{
    Properties
    {
        // Potential Bug #34: This is a bug because Matcap2 always applies perspective correction and cannot reproduce the original Matcap shader's uncorrected view-normal mode.
        // Suggested Fix: Add the same _PerspectiveCorrection property and branch between corrected and uncorrected cap calculations.
        // Related: #25.
        _Matcap("Matcap", 2D) = "white"
        // Potential Bug #35: This is a bug because the inspector exposes tiling and offset for all three matcap layers but the shader never declares or applies their _ST values.
        // Suggested Fix: Mark _Matcap, _AddOverlay, and _MultOverlay with [NoScaleOffset], or declare and apply each texture transform deliberately.
        // Related: #32.
        _AddOverlay("AddOverlay", 2D) = "black"
        _MultOverlay("MultOverlay", 2D) = "white"
        _Exposure("Exposure", Float) = 1.0
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Flicker("Flicker", Float) = 0
        _FlickerSpeed("FlickerSpeed", Float) = 0
        _RollSpeedX("RollSpeedX", Float) = 0
        _RollSpeedY("RollSpeedY", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "SRPDefaultUnlit" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                // Potential Bug #36: This is a bug because multiplying by an absent mesh COLOR attribute relies on backend-specific default attribute values and can render an otherwise valid mesh black.
                // Suggested Fix: Add a shader feature that bypasses vertex-color multiplication for meshes without colors, or document and enforce a white vertex-color channel.
                // Related: #33.
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                // Potential Bug #28: This is a bug because POSITIONT is a legacy pre-transformed-position semantic rather than a portable generic interpolator across all URP graphics backends.
                // Suggested Fix: Store viewDir in an unused TEXCOORD semantic such as TEXCOORD0.
                // Related: #29.
                float3 viewDir : POSITIONT;
                half3 tspace0 : TEXCOORD1;
                half3 tspace1 : TEXCOORD2;
                half3 tspace2 : TEXCOORD3;
                float2 uv : TEXCOORD4;
                float4 color : COLOR;
            };

            TEXTURE2D(_Matcap);
            SAMPLER(sampler_Matcap);
            TEXTURE2D(_AddOverlay);
            SAMPLER(sampler_AddOverlay);
            TEXTURE2D(_MultOverlay);
            SAMPLER(sampler_MultOverlay);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _NormalMap_ST;
                float _Exposure;
                float _Flicker;
                float _FlickerSpeed;
                float _RollSpeedX;
                float _RollSpeedY;
            CBUFFER_END

            half shade(half input)
            {
                if (input < 0.25f) { return 0.33333333f; }
                if (input < 0.50f) { return 0.55555556f; }
                if (input < 0.75f) { return 0.86274509f; }
                return 1.0f;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);

                float3 viewPos = TransformWorldToView(TransformObjectToWorld(v.vertex.xyz));
                o.viewDir = normalize(viewPos);

                half3 wNormal = TransformObjectToWorldNormal(v.normal);
                half3 wTangent = TransformObjectToWorldDir(v.tangent.xyz);
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;

                o.uv = v.uv * _NormalMap_ST.xy + _NormalMap_ST.zw
                    + float2(_Time.y * _RollSpeedX, _Time.y * _RollSpeedY);
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
                o.color = v.color;

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half3 tnormal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv));
                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);

                // Potential Bug #29: This is a bug because interpolated viewDir and reconstructed worldNormal are used without fragment renormalization, distorting cap coordinates and potentially sampling outside the matcap disc.
                // Suggested Fix: Normalize i.viewDir and worldNormal in the fragment shader before transforming and crossing them.
                // Related: #26, #28, #30.
                half3 viewNorm = TransformWorldToViewDir(worldNormal);
                float3 viewCross = cross(i.viewDir, viewNorm);
                float2 cap = float2(-viewCross.y, viewCross.x) * 0.5 + 0.5;

                // Potential Bug #30: This is a bug because matcap coordinates can leave the expected range and Repeat-wrapped matcap textures then sample the opposite edge, producing silhouette seams.
                // Suggested Fix: Clamp cap to the valid range and import the matcap and overlay textures with Clamp wrap mode.
                // Related: #29.
                half4 col = SAMPLE_TEXTURE2D(_Matcap, sampler_Matcap, cap);
                half4 add = SAMPLE_TEXTURE2D(_AddOverlay, sampler_AddOverlay, cap);
                half4 mult = SAMPLE_TEXTURE2D(_MultOverlay, sampler_MultOverlay, cap);

                col = (col + add) * mult;
                float e = _Exposure + (cos(_Time.x * _FlickerSpeed) * _Flicker);

                col *= e;
                col.a = 1.0;

                return col * i.color;
            }
            ENDHLSL
        }
        // Potential Bug #31: This is a bug because the shader has no ShadowCaster or depth pass, so objects can fail to cast shadows or participate in renderer depth features.
        // Suggested Fix: Add URP ShadowCaster and DepthOnly passes that reproduce the forward pass geometry and clipping behavior.
        // Related: #27.
    }
}
