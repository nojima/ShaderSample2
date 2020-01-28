Shader "Unlit/TextureMapping" {
    Properties {
        _Texture("Texture", 2D) = "white" {}
        _AmbientReflectance("Ambient Reflection Constant", Range(0, 1)) = 0.1
        _DiffuseReflectance("Diffuse Reflection Constant", Range(0, 1)) = 0.7
        _SpecularReflectance("Specular Reflection Constant", Range(0, 1)) = 0.2
        _Shininess("Shininess", Float) = 20.0
    }
    SubShader {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc" // _LightColor0 のため

			sampler2D _Texture;
			float4 _Texture_ST;

			float _AmbientReflectance;
			float _DiffuseReflectance;
			float _SpecularReflectance;
			float _Shininess;

			struct VertexInput {
				float4 objectPos : POSITION;
				float3 objectNormal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput {
				float4 clipPos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			VertexOutput vert(VertexInput v) {
				VertexOutput o;
				o.clipPos = UnityObjectToClipPos(v.objectPos);
				o.worldPos = mul(unity_ObjectToWorld, v.objectPos);
				o.worldNormal = UnityObjectToWorldNormal(v.objectNormal);
				o.uv = TRANSFORM_TEX(v.uv, _Texture);
				return o;
			}

            float3 Phong(VertexOutput i, float3 baseColor) {
                float3 lightIntensity = _LightColor0;
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 ambientLightIntensity = UNITY_LIGHTMODEL_AMBIENT;
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldNormal = normalize(i.worldNormal);
                
                // 環境光
                float3 ambient = _AmbientReflectance * ambientLightIntensity;

                // 拡散光
                float LN = dot(lightDir, worldNormal);
                float3 diffuse = _DiffuseReflectance * max(LN, 0.0) * baseColor * lightIntensity;

                // 反射光
                float3 reflectionDir = -reflect(lightDir, worldNormal);
                float RV = dot(reflectionDir, viewDir);
                float3 specular = _SpecularReflectance * pow(max(RV, 0.0), _Shininess) * lightIntensity;

                return ambient + diffuse + specular;
            }

            float4 frag(VertexOutput i) : SV_TARGET {
                float3 baseColor = tex2D(_Texture, i.uv).rgb;
                float3 color = Phong(i, baseColor);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
