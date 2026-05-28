//
//  LavaLampShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 lavaLampShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float totalEnergy = 0.0;
    
    const int blobsCount = 6;
    
    float2 centers[blobsCount] = {
        float2(sin(time * 0.8) * 0.4,  cos(time * 1.2) * 0.5),
        float2(cos(time * 0.5) * 0.5,  sin(time * 0.9) * 0.4),
        float2(sin(time * 1.1) * 0.3,  sin(time * 0.6) * 0.6),
        float2(cos(time * 0.7) * 0.6,  cos(time * 1.4) * 0.3),
        float2(sin(time * 1.3) * 0.5,  sin(time * 0.4) * -0.5),
        float2(cos(time * 0.9) * -0.4, cos(time * 1.1) * -0.4)
    };
    
    float radii[blobsCount] = { 0.18, 0.22, 0.15, 0.25, 0.14, 0.20 };
    
    for (int i = 0; i < blobsCount; i++) {
        float d = length(uv - centers[i]);
        
        totalEnergy += (radii[i] * radii[i]) / max(d * d, 0.0001);
    }
    
    half3 bgColor = half3(0.08, 0.02, 0.08);
    
    half3 lavaColor = half3(1.0, 0.0, 0.4);
    
    half3 coreColor = half3(1.0, 0.7, 0.9);
    half3 mixedLava = mix(lavaColor, coreColor, smoothstep(1.5, 4.0, totalEnergy));
    
    float edge = smoothstep(0.95, 1.05, totalEnergy);
    
    half3 finalColor = mix(bgColor, mixedLava, edge);
    
    float glow = smoothstep(0.3, 1.0, totalEnergy) * 0.3;
    finalColor += lavaColor * glow * (1.0 - edge);
    
    return half4(finalColor, 1.0);
}
