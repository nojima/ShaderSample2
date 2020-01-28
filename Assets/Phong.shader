Shader "Unlit/Phong" {
    Properties {
        _BaseColor("Base Color", Color) = (0.8, 0.0, 0.0, 1.0)
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

            float4 _BaseColor;
            float _AmbientReflectance;
            float _DiffuseReflectance;
            float _SpecularReflectance;
            float _Shininess;

            struct VertexInput {
                float4 objectPos : POSITION;
                float3 objectNormal : NORMAL;
            };

            struct VertexOutput {
                float4 clipPos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o;
                o.clipPos = UnityObjectToClipPos(v.objectPos);
                o.worldPos = mul(unity_ObjectToWorld, v.objectPos);
                o.worldNormal = UnityObjectToWorldNormal(v.objectNormal);
                return o;
            }

            float4 frag(VertexOutput i) : SV_TARGET {
                float3 lightIntensity = _LightColor0;
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 ambientLightIntensity = UNITY_LIGHTMODEL_AMBIENT;
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldNormal = normalize(i.worldNormal);
                
                // 環境光
                float3 ambient = _AmbientReflectance * ambientLightIntensity;

                // 拡散光
                float LN = dot(lightDir, worldNormal);
                float3 diffuse = _DiffuseReflectance * max(LN, 0.0) * _BaseColor * lightIntensity;

                // 反射光
                float3 reflectionDir = -reflect(lightDir, worldNormal);
                float RV = dot(reflectionDir, viewDir);
                float3 specular = _SpecularReflectance * pow(max(RV, 0.0), _Shininess) * lightIntensity;

                float3 color = ambient + diffuse + specular;
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
