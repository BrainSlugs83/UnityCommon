Shader "BrainSlugs83/Matcap3"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _NoiseTex("Noise", 2D) = "white" {}
        _Cutoff("Cut off", Range(0, 1)) = 0.0
        _CutoffMultiply("Cut off Multiply", Float) = 0.0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2
    }
    SubShader
    {
        Tags { "RenderType" = "Geometry" "Queue" = "Transparent" }
        LOD 200
        Cull[_Cull]

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard addshadow fullforwardshadows

        #ifndef SHADER_API_D3D11
            #pragma target 3.0
        #else
            #pragma target 4.0
        #endif

        sampler2D _MainTex;
        sampler2D _NoiseTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
            float4 vtxColor : COLOR;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)

            UNITY_DEFINE_INSTANCED_PROP(half, _Glossiness)
            UNITY_DEFINE_INSTANCED_PROP(half, _Metallic)
            UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
            UNITY_DEFINE_INSTANCED_PROP(half, _Cutoff)
            UNITY_DEFINE_INSTANCED_PROP(float, _CutoffMultiply)

        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input input, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, input.uv_MainTex) 
                * UNITY_ACCESS_INSTANCED_PROP(Props, _Color) * input.vtxColor;

            o.Albedo = c.rgb;

            fixed4 noise = tex2D(_NoiseTex, input.uv_NoiseTex);

            if (noise.r > UNITY_ACCESS_INSTANCED_PROP(Props, _Cutoff))
            {
                float cutOffMx = UNITY_ACCESS_INSTANCED_PROP(Props, _CutoffMultiply);
                o.Albedo *= (cutOffMx * noise.r);
                clip(cutOffMx <= 0 ? -1 : 1);
            }
            else
            {
                clip(1);
            }

            // Metallic and smoothness come from slider variables
            o.Metallic = UNITY_ACCESS_INSTANCED_PROP(Props, _Metallic);
            o.Smoothness = UNITY_ACCESS_INSTANCED_PROP(Props, _Glossiness);
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
