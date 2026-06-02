//
//  LiquidMetal.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 02.06.2026.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = fract(sin(dot(i, float2(12.9898, 78.233))) * 43758.5453);
    float b = fract(sin(dot(i + float2(1.0, 0.0), float2(12.9898, 78.233))) * 43758.5453);
    float c = fract(sin(dot(i + float2(0.0, 1.0), float2(12.9898, 78.233))) * 43758.5453);
    float d = fract(sin(dot(i + float2(1.0, 1.0), float2(12.9898, 78.233))) * 43758.5453);
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(float2 p, float time) {
    float f = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 4; i++) {
        f += amp * noise(p + time * 0.2);
        p = p * 2.0 + float2(time * 0.1, -time * 0.15);
        amp *= 0.5;
    }
    return f;
}

[[ stitchable ]] half4 liquidMetalShader(float2 position, half4 color, float time, float2 size) {
    float2 uv = position / size.y;
    
    uv *= 3.0;
    
    float2 q = float2(fbm(uv + float2(0.0, 0.0), time),
                      fbm(uv + float2(5.2, 1.3), time));
                      
    float2 r = float2(fbm(uv + 4.0 * q + float2(1.7, 9.2), time),
                      fbm(uv + 4.0 * q + float2(8.3, 2.8), time));
    
    float value = fbm(uv + 4.0 * r, time);
    
    float eps = 0.01;
    float nx = fbm(uv + 4.0 * r + float2(eps, 0.0), time) - value;
    float ny = fbm(uv + 4.0 * r + float2(0.0, eps), time) - value;
    float3 normal = normalize(float3(-nx, -ny, eps * 2.0));
    
    float3 light = normalize(float3(1.0, 1.0, 2.0));
    
    float3 col1 = float3(0.8, 0.5, 0.2);
    float3 col2 = float3(0.1, 0.6, 0.9);
    float3 col3 = float3(0.1, 0.1, 0.12);
    
    float3 baseColor = mix(col3, col1, clamp(value * 1.5, 0.0, 1.0));
    baseColor = mix(baseColor, col2, clamp(length(q) - 0.2, 0.0, 1.0));
    
    float specular = pow(max(dot(normal, light), 0.0), 30.0);
    float fresnel = pow(1.0 - max(dot(normal, float3(0.0, 0.0, 1.0)), 0.0), 3.0);
    
    float3 finalColor = baseColor * (value + 0.5)
                      + float3(1.0) * specular * 1.5
                      + col2 * fresnel * 0.8;
                      
    return half4(half3(finalColor), 1.0);
}
