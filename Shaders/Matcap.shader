Shader "BrainSlugs83/Matcap"
{
    Properties
    {
        _Matcap("Matcap", 2D) = "white"
        [Toggle] _PerspectiveCorrection("Use Perspective Correction", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
            };


            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 cap : TEXCOORD0;
                float4 color : COLOR;
                //float3 worldNorm: NORMAL;
                //float3 viewNorm: NORMAL;
            };

            sampler2D _Matcap;
            bool _PerspectiveCorrection;

            v2f vert (appdata v)
            {
                v2f o;
                o.color = v.color;
                o.pos = UnityObjectToClipPos(v.vertex);

                float3 worldNorm = UnityObjectToWorldNormal(v.normal);
                float3 viewNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
                
                if (_PerspectiveCorrection)
                {
                    // get view space position of vertex
                    float3 viewPos = UnityObjectToViewPos(v.vertex);
                    float3 viewDir = normalize(viewPos);

                    // get vector perpendicular to both view direction and view normal
                    float3 viewCross = cross(viewDir, viewNorm);

                    // swizzle perpendicular vector components to create a new perspective corrected view normal
                    viewNorm = float3(-viewCross.y, viewCross.x, 0.0);
                }
                
                o.cap = viewNorm.xy * 0.5 + 0.5;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //float2 uv = mul((float3x3)UNITY_MATRIX_V, i.normal).xy * 0.5 + 0.5;

                fixed4 col = tex2D(_Matcap, i.cap);
                return col * i.color;
            }
            ENDCG
        }
    }
}
