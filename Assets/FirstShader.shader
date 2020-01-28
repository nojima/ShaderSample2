Shader "Unlit/FirstShader" {
	Properties {
		_Color("Color of the surface", Color) = (0.22, 0.71, 0.55, 1.0)
	}
    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			float4 _Color;

            float4 vert(float4 pos : POSITION) : SV_POSITION {
				pos = mul(UNITY_MATRIX_M, pos); // ワールド変換
				pos = mul(UNITY_MATRIX_V, pos); // ビュー変換
				pos = mul(UNITY_MATRIX_P, pos); // パースペクティブ変換
				return pos;
            }

            float4 frag() : SV_TARGET {
                return _Color;
            }
            ENDCG
        }
    }
}