//
//  NeonTunnel.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 02.06.2026.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 neonTunnelShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float absX = abs(uv.x);
    float absY = abs(uv.y);
    if (max(absX, absY) < 0.01) return half4(0.0, 0.0, 0.0, 1.0);
    
    float perspectiveZ;
    float2 wallUV;
    
    if (absX > absY) {
        perspectiveZ = 1.0 / absX;
        wallUV = float2(uv.y * perspectiveZ, perspectiveZ + time * 2.0);
    } else {
        perspectiveZ = 1.0 / absY;
        wallUV = float2(uv.x * perspectiveZ, perspectiveZ + time * 2.0);
    }
    
    float2 gridScale = float2(4.0, 4.0);
    float2 st = wallUV * gridScale;
    
    float2 gridFract = abs(fract(st) - 0.5);
    
    float thickness = 0.02;
    float glowX = thickness / max(gridFract.x, 0.005);
    float glowY = thickness / max(gridFract.y, 0.005);
    
    float finalGlow = glowX + glowY;
    
    half3 neonColor = half3(0.0);
    
    if (absX > absY) {
        if (uv.x > 0.0) {
            neonColor = mix(half3(0.0, 0.5, 1.0), half3(0.7, 0.0, 1.0), half(sin(wallUV.y) * 0.5 + 0.5));
        } else {
            neonColor = half3(1.0, 0.0, 0.8);
        }
    } else {
        if (uv.y > 0.0) {
            neonColor = mix(half3(0.5, 0.0, 1.0), half3(1.0, 0.3, 0.0), half(uv.x * 0.5 + 0.5));
        } else {
            neonColor = half3(0.0, 0.3, 1.0);
        }
    }
    
    half3 finalColor = neonColor * finalGlow;
    
    finalColor = pow(finalColor, 1.2);
    
    float depthFade = smoothstep(0.0, 0.5, 1.0 / perspectiveZ);
    finalColor *= depthFade;
    
    finalColor = clamp(finalColor, 0.0, 1.5);
    
    return half4(finalColor, 1.0);
}
