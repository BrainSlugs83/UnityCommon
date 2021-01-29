Shader "BrainSlugs83/MatCappy2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Matcap ("Matcap ", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NormalMap("Normal Map", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _Matcap;
        sampler2D _NormalMap;

        struct Input
        {
            float2 uv_Matcap;
            float2 uv_NormalMap;

            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float4 color : COLOR;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input v, inout SurfaceOutputStandard o)
        {
            //float3 viewDir = v.vertex; // normalize(UnityObjectToViewPos(v.vertex));
            float3 viewDir = normalize(UnityWorldToViewPos(v.vertex));

            half3 wNormal = v.normal; // UnityObjectToWorldNormal(v.normal);
            half3 wTangent = v.tangent.xyz; // UnityObjectToWorldDir(v.tangent.xyz);
            half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
            half3 wBitangent = cross(wNormal, wTangent) * tangentSign;

            half3 tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
            half3 tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
            half3 tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);

            // sample the normal map, and decode from the Unity encoding
            half3 tnormal = UnpackNormal(tex2D(_NormalMap, v.uv_NormalMap));

            // transform normal from tangent to world space
            half3 worldNormal;
            worldNormal.x = dot(tspace0, tnormal);
            worldNormal.y = dot(tspace1, tnormal);
            worldNormal.z = dot(tspace2, tnormal);

            half3 viewNorm = mul((float3x3)UNITY_MATRIX_V, worldNormal);

            // get vector perpendicular to both view direction and view normal
            float3 viewCross = cross(viewDir, viewNorm);

            // swizzle perpendicular vector components to create a new perspective corrected view normal
            float2 cap = float2(-viewCross.y, viewCross.x) * 0.5 + 0.5;
            cap = normalize(cap) * 0.9;

            fixed4 col = tex2D(_Matcap, cap);

            // Albedo comes from a texture tinted by color
            fixed4 c = _Color * v.color * col;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
            o.Alpha = 1; // c.a;
        }
        ENDCG
    }
    //FallBack "Diffuse"
}
