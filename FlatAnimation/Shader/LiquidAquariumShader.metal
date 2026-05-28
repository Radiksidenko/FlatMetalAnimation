//
//  LiquidAquariumShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 liquidAquariumShader(float2 position, half4 color, float2 size, float time,
                                           half4 c1, half4 c2, half4 c3,
                                           half4 r1, half4 r2) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float aquariumRadius = 0.85;
    float pixelDistToCenter = length(uv);
    
    if (pixelDistToCenter > aquariumRadius) {
        return half4(0.0, 0.0, 0.0, 1.0);
    }
    
    float2 centers[6] = {
        float2(c1.r, c1.g), float2(c1.b, c1.a),
        float2(c2.r, c2.g), float2(c2.b, c2.a),
        float2(c3.r, c3.g), float2(c3.b, c3.a)
    };
    
    float radii[6] = {
        float(r1.r), float(r1.g), float(r1.b), float(r1.a),
        float(r2.r), float(r2.g)
    };
    
    float totalEnergy = 0.0;
    
    for (int i = 0; i < 6; i++) {
        float d = length(uv - centers[i]);
        totalEnergy += (radii[i] * radii[i]) / max(d * d, 0.0001);
    }
    
    half3 bgColor = half3(0.05, 0.01, 0.06);
    half3 lavaColor = half3(1.0, 0.0, 0.4);
    half3 coreColor = half3(1.0, 0.7, 0.9);
    
    half3 mixedLava = mix(lavaColor, coreColor, smoothstep(1.5, 4.0, totalEnergy));
    
    float edge = smoothstep(0.95, 1.05, totalEnergy);
    half3 finalColor = mix(bgColor, mixedLava, edge);
    
    float glow = smoothstep(0.3, 1.0, totalEnergy) * 0.25;
    finalColor += lavaColor * glow * (1.0 - edge);
    
    float borderMask = smoothstep(aquariumRadius - 0.012, aquariumRadius - 0.002, pixelDistToCenter);
    half3 borderColor = half3(0.8, 0.3, 1.0);
    finalColor = mix(finalColor, borderColor, borderMask);
    
    return half4(finalColor, 1.0);
}
