//
//  PlasmaGlobeShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 plasmaGlobeShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float distToCenter = length(uv);
    float globeRadius = 0.85;
    
    if (distToCenter > globeRadius) {
        return half4(0.0, 0.0, 0.0, 1.0);
    }
    
    float angle = atan2(uv.y, uv.x);
    
    half3 finalColor = half3(0.0);
    
    float lightning = sin(angle * 3.0 + time * 2.0) * 0.15
                    + cos(angle * 7.0 - time * 3.5) * 0.05
                    + sin(angle * 13.0 + time * 5.0) * 0.02;
    
    lightning *= sin(distToCenter * 4.0 - time);
    
    float rayDistance = abs(distToCenter - 0.5 - lightning);
    
    float rayGlow = 0.012 / max(rayDistance, 0.001);
    
    rayGlow *= smoothstep(0.1, 0.4, distToCenter);
    rayGlow *= smoothstep(globeRadius, globeRadius - 0.1, distToCenter);
    
    finalColor += half3(1.0, 0.0, 0.5) * rayGlow;
    
    float coreRadius = 0.12;
    if (distToCenter < coreRadius) {
        finalColor += half3(0.5, 0.9, 1.0) * (distToCenter / coreRadius);
    }
    
    float coreGlow = 0.04 / max(distToCenter - coreRadius, 0.005);
    finalColor += half3(0.2, 0.0, 0.8) * coreGlow * smoothstep(globeRadius, 0.0, distToCenter);
    
    float borderMask = smoothstep(globeRadius - 0.02, globeRadius - 0.002, distToCenter);
    half3 borderColor = half3(0.6, 0.2, 1.0);
    finalColor = mix(finalColor, borderColor, borderMask);
    
    finalColor += half3(0.1, 0.0, 0.2) * (1.0 - distToCenter / globeRadius) * 0.4;
    
    return half4(finalColor, 1.0);
}
