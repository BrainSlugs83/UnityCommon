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
        Tags { "RenderType" = "Opaque" }
        LOD 300

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "PerlinNoise.cginc"

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _AoTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_AoTex;
            float3 worldPos;
            float discoloration;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _CellSize;
        float _UVScale;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void vert(inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
           
            float4 wp = mul(unity_ObjectToWorld, v.vertex);
            o.worldPos = wp.xyz;

            //wp /= _CellSize;
            //wp = round(wp);
            //wp *= _CellSize;

            //v.vertex = mul(unity_WorldToObject, wp);

            //float3 value = o.worldPos / _CellSize;
            //float3 noise = ValueNoise3Dto3D(value);
            
            //v.vertex += float4(noise, 0) * _DistortionStrength;
            //o.discoloration = (ValueNoise3Dto1D(value) * _Discoloration) - (_Discoloration * .5);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            IN.uv_MainTex = float2(IN.worldPos.x, IN.worldPos.z) * _UVScale;
            IN.uv_BumpMap = float2(IN.worldPos.x, IN.worldPos.z) * _UVScale;
            IN.uv_AoTex = float2(IN.worldPos.x, IN.worldPos.z) * _UVScale;


            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            o.Albedo = c.rgb + float3(IN.discoloration, IN.discoloration, IN.discoloration);
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

            
            fixed4 ao = tex2D(_AoTex, IN.uv_AoTex);
            o.Alpha = ao.a;
            o.Occlusion = ao.r;

            //o.Albedo = ( * .5) + .5;
        }
        ENDCG
    }
    FallBack "Standard"
}
