//
//  Fire.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

#include <metal_stdlib>
using namespace metal;

float circle_fire_noise(float2 uv) {
    float2 i = floor(uv);
    float2 f = fract(uv);
    float2 u = f * f * (3.0 - 2.0 * f);
    
    float a = fract(sin(dot(i + float2(0.0, 0.0), float2(127.1, 311.7))) * 43758.5453123);
    float b = fract(sin(dot(i + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453123);
    float c = fract(sin(dot(i + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453123);
    float d = fract(sin(dot(i + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453123);
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

[[ stitchable ]] half4 vectorFireCircleShader(float2 position, half4 color, float2 size, float time) {
    
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float distToCenter = length(uv);
    float circleRadius = 0.85;
    
    if (distToCenter > circleRadius) {
        return half4(0.0, 0.0, 0.0, 1.0);
    }
    
    float2 noiseUV = uv * 2.5;
    
    float n1 = circle_fire_noise(noiseUV + float2(sin(time * 0.5) * 0.5, -time * 1.8));
    float n2 = circle_fire_noise(noiseUV * 1.8 + float2(-time * 1.2, cos(time * 0.7) * 0.6));
    
    float combinedNoise = n1 * 0.55 + n2 * 0.45;
    
    float intensity = combinedNoise * 0.8 + (1.0 - distToCenter / circleRadius) * 0.3;
    intensity = clamp(intensity, 0.0, 1.0);
    
    half3 finalColor = half3(0.0);
    
    float redMask = smoothstep(0.15, 0.17, intensity);
    half3 redColor = half3(0.92, 0.26, 0.08);
    finalColor = mix(finalColor, redColor, redMask);
    
    float orangeMask = smoothstep(0.35, 0.37, intensity);
    half3 orangeColor = half3(1.0, 0.54, 0.0);
    finalColor = mix(finalColor, orangeColor, orangeMask);
    
    float yellowMask = smoothstep(0.53, 0.55, intensity);
    half3 yellowColor = half3(1.0, 0.86, 0.0);
    finalColor = mix(finalColor, yellowColor, yellowMask);
    
    float coreMask = smoothstep(0.70, 0.72, intensity);
    half3 coreColor = half3(1.0, 0.98, 0.6);
    finalColor = mix(finalColor, coreColor, coreMask);
    
    float borderMask = smoothstep(circleRadius - 0.015, circleRadius - 0.005, distToCenter);
    finalColor = mix(finalColor, redColor, borderMask);
    
    return half4(finalColor, 1.0);
}
