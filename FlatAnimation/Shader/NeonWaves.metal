//
//  NeonWaves.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 neonWavesShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    half3 finalColor = half3(0.0, 0.0, 0.0);
    
    float wave1 = sin(uv.x * 2.5 + time * 3.0) * 0.25 + cos(uv.x * 1.5 - time * 1.5) * 0.1;
    float dist1 = abs(uv.y - wave1);
    float glow1 = 0.025 / max(dist1, 0.001);
    
    finalColor += half3(0.0, 0.9, 1.0) * glow1;
    
    float wave2 = sin(uv.x * 1.8 - time * 2.0) * 0.35 + sin(uv.x * 3.5 + time * 1.2) * 0.08;
    float dist2 = abs(uv.y - wave2);
    float glow2 = 0.03 / max(dist2, 0.001);
    finalColor += half3(1.0, 0.0, 0.6) * glow2;
    
    float wave3 = cos(uv.x * 1.2 + time * 1.1) * 0.45;
    float dist3 = abs(uv.y - wave3);
    float glow3 = 0.04 / max(dist3, 0.001);

    finalColor += half3(0.0, 1.0, 0.3) * glow3 * 0.7;
    
    float vignette = smoothstep(2.0, 0.5, length(uv));
    finalColor *= vignette;
    
    return half4(finalColor, 1.0);
}
