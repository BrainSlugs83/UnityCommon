Shader "BrainSlugs83/Matcap"
{
    Properties
    {
        // Potential Bug #32: This is a bug because the material inspector exposes Matcap tiling and offset controls but the shader never declares or applies _Matcap_ST, so those controls silently do nothing.
        // Suggested Fix: Add [NoScaleOffset] to _Matcap when transforms are unsupported, or declare _Matcap_ST and transform its lookup coordinates.
        // Related: #35.
        _Matcap("Matcap", 2D) = "white"
        [Toggle] _PerspectiveCorrection("Use Perspective Correction", Float) = 1.0
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
                // Potential Bug #33: This is a bug because multiplying by an absent mesh COLOR attribute relies on backend-specific default attribute values and can render an otherwise valid mesh black.
                // Suggested Fix: Add a shader feature that bypasses vertex-color multiplication for meshes without colors, or document and enforce a white vertex-color channel.
                // Related: #36.
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 cap : TEXCOORD0;
                float4 color : COLOR;
            };

            TEXTURE2D(_Matcap);
            SAMPLER(sampler_Matcap);
            // Potential Bug #25: This is a bug because a Float material property is bound to a bool uniform, relying on backend-specific constant-buffer representation for the toggle value.
            // Suggested Fix: Declare _PerspectiveCorrection as float and test _PerspectiveCorrection > 0.5.
            // Related: None.
            bool _PerspectiveCorrection;

            v2f vert(appdata v)
            {
                v2f o;
                o.color = v.color;
                o.pos = TransformObjectToHClip(v.vertex.xyz);

                float3 worldNorm = TransformObjectToWorldNormal(v.normal);
                float3 viewNorm = TransformWorldToViewDir(worldNorm);

                if (_PerspectiveCorrection)
                {
                    float3 viewPos = TransformWorldToView(TransformObjectToWorld(v.vertex.xyz));
                    float3 viewDir = normalize(viewPos);
                    float3 viewCross = cross(viewDir, viewNorm);
                    viewNorm = float3(-viewCross.y, viewCross.x, 0.0);
                }

                // Potential Bug #26: This is a bug because nonlinear matcap coordinates are calculated per vertex and linearly interpolated, causing faceted or snapping highlights on low-density meshes.
                // Suggested Fix: Interpolate view position and normal, normalize them, and calculate cap in the fragment shader.
                // Related: #29.
                o.cap = viewNorm.xy * 0.5 + 0.5;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_Matcap, sampler_Matcap, i.cap);
                return col * i.color;
            }
            ENDHLSL
        }
        // Potential Bug #27: This is a bug because the shader has no ShadowCaster or depth pass, so objects can fail to cast shadows or participate in renderer depth features.
        // Suggested Fix: Add URP ShadowCaster and DepthOnly passes that use the same vertex deformation and clipping behavior as the forward pass.
        // Related: #31.
    }
}
