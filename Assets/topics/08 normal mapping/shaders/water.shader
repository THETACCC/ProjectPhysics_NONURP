Shader "examples/week 8/water"
{
    Properties 
    {
        _albedo ("albedo", 2D) = "white" {}
        _albedo2 ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _normalMap2 ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _normalMap3 ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _normalMap4 ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _normalMap5 ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _displacementMap ("displacement map", 2D) = "white" {}
        [NoScaleOffset] _displacementMap2 ("displacement map", 2D) = "white" {}
        [NoScaleOffset] _displacementMap3 ("displacement map", 2D) = "white" {}
        [NoScaleOffset] _displacementMap4 ("displacement map", 2D) = "white" {}
        _gloss ("gloss", Range(0,1)) = 1
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0,1)) = 0.5
        _refractionIntensity ("refraction intensity", Range(0, 0.5)) = 0.1
        _refractionIntensity_distort ("refraction intensity Distorted", Range(0, 0.5)) = 0.1
        _opacity ("opacity", Range(0,1)) = 0.9


        _scale ("noise scale", Range(2, 100)) = 15.5
        _displacement ("displacement", Range(0, 0.1)) = 0.05



        _diffuseLightSteps ("diffuse light steps", Int) = 4
        _specularLightSteps ("specular light steps", Int) = 2

        _surfaceIntersectionSize ("surface intersection size", Range(0, 20)) = 0.1
        _depthFog ("depth fog", Range(0, 50)) = 0.1
        _opacity_depth ("opacity_dpeth", Range(0,1)) = 0.8

    }
    SubShader
    {
        // this tag is required to use _LightColor0
        // this shader won't actually use transparency, but we want it to render with the transparent objects
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "LightMode"="ForwardBase" }

        GrabPass {
            "_BackgroundTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc" // might be UnityLightingCommon.cginc for later versions of unity

            #define MAX_SPECULAR_POWER 256

            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _albedo2;
            sampler2D _normalMap;
            sampler2D _normalMap2;
            sampler2D _normalMap3;
            sampler2D _normalMap4;
            sampler2D _normalMap5;
            sampler2D _displacementMap;
            sampler2D _displacementMap2;
            sampler2D _displacementMap3;
            sampler2D _displacementMap4;
            //This is used to make depth effects
            sampler2D _BackgroundTex;
            sampler2D _CameraDepthTexture;
            float _surfaceIntersectionSize;
            float _depthFog;
            float _opacity_depth;
            float _gloss;
            float _normalIntensity;
            float _displacementIntensity;
            float _refractionIntensity;
            float _refractionIntensity_distort;
            float _opacity;


            float _scale;
            float _displacement;

            int _diffuseLightSteps;
            int _specularLightSteps;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
                float surfZ : TEXCOORD1;
            };

            float wave (float2 uv) {
                float wave1 = sin(((uv.x + uv.y) * _scale) + _Time.z) * 0.5 + 0.5;
                float wave2 = (cos(((uv.x - uv.y) * _scale/2.568) + _Time.z) + 1) * sin(_Time.x * 5.2321 + (uv.x * uv.y)) * 0.5 + 0.5;
                return (wave1 + wave2) / 3;
            }

            //noises

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }



            float noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            float fractal_noise (float2 uv) {
                float n = 0;
                // fractal noise is created by adding together "octaves" of a noise
                // an octave is another noise value that is half the amplitude and double the frequency of the previously added noise
                // below the uv is multiplied by a value double the previous. multiplying the uv changes the "frequency" or scale of the noise becuase it scales the underlying grid that is used to create the value noise
                // the noise result from each line is multiplied by a value half of the previous value to change the "amplitude" or intensity or just how much that noise contributes to the overall resulting fractal noise.

                n  = (1 / 2.0)  * noise( uv * 1);
                n += (1 / 4.0)  * noise( uv * 2); 
                n += (1 / 8.0)  * noise( uv * 4); 
                n += (1 / 16.0) * noise( uv * 8);
                
                return n;
            }

            float TriangleWave(float t, float amplitude, float period, float phase)
            {
                // Adjust time for phase shift
                float tAdjusted = t + phase;

                // Compute the triangle wave
                float fracC = frac(tAdjusted / period);
                float wave = 2.0 * amplitude * abs(fracC * period - period / 2.0) / period - amplitude;
                return wave;
            }

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 posWorld : TEXCOORD4;
                
                // create a variable to hold two float2 direction vectors that we'll use to pan our textures
                float4 uvPan : TEXCOORD5;
                float4 uvPan2 : TEXCOORD9;
                float4 uvPan3 : TEXCOORD10;
                float4 uvPan4 : TEXCOORD11;
                float4 uvPan5 : TEXCOORD14;
                float4 screenUV : TEXCOORD6;

                
                // screenPos and surfZ
                float4 screenPos : TEXCOORD13;
                float2 worldUV : TEXCOORD12;
                float disp : TEXCOORD7;
                float surfZ : TEXCOORD8;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                //o.disp = sin(((v.uv.x - v.uv.y) * _scale) + _Time.z) * 0.5 + 0.5;
                //o.disp = sin((smoothstep(sin(v.uv.x - v.uv.y),0,1) * _scale) + _Time.z) * 0.5 + 0.5;
                o.disp = TriangleWave(((v.uv.x - v.uv.y) * _scale) + _Time.z, 1 , 4, 1) * 0.5 + 0.5;              
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
           
                // panning  * frac(sin(_Time.x) * 90321) * 0.00001
                o.uvPan = float4(float2(0.9, 3) * _Time.x * 0.5, float2(0.5, -15) * _Time.z);
                o.uvPan2 = float4(float2(10,1 ) * _Time.x * 0.5, float2(1, 10) * _Time.z);
                o.uvPan3 = float4(float2(4, 4) * _Time.x, float2(4, 4) * _Time.z);
                o.uvPan4 = float4(float2(0.2, -3) * _Time.x * 1, float2(0.1, -0.2) * _Time.z);
                //InvertedPan
                o.uvPan5 = float4(float2(4, 0.2) * _Time.x * 1, float2(-0.2, 0.1) * _Time.z);
                // add our panning to our displacement texture sample
                //_displacementMap = fractal_noise(_displacementMap);
                float height1 = tex2Dlod(_displacementMap, float4(o.uv + o.uvPan.xy, 0, 0)).r;
                //height1 =  frac(sin(height1) * 90321) * sin(_Time.z);
                float height2 = tex2Dlod(_displacementMap2, float4(o.uv + o.uvPan2.xy, 0, 0)).r;
                float height3 = tex2Dlod(_displacementMap3, float4(o.uv + o.uvPan3.xy, 0, 0)).r;
                float height4 = tex2Dlod(_displacementMap4, float4(o.uv + o.uvPan4.xy, 0, 0)).r;
                float height = height1 * height2 * height3 * height4;
                v.vertex.xyz += v.normal * height * _displacementIntensity * o.disp;
                v.vertex.xyz += v.normal * o.disp * _displacement;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                

                // screenPos and surfZ
                o.screenPos = ComputeGrabScreenPos(o.vertex);
                o.surfZ = -UnityObjectToViewPos(v.vertex).z;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float2 screenUV = i.screenUV.xy / i.screenUV.w;
                float rand = 0;
                /*
                    float3 colorEdge = (0,0,0);
                float depth = Linear01Depth(tex2D(_CameraDepthTexture,screenUV));
                float difference = abs((depth / _ProjectionParams.w) - i.surfZ);

                if (difference >= 1)
                {
                    colorEdge = (1,1,1);
                }
                */

                float3 tangentSpaceNormal1 = UnpackNormal(tex2D(_normalMap, uv + i.uvPan.xy));
                tangentSpaceNormal1 += float3 (0.5 , 0,0);
                float3 tangentSpaceNormal2 = UnpackNormal(tex2D(_normalMap2, uv + i.uvPan2.xy));
                tangentSpaceNormal2 += float3 (0.5 , 0,0);
                tangentSpaceNormal2 *= fractal_noise(tangentSpaceNormal2 * _Time.z);
                float3 tangentSpaceNormal3 = UnpackNormal(tex2D(_normalMap3, uv + i.uvPan3.xy));
                tangentSpaceNormal3 += float3 (0.5 , 0,0);
                float3 tangentSpaceNormal4 = UnpackNormal(tex2D(_normalMap4, uv + i.uvPan4.xy));
                tangentSpaceNormal4 += float3 (0.5 , 0,0);
                float3 tangentSpaceNormal5 = UnpackNormal(tex2D(_normalMap5, uv + i.uvPan5.xy));
                tangentSpaceNormal5 += float3 (0.5 , 0,0);
                //float3 tangentSpaceNormal = tangentSpaceNormal1 * tangentSpaceNormal2 * tangentSpaceNormal3 * tangentSpaceNormal4 * tangentSpaceNormal5;
                float3 tangentSpaceNormal = tangentSpaceNormal1 * tangentSpaceNormal2 * tangentSpaceNormal3 * tangentSpaceNormal4 * tangentSpaceNormal5;
                //float3 tangentSpaceNormal = tangentSpaceNormal1 * (tangentSpaceNormal2 * 0.25);
                //rand = frac(sin( tangentSpaceNormal) * 90321 * (sin(_Time.z) * 2 + 1));
                //tangentSpaceNormal = rand * tangentSpaceNormal;
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));
                //tangentSpaceNormal = ceil(tangentSpaceNormal * 12) / 12;          



                float2 refractionUV = screenUV.xy + (tangentSpaceNormal.xy * _refractionIntensity);
                float3 background = tex2D(_BackgroundTex, refractionUV);

                float3x3 tangentToWorld = float3x3 
                (
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                );

                float3 normal = mul(tangentToWorld, tangentSpaceNormal);


                // blinn phong
                //+ i.uvPan3.xy To add pan to second albedo
                float3 surfaceColor = tex2D(_albedo, uv + i.uvPan.xy).rgb * tex2D(_albedo2, uv ).rgb * 1;

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 halfDirection = normalize(viewDirection + lightDirection);

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                float specularFalloff = max(0, dot(normal, halfDirection));


                float3 specular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss * lightColor;
                specular += float3(0,0,0);
                float3 diffuse = diffuseFalloff * surfaceColor * lightColor;


                diffuse = ceil(diffuse * _diffuseLightSteps) / _diffuseLightSteps;
                specular = floor(specular * _specularLightSteps) / _specularLightSteps ;
    
                //Depth  Stuff
                //float w = wave(i.worldUV);
                // calculate screenUV coordinates


                // depth intersection
                float depth = Linear01Depth(tex2D(_CameraDepthTexture, screenUV)).r;
                float depthDifference = abs((depth / _ProjectionParams.w) - i.surfZ);

                float intersection = 1 - smoothstep(0,  _surfaceIntersectionSize + noise(depthDifference * _Time.z * .001),depthDifference);
                //intersection = frac(sin(intersection) * 90321);
                //intersection *= saturate(saturate(sin(2 * _Time.z + 2 * (1-intersection)))  + smoothstep(0.9, 1, intersection));
                intersection *= saturate(sin(2 * _Time.z + 12 * (intersection * 0.5)))  + smoothstep(0.9, 1, intersection);
                specular +=  TriangleWave(((i.uv.x - i.uv.y) * _scale) + _Time.y*5, 0.5 , 48, 2)* 0.5  + 0.4;     
                //diffuse +=  TriangleWave(((i.uv.x - i.uv.y) * _scale) + _Time.z, 0.5 , 48, 2)* 0.5  + 0.2;     
                // refraction effect
                float2 distortedScreenUV = screenUV + (float2(0.1, 0.4) * (saturate(i.normal.y) * _refractionIntensity_distort));

                background *= tex2D(_BackgroundTex, distortedScreenUV);

                float distortedDepth = Linear01Depth(tex2D(_CameraDepthTexture, distortedScreenUV)).r;
                float distortedDepthDifference = abs((distortedDepth / _ProjectionParams.w) - i.surfZ);
                float underwaterDepth = 1 - smoothstep(0, _depthFog, distortedDepthDifference);
                //This is stylized color for the water depth under the water shader
                float3 underwaterDepthColor = float3 (underwaterDepth,0.89,0.95);
                background *= underwaterDepthColor;


                float3 color = (diffuse * _opacity ) + (background * (1 - _opacity)) + specular;
                color = saturate(color + background * 0.5 * (1 - _opacity_depth));

                color += smoothstep(0.1, 0.2, intersection) * 0.5;
                return float4(color, 1);
            }
            ENDCG
        }
    }
}
