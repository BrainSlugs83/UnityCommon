// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "BrainSlugs83/Matcap2"
{
    Properties
    {
        _Matcap("Matcap", 2D) = "white"
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
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                //float2 cap : TEXCOORD0;
                //float3 viewNorm : NORMAL;
                float3 viewDir : POSITIONT;
                //float3 worldPos : TEXCOORD0;

                half3 tspace0 : TEXCOORD1; // tangent.x, bitangent.x, normal.x
                half3 tspace1 : TEXCOORD2; // tangent.y, bitangent.y, normal.y
                half3 tspace2 : TEXCOORD3; // tangent.z, bitangent.z, normal.z
                float2 uv : TEXCOORD4;
                float4 color : COLOR;
            };

            sampler2D _Matcap;
            sampler2D _AddOverlay;
            sampler2D _MultOverlay;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            float _Exposure;
            float _Flicker;
            float _FlickerSpeed;
            float _RollSpeedX;
            float _RollSpeedY;

            half shade(half input)
            {
                //return smoothstep(.9f, .1f, 1-input);
                /*if (input < .33f) { return (1.0f / 3.0f); }
                if (input < .67f) { return (2.0f / 3.0f); }
                return 1.0f;*/

                if (input < 0.25f) { return 0.33333333f; }
                if (input < 0.50f) { return 0.55555556f; }
                if (input < 0.75f) { return 0.86274509f; }
                return 1.0f;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //o.viewNorm = COMPUTE_VIEW_NORMAL;

                // get view space position of vertex
                o.viewDir = normalize(UnityObjectToViewPos(v.vertex));

                //o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                half3 wNormal = UnityObjectToWorldNormal(v.normal);
                half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);


                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;

                o.uv = TRANSFORM_TEX(v.uv, _NormalMap) + float2(_Time.y * _RollSpeedX, _Time.y * _RollSpeedY);
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
                o.color = v.color;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the normal map, and decode from the Unity encoding
                half3 tnormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                // transform normal from tangent to world space
                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);

                half3 viewNorm = mul((float3x3)UNITY_MATRIX_V, worldNormal);
                //float3 viewDir = normalize(i.viewPos);

                // get vector perpendicular to both view direction and view normal
                float3 viewCross = cross(i.viewDir, viewNorm);

                // swizzle perpendicular vector components to create a new perspective corrected view normal
                float2 cap = float2(-viewCross.y, viewCross.x) * 0.5 + 0.5;

                fixed4 col = tex2D(_Matcap, cap);
                fixed4 add = tex2D(_AddOverlay, cap);
                fixed4 mult = tex2D(_MultOverlay, cap);

                col = (col + add) * mult;
                float e = _Exposure + (cos(_Time.x * _FlickerSpeed) * _Flicker);

                col *= e;
                col.a = 1.0;

                /*
                col.r = shade(col.r);
                col.g = shade(col.g);
                col.b = shade(col.b);
                */

                return col * i.color;
            }
            ENDCG
        }
    }
}