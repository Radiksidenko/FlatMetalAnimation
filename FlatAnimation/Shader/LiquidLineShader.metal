//
//  LiquidLineShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 01.06.2026.
//

#include <metal_stdlib>
using namespace metal;

float getGlow(float dist, float radius, float intensity) {
    return pow(intensity / max(abs(dist - radius), 0.005), 1.5);
}

[[ stitchable ]] half4 liquidLineShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float angle = atan2(uv.y, uv.x);
    float radius = length(uv);
    
    float wave1 = sin(angle * 3.0 + time * 1.2) * 0.15;
    float wave2 = cos(radius * 4.0 - time * 0.8) * 0.1;
    float wave3 = sin(uv.x * 2.0 + uv.y * 2.0 + time) * 0.1;
    
    float glassShape = 0.45 + wave1 + wave2 + wave3;
    
    float distToGlass = abs(radius - glassShape);
    
    float glassMask = smoothstep(0.12, 0.08, distToGlass);
    
    if (glassMask < 0.01) {
        return half4(0.0, 0.0, 0.0, 0.0);
    }
    
    float lightDir = sin(angle - time * 0.5);
    float light = smoothstep(-1.0, 1.0, lightDir);
    
    float specMask = smoothstep(0.03, 0.0, distToGlass);
    float spec = pow(specMask, 8.0) * (light * 0.7 + 0.3);
    float spec2 = getGlow(radius, glassShape - 0.02, 0.002) * 0.5;
    
    float fresnel = pow(distToGlass * 7.0, 2.5) * glassMask;
    
    float3 colorGreen  = float3(0.1, 0.8, 0.2);
    float3 colorYellow = float3(0.9, 0.7, 0.0);
    float3 colorPink   = float3(0.9, 0.1, 0.5);
    
    float3 baseColor = mix(colorGreen, colorYellow, sin(angle + time) * 0.5 + 0.5);
    baseColor = mix(baseColor, colorPink, cos(radius * 3.0 - time * 0.5) * 0.5 + 0.5);
    
    float3 finalColor = baseColor * (light * 0.5 + 0.5);
    
    finalColor += float3(0.8, 1.0, 0.9) * fresnel * 0.4;
    
    finalColor += float3(1.0) * (spec * 0.8 + spec2);
    
    finalColor *= glassMask;
    
    return half4(half3(finalColor), 1.0);
}
