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
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            // Physically based Standard lighting model, and enable shadows on all light types
            //#pragma surface surf Standard fullforwardshadows vertex:vert finalcolor:clrmap
            #pragma surface surf Standard fullforwardshadows vertex:vert

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 3.0

            #include "PerlinNoise.cginc"
            
            struct Input
            {
                float2 uv_MainTex;
                float2 uv_BumpMap;
                float2 uv_HeightMap;
                fixed4 color : COLOR;
                float3 viewDir;
                //float4 screenPos;
                float3 worldPos;
            };

            CBUFFER_START(BumpedWithVertexColorParams)

            sampler2D _MainTex;
            sampler2D _BumpMap;
            sampler2D _HeightMap;

            half _Smoothness;
            half _Metallic;
            fixed4 _Color;

            float4 _RimColor;
            float _RimPower;
            float _NormalExtrusion;
            float _HeightPower;

            int _AtlasWidth;
            int _AtlasHeight;
            int _AtlasOffsetX;
            int _AtlasOffsetY;
            float _AtlasBorder;

            CBUFFER_END

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)
            
            void vert(inout appdata_full i, out Input o)
            {
                UNITY_INITIALIZE_OUTPUT(Input, o);
                i.vertex.xyz += i.normal * _NormalExtrusion;
            }

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

            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                int ox = _AtlasOffsetX;
                int oy = _AtlasOffsetY;

                float2 rnd = Rand3Dto2D(trunc(IN.worldPos + float3(8000,8000, 8000)) / 100000);
                if (ox < 0 && _AtlasWidth > 1) { ox = floor(rnd.x * _AtlasWidth); }
                if (oy < 0 && _AtlasHeight > 1) { oy = floor(rnd.y * _AtlasHeight); }

                float2 texOffset = ParallaxOffset(tex2D(_HeightMap, FixUVs(IN.uv_HeightMap, ox, oy)).r, _HeightPower, IN.viewDir);

                // Albedo comes from a texture tinted by color and Vertex Color
                fixed4 c = tex2D(_MainTex, FixUVs(IN.uv_MainTex + texOffset, ox, oy)) * _Color * IN.color;
                if (c.a <= 0) { clip(-1); return; }

                o.Albedo = c.rgb;
                // Metallic and smoothness come from slider variables
                o.Metallic = _Metallic;
                o.Smoothness = _Smoothness;
                o.Alpha = c.a;
                o.Normal = UnpackNormal(tex2D(_BumpMap, FixUVs(IN.uv_BumpMap + texOffset, ox, oy)));
                
                if (_RimColor.a > 0.0)
                {
                    half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
                    o.Emission = (_RimColor.rgb * pow(rim, _RimPower)) * _RimColor.a;
                }

                //o.Albedo = IN.screenPos.xyz / IN.screenPos.w;
            }

            /*float Ramp(float input)
            {
                float4 value = tex2D(_ToonMap, float2(input, 0.5));
                if (value.a <= 0) { return input; }
                return (value.r + value.g + value.b) / 3.0;
            }

            void clrmap(Input IN, SurfaceOutputStandard o, inout fixed4 color)
            {
                color.r = Ramp(color.r);
                color.g = Ramp(color.g);
                color.b = Ramp(color.b);
            }*/

            ENDCG
        }
        FallBack "Diffuse"
}