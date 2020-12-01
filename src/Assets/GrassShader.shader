Shader "Unlit/GrassShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue" = "Geometry" "RenderType" = "Opaque" "LightMode" = "ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            uniform StructuredBuffer<float4>    points;

            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct v2f
            {
                fixed4 color : COLOR0;
                float4 pos : SV_POSITION;
                float2 force : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (uint id : SV_VertexID)
            {
                float4 p = points[id];

                v2f o;
                o.pos = float4(p.xyz, 1.0);// ワールド座標を直接渡す
                if(p.w < 1.0){
                    o.color = float4(0, p.w, 0, 1);// 黒から緑
                }else{
                    o.color = float4(p.w - 1.0, 1, p.w - 1.0, 1);// 緑から白
                }

                float2 uv = p.xz / 10.0 + 0.5;// [0,1]に正規化
                o.force = tex2Dlod(_MainTex, float4(uv,0,1));

                return o;
            }

            // ジオメトリシェーダ
            [maxvertexcount(6)]// 最大頂点数の指定
            void geom(point v2f input[1], inout TriangleStream<v2f> outStream)
            {
                v2f output = (v2f)0;
                float3 pos = float3(input[0].pos.x, 0, input[0].pos.z);
                float height = input[0].pos.y;
                fixed4 color = input[0].color;

                float width = 0.05;// 草の太さ
                float4 p0 = mul(UNITY_MATRIX_VP, float4(pos + float3(+width, 0, 0), 1));
                float4 p1 = mul(UNITY_MATRIX_VP, float4(pos + float3(-width, 0, 0), 1));
                float4 p2 = mul(UNITY_MATRIX_VP, float4(pos + float3(input[0].force.x, height, input[0].force.y), 1));

                // 表
                output.pos = p0;
                output.color = color;
                outStream.Append(output);
                output.pos = p1;
                output.color = color;
                outStream.Append(output);
                output.pos = p2;
                output.color = color;
                outStream.Append(output);
                outStream.RestartStrip();

                // 裏
                output.pos = p0;
                output.color = color;
                outStream.Append(output);
                output.pos = p2;
                output.color = color;
                outStream.Append(output);
                output.pos = p1;
                output.color = color;
                outStream.Append(output);
                outStream.RestartStrip();
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
