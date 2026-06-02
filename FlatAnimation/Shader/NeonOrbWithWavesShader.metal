//
//  NeonOrbWithWavesShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 01.06.2026.
//

#include <metal_stdlib>
using namespace metal;

float neon_wave_hash(float3 p) {
    p = fract(p * float3(127.1, 311.7, 74.7));
    return fract(sin(dot(p, float3(269.5, 183.3, 246.1))) * 43758.5453);
}

float neon_wave_noise(float3 p) {
    float3 i = floor(p);
    float3 f = fract(p);
    float3 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(mix(neon_wave_hash(i + float3(0,0,0)), neon_wave_hash(i + float3(1,0,0)), u.x),
                   mix(neon_wave_hash(i + float3(0,1,0)), neon_wave_hash(i + float3(1,1,0)), u.x), u.y),
               mix(mix(neon_wave_hash(i + float3(0,0,1)), neon_wave_hash(i + float3(1,0,1)), u.x),
                   mix(neon_wave_hash(i + float3(0,1,1)), neon_wave_hash(i + float3(1,1,1)), u.x), u.y), u.z);
}

[[ stitchable ]] half4 neonOrbWithWavesShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float r = length(uv);
    float maxRadius = 0.75;
    
    half3 backgroundColor = half3(0.96, 0.96, 0.98);
    
    if (r > maxRadius + 0.1) {
        return half4(backgroundColor, 1.0);
    }
    
    float z = sqrt(max(0.0, maxRadius * maxRadius - r * r));
    float3 normal = normalize(float3(uv, z));
    float3 viewDir = float3(0.0, 0.0, 1.0);
    
    float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), 2.0);
    
    float3 noisePos = float3(uv * 1.5, time * 0.4);
    float n1 = neon_wave_noise(noisePos);
    float n2 = neon_wave_noise(noisePos * 2.0 - float3(time * 0.2));
    float combinedNoise = mix(n1, n2, 0.4);
    
    half3 magentaColor = half3(0.92, 0.12, 0.70);
    half3 purpleColor  = half3(0.53, 0.05, 0.95);
    half3 neonPink     = half3(1.00, 0.40, 0.85);
    
    half3 internalGlow = mix(purpleColor, magentaColor, combinedNoise);
    internalGlow = mix(internalGlow, neonPink, fresnel * 0.3);
    
    float centerGlow = pow(max(0.0, 1.0 - r / maxRadius), 1.5);
    internalGlow += half3(0.9, 0.5, 0.9) * centerGlow * 0.35;
    
    half3 wavesColor = half3(0.0);
    
    float wave1 = sin(normal.x * 3.5 + time * 2.5) * 0.22 + cos(normal.x * 2.0 - time * 1.2) * 0.08;
    float dist1 = abs(normal.y - wave1);
    float glow1 = 0.008 / max(dist1, 0.001);
    wavesColor += half3(0.0, 0.9, 1.0) * glow1;
    
    float wave2 = sin(normal.x * 2.2 - time * 1.8) * 0.3 + sin(normal.x * 4.0 + time * 1.5) * 0.05;
    float dist2 = abs(normal.y - wave2);
    float glow2 = 0.009 / max(dist2, 0.001);
    wavesColor += half3(1.0, 0.0, 0.6) * glow2;
    
    float wave3 = cos(normal.x * 1.8 + time * 1.1) * 0.35;
    float dist3 = abs(normal.y - wave3);
    float glow3 = 0.012 / max(dist3, 0.001);
    wavesColor += half3(0.0, 1.0, 0.3) * glow3 * 0.6;
    
    wavesColor *= smoothstep(0.0, 0.3, normal.z);
    
    half3 orbColor = internalGlow + wavesColor;
    
    float3 lightDir1 = normalize(float3(sin(time * 0.4), 1.0, 0.8));
    float3 lightDir2 = normalize(float3(-1.0, cos(time * 0.25), 0.5));
    
    float spec1 = pow(max(dot(normal, normalize(lightDir1 + viewDir)), 0.0), 64.0);
    float spec2 = pow(max(dot(normal, normalize(lightDir2 + viewDir)), 0.0), 32.0);
    float rimLight = pow(fresnel, 4.0) * 0.5;
    
    orbColor += half3(spec1 * 0.55 + spec2 * 0.25);
    orbColor += half3(1.0, 0.8, 1.0) * rimLight;
    
    float edgeAlpha = smoothstep(maxRadius, maxRadius - 0.004, r);
    half3 finalColor = mix(backgroundColor, orbColor, edgeAlpha);
    
    return half4(finalColor, 1.0);
}

