//
//  Shaders.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 plasmaShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = position / size;
    
    float2 k = uv * 10.0;
    
    float v1 = sin(k.x + time);
    
    float v2 = sin(k.y + time * 1.5 + sin(k.x + time));
    
    float2 center = k - float2(5.0, 5.0);
    float v3 = sin(length(center) + time * 2.0);
    
    float v4 = sin(sqrt(k.x * k.x + k.y * k.y) + time);
    
    float total = (v1 + v2 + v3 + v4) / 4.0;
    
    float p = total * 0.5 + 0.5;
    
    half r = sin(p * M_PI_F + time) * 0.5 + 0.5;
    half g = sin(p * M_PI_F + time + 2.0) * 0.5 + 0.5;
    half b = sin(p * M_PI_F + time + 4.0) * 0.5 + 0.5;
    
    return half4(r, g, b, 1.0);
}

[[ stitchable ]] half4 particleShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    float3 col = float3(0.0);
    
    for(float i = 0.0; i < 20.0; i++) {
        float2 p = float2(sin(time + i) * 0.5, cos(time + i * 0.5) * 0.5);
        float d = length(uv - p);
        col += 0.01 / d * float3(0.2, 0.5, 1.0);
    }
    
    return half4(half3(col), 1.0);
}

[[ stitchable ]] half4 waveShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = position / size;
    
    float wave1 = sin(uv.x * 6.0 + time * 2.0) * 0.05;
    float wave2 = sin(uv.x * 12.0 - time * 1.5) * 0.02;
    
    float waveCenter = 0.5 + wave1 + wave2;
    
    float edge = smoothstep(waveCenter - 0.005, waveCenter + 0.005, uv.y);
    
    half4 colorTop = half4(0.1, 0.4, 0.8, 1.0);
    half4 colorBottom = half4(0.0, 0.1, 0.3, 1.0);
    
    return mix(colorBottom, colorTop, edge);
}

[[ stitchable ]] half4 particleFShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    uv.y = -uv.y;
    
    float3 col = float3(0.0);
    
    const int particleCount = 20;
    
    float2 targets[particleCount] = {
        float2(-0.2, -0.5), float2(-0.2, -0.3), float2(-0.2, -0.1),
        float2(-0.2,  0.1), float2(-0.2,  0.3), float2(-0.2,  0.5),
        
        float2(-0.0,  0.5), float2( 0.2,  0.5), float2( 0.4,  0.5), float2( 0.6,  0.5),
        
        float2(-0.0,  0.0), float2( 0.2,  0.0), float2( 0.4,  0.0),
        
        float2(-0.2, -0.4), float2(-0.2,  0.2), float2( 0.1,  0.5),
        float2( 0.3,  0.5), float2( 0.5,  0.5), float2( 0.1,  0.0), float2( 0.3,  0.0)
    };
    
    for(int i = 0; i < particleCount; i++) {
        float2 basePos = targets[i];

        float2 offset = float2(
            sin(time * 2.0 + float(i) * 0.5) * 0.03,
            cos(time * 2.5 + float(i) * 0.8) * 0.03
        );
        
        float2 p = basePos + offset;
        
        float d = length(uv - p);

        float intensity = 0.008 / max(d, 0.001);
        
        float3 particleColor = float3(
            0.2 + 0.5 * sin(time + float(i) * 0.3),
            0.5 + 0.5 * cos(time + float(i) * 0.5),
            1.0
        );
        
        col += intensity * particleColor;
    }
    
    return half4(half3(col), 1.0);
}
