//
//  File.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 01.06.2026.
//

#include <metal_stdlib>
using namespace metal;

half3 cubeRainbow(float h) {
    half3 c = half3(fract(h + float3(0.0, 2.0/3.0, 1.0/3.0)));
    half3 rgb = clamp(abs(c * 6.0 - 3.0) - 1.0, 0.0, 1.0);
    return mix(half3(1.0), rgb, 1.0);
}

float2x2 rotate2DCube(float alpha) {
    float s = sin(alpha), c = cos(alpha);
    return float2x2(c, -s, s, c);
}

float sdRoundBox(float3 p, float3 b, float r) {
    float3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float cubeSceneSDF(float3 p, float time, thread float &colorTrack) {
    p.xz = p.xz * rotate2DCube(time * 0.4);
    p.xy = p.xy * rotate2DCube(time * 0.25);
    
    colorTrack = length(p.xyz) + p.y * 0.5 + time * 1.0;
    
    float3 boxSize = float3(0.8, 0.8, 0.8);
    float roundness = 0.08;
    float boxBox = sdRoundBox(p, boxSize, roundness);
    
    float pattern = sin(p.x * 10.0 + time) * sin(p.y * 10.0) * sin(p.z * 10.0);
    
    return max(boxBox, -pattern * 0.04) * 0.5;
}

[[ stitchable ]] half4 abstractCubeShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float3 ro = float3(0.0, 0.0, -4.0);
    float3 rd = normalize(float3(uv, 1.5));
    
    float t = 0.0;
    float colorTrack = 0.0;
    float minD = 9999.0;
    float lastColorTrack = 0.0;
    
    for (int i = 0; i < 90; i++) {
        float3 p = ro + rd * t;
        float d = cubeSceneSDF(p, time, colorTrack);
        
        if (d < minD) {
            minD = d;
            lastColorTrack = colorTrack;
        }
        
        if (d < 0.0005 || t > 8.0) break;
        
        t += d * 0.85;
    }
    
    float alpha = smoothstep(0.008, 0.0002, minD);
    
    if (alpha <= 0.0) {
        return half4(0.0, 0.0, 0.0, 1.0);
    }
    
    float light = 1.0 / (1.0 + t * t * 0.12);
    half3 cubeColor = cubeRainbow(lastColorTrack * 0.2 + t * 0.05);
    
    cubeColor *= (light * 1.8);
    
    return half4(mix(half3(0.0), cubeColor, alpha), 1.0);
}
