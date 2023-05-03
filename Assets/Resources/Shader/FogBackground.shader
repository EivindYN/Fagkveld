Shader "Unlit/FogBackground" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1 ("Color1", Color) = (0, 0, 1, 1) //Must have different alpha values
        _Color2 ("Color2", Color) = (0, 0, 0, 0)
    }
    SubShader {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Pass {
            CULL Off
            ZWRITE Off
            BLEND One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color1 : TEXCOORD1; // uv0 diffuse/normal map textures
                float4 color2 : TEXCOORD2; // uv0 diffuse/normal map textures
                float4 color3 : TEXCOORD3; // uv0 diffuse/normal map textures
                float4 c1 : TEXCOORD4;
                float4 c2 : TEXCOORD5;
                float4 c3 : TEXCOORD6;
                float3 worldPos : TEXCOORD7;
            };
            float4 _Color1;
            float4 _Color2;

            //  1 out, 3 in...
            float hash13(float3 p3)
            {
                p3  = (p3 * .1031) % 1;
                p3 += dot(p3, p3.zyx + 31.32);
                return ((p3.x + p3.y) * p3.z) % 1;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float Lerp2D(float c00, float c01, float c11, float c10, float2 pos){
                float c0010 = ((c10-c00) * pos.x + c00) * (1-pos.y);
                float c0001 = ((c01-c00) * pos.y + c00) * (1-pos.x);
                float c0111 = ((c11-c01) * pos.x + c01) * pos.y;
                float c1011 = ((c11-c10) * pos.y + c10) * pos.x;
                c00 *= (1 - pos.x) * (1 - pos.y);
                c01 *= (1 - pos.x) * pos.y;
                c10 *= pos.x * (1-pos.y);
                c11 *= pos.x * pos.y;
                return c00 + c01 + c10 + c11;
                return (c0010 + c0001 + c0111 + c1011) / 2; //
            }

            float4 frag (v2f i) : SV_Target {
                i.uv += i.worldPos.xy + float2(50, 50); //NB cheap/janky solution to make it positive
                // sample the texture
                //return float4(0,0,1,1) * step(0.5,i.color1.z);
                float2 cuv = i.uv * 2 - 1;
                //clip(1-length(cuv) + (1 - max(abs(cuv.x), abs(cuv.y))));
                float4 color = float4(0,0,0,1);
                float time = _Time.y * 2.0;
                for (int n = 0; n < 3; n += 1){
                    float unit = 2;
                    //i.uv.x = max(1- i.uv.x, i.uv.x);
                    //i.uv.y = max(1- i.uv.y, i.uv.y);
                    float c00 = hash13(float3(round(i.uv.x * unit - 0.5), round(i.uv.y * unit - 0.5), round(time - 0.5 + n * 10)));
                    float c01 = hash13(float3(round(i.uv.x * unit - 0.5), round(i.uv.y * unit + 0.5), round(time - 0.5 + n * 10)));
                    float c10 = hash13(float3(round(i.uv.x * unit + 0.5), round(i.uv.y * unit - 0.5), round(time - 0.5 + n * 10)));
                    float c11 = hash13(float3(round(i.uv.x * unit + 0.5), round(i.uv.y * unit + 0.5), round(time - 0.5 + n * 10)));
                    float c00n = hash13(float3(round(i.uv.x * unit - 0.5), round(i.uv.y * unit - 0.5), round(time + 0.5 + n * 10)));
                    float c01n = hash13(float3(round(i.uv.x * unit - 0.5), round(i.uv.y * unit + 0.5), round(time + 0.5 + n * 10)));
                    float c10n = hash13(float3(round(i.uv.x * unit + 0.5), round(i.uv.y * unit - 0.5), round(time + 0.5 + n * 10)));
                    float c11n = hash13(float3(round(i.uv.x * unit + 0.5), round(i.uv.y * unit + 0.5), round(time + 0.5 + n * 10)));
                    float2 pos = float2((i.uv.x * unit) % 1, (i.uv.y * unit) % 1);
                    float lerped = Lerp2D(c00,c01,c11,c10, pos);
                    float lerped2 = Lerp2D(c00n,c01n,c11n,c10n, pos);
                    float lerpedDiff = lerped2 - lerped;
                    float4 _ColorDiff = _Color1 - _Color2;
                    float4 blend = time % 1;
                    float4 hardc = (_ColorDiff * step(0.5, lerp(lerped, lerped2, blend)) + _Color2);
                    float4 softc = (_ColorDiff * lerp(step(0.5, lerped),step(0.5, lerped2), blend) + _Color2);
                    float c = (hardc + softc) * 0.5;
                    //c = lerped;
                    if (n == 0){
                        //color.x = hardc;
                        color.x = c;
                        //color.y = hardc;
                    }
                    if (n == 1){
                        //color.y = hardc;
                        color.y = c;
                        //color.z = hardc;
                    }
                    if (n == 2){
                        //color.x = hardc;
                        //color.z = hardc;
                        color.z = c;
                    }
                }
                
                return color;
            }
            ENDCG
        }
    }
}