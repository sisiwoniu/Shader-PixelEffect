Shader "CustomShader/PixelEffect"
{
    Properties
    {
		[HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
        
        [HDR]
		_Color("Color", Color) = (1, 1, 1, 1)
		
		_SphereSize("Sphere Size", Range(0, 1)) = 1
		
		_Scale("Scale", Range(1, 1000)) = 500

		_Threshold("Threshold", Range(-0.1, 1.2)) = 0

		_LineWidth("LineWidth", Range(0, 10)) = 2

		_MinAlpha("Min Alpha", Range(0, 0.5)) = 0.1

		_MaxAlpha("Max Alpha", Range(0.5, 1)) = 0.5

		_ChangeAlphaSpeed("Change Alpha Speed", Range(0, 10)) = 3

		//_AnimSpeed("Anim Speed", Range(0, 5)) = 1

		[KeywordEnum(Sphere, Arrow, Heart)]
		_Type("Type", float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }

        LOD 100

		Cull Back

		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

			#pragma multi_compile _TYPE_SPHERE _TYPE_ARROW _TYPE_HEART

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

			fixed4 _Color;

			fixed _SphereSize;

			fixed _Scale;

			fixed _Threshold;

			fixed _LineWidth;

			fixed _MinAlpha, _MaxAlpha, _ChangeAlphaSpeed;

			fixed _AnimSpeed;

			float noise(fixed2 uv) 
			{
				return frac(sin(dot(uv, fixed2(12.9898, 78.233))) * 43758.5453);
			}

			fixed SphereAlpha(fixed2 blockUV) 
			{
				fixed centerBlock = floor(_Scale * 0.5);

				fixed blockDist = distance(half2(centerBlock, centerBlock), blockUV);

				fixed scale = _Scale * (_Threshold + frac(_Time.y * _AnimSpeed));

				return step(blockDist, scale) * step(scale - _LineWidth, blockDist);
			}

			fixed ArrowAlpha(fixed2 blockUV) 
			{
				fixed centerBlock = floor(_Scale * 0.5);

				fixed a = abs(blockUV.x - centerBlock) + abs(blockUV.y - centerBlock);

				fixed scale = _Scale * (_Threshold + frac(_Time.y * _AnimSpeed));

				a = (1 - step(scale, a)) * step(scale - _LineWidth, a);
			
				return a;
			}

			fixed HeartAlpha(fixed2 blockUV) 
			{
				fixed centerBlock = floor(_Scale * 0.5);

				fixed blockDist = distance(fixed2(centerBlock, blockUV.y), blockUV);

				blockUV.y += blockDist;

				fixed scale = _Scale * _Threshold;//(_Threshold + frac(_Time.y * _AnimSpeed));

				blockDist = distance(fixed2(centerBlock, centerBlock), blockUV);
			
				return step(blockDist, scale) * step(scale - _LineWidth, blockDist);
			}

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = v.uv;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
				fixed2 uv = i.uv * _Scale;

				fixed2 blockUV = floor(uv);

				uv = frac(uv);

				//ランダムに点滅させる
				_Color.a = clamp(noise(clamp(blockUV, 1, _Scale)) * _Color.a + frac(_Time.y * _ChangeAlphaSpeed), _MinAlpha, _MaxAlpha);

                fixed4 col = tex2D(_MainTex, uv) * _Color;

				half dist = distance(half2(0.5, 0.5), uv);

				//丸の色
				col *= step(dist, _SphereSize);

				//該当のブロックだけ表示する
				#ifdef _TYPE_SPHERE 

				col.a *= SphereAlpha(blockUV);

				#elif _TYPE_ARROW

				col.a *= ArrowAlpha(blockUV);

				#elif _TYPE_HEART

				col.a *= HeartAlpha(blockUV);

				#endif

                return col;
            }

            ENDCG
        }
    }
}