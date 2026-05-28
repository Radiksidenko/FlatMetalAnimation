//
//  AbstractOrbShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

#include <metal_stdlib>
using namespace metal;

half3 rainbow(float h) {
    half3 c = half3(fract(h + float3(0.0, 2.0/3.0, 1.0/3.0)));
    half3 rgb = clamp(abs(c * 6.0 - 3.0) - 1.0, 0.0, 1.0);
    return mix(half3(1.0), rgb, 1.0);
}

float2x2 rotate2D(float alpha) {
    float s = sin(alpha), c = cos(alpha);
    return float2x2(c, -s, s, c);
}

float sceneSDF(float3 p, float time, thread float &colorTrack) {
    p.xz = p.xz * rotate2D(time * 0.3);
    p.xy = p.xy * rotate2D(time * 0.15);
    
    float r = length(p);
    
    float angle = atan2(p.z, p.x);
    float twist = angle + p.y * 2.0 + time * 1.5;
    
    colorTrack = twist;
    
    float ribbons = sin(twist * 3.0) * 0.25;
    
    float sphereThickness = abs(r - 1.25) - 0.05;
    
    return max(sphereThickness, -ribbons) * 0.5;
}

[[ stitchable ]] half4 abstractOrbShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float3 ro = float3(0.0, 0.0, -3.5);
    float3 rd = normalize(float3(uv, 1.5));
    
    float t = 0.0;
    float colorTrack = 0.0;
    float minD = 9999.0;
    float lastColorTrack = 0.0;
    
    for (int i = 0; i < 90; i++) {
        float3 p = ro + rd * t;
        float d = sceneSDF(p, time, colorTrack);
        
        if (d < minD) {
            minD = d;
            lastColorTrack = colorTrack;
        }
        
        if (d < 0.0005 || t > 7.0) break;
        
        t += d * 0.85;
    }
    
    float alpha = smoothstep(0.006, 0.0002, minD);
    
    if (alpha <= 0.0) {
        return half4(0.0, 0.0, 0.0, 1.0);
    }
    
    float light = 1.0 / (1.0 + t * t * 0.15);
    half3 orbColor = rainbow(lastColorTrack * 0.16 + t * 0.08);
    
    orbColor *= (light * 1.5);
    
    return half4(mix(half3(0.0), orbColor, alpha), 1.0);
}
