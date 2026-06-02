//
//  GlassMetaballCubeShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 01.06.2026.
//

#include <metal_stdlib>
using namespace metal;

float2x2 rotateLava(float alpha) {
    float s = sin(alpha), c = cos(alpha);
    return float2x2(c, -s, s, c);
}

float sminLava(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdLavaBox(float3 p, float3 b) {
    float3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdLavaBlobs(float3 p, float time) {
    float3 centerPos = float3(0.0, 0.0, 0.0);
    float dCenter = length(p - centerPos) - 0.15;
    
    float3 pos1 = float3(0.0, -0.25 + sin(time * 0.7) * 0.2, 0.0);
    float d1 = length(p - pos1) - 0.25;
    
    float3 pos2 = float3(sin(time * 1.1) * 0.15, cos(time * 0.8) * 0.35, cos(time * 1.1) * 0.1);
    float d2 = length(p - pos2) - 0.18;
    
    float3 pos3 = float3(cos(time * 1.4) * 0.2, sin(time * 1.2) * 0.4, sin(time * 0.9) * 0.15);
    float d3 = length(p - pos3) - 0.12;
    
    float3 pos4 = float3(-0.1, -0.3 + cos(time * 0.5) * 0.15, 0.1);
    float d4 = length(p - pos4) - 0.15;
    
    float glue = 0.22;
    float res = sminLava(dCenter, d1, glue);
    res = sminLava(res, d2, glue);
    res = sminLava(res, d3, glue);
    res = sminLava(res, d4, glue);
    
    res += sin(p.x * 6.0 + time) * cos(p.y * 6.0 - time) * 0.01;
    
    return res;
}

float3 getLavaCubeNormal(float3 p) {
    float3 eps = float3(0.001, 0.0, 0.0);
    float3 b = float3(0.8);
    float3 n = float3(
        sdLavaBox(p + eps.xyz, b) - sdLavaBox(p - eps.xyz, b),
        sdLavaBox(p + eps.yxz, b) - sdLavaBox(p - eps.yxz, b),
        sdLavaBox(p + eps.yzx, b) - sdLavaBox(p - eps.yzx, b)
    );
    return normalize(n);
}

half3 renderLavaInside(float3 ro, float3 rd, float time) {
    float t = 0.0;
    for (int i = 0; i < 50; i++) {
        float3 p = ro + rd * t;
        float d = sdLavaBlobs(p, time);
        
        if (d < 0.001) {
            half3 magenta = half3(1.0, 0.15, 0.6);
            half3 electricBlue = half3(0.1, 0.4, 1.0);
            
            float mixFactor = smoothstep(-0.5, 0.5, p.y);
            half3 lavaColor = mix(electricBlue, magenta, mixFactor);
            
            float3 normal = normalize(p);
            float fresnel = pow(1.0 - max(dot(-rd, normal), 0.0), 3.0);
            lavaColor += half3(1.0, 0.6, 0.9) * fresnel * 0.7;
            
            return lavaColor;
        }
        if (t > 4.0) break;
        t += max(d, 0.008);
    }
    return half3(0.02, 0.02, 0.08);
}

[[ stitchable ]] half4 glassLavaLampCubeShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position - size * 0.5) / min(size.x, size.y);
    
    float3 ro = float3(0.0, 0.0, -5.2);
    float3 rd = normalize(float3(uv, 1.8));
    
    float2x2 rXZ = rotateLava(time * 0.25);
    float2x2 rXY = rotateLava(0.45);
    
    ro.xz = ro.xz * rXZ; ro.xy = ro.xy * rXY;
    rd.xz = rd.xz * rXZ; rd.xy = rd.xy * rXY;
    
    float tCube = 0.0;
    bool hitCube = false;
    float3 boxSize = float3(0.8, 0.8, 0.8);
    
    for (int i = 0; i < 80; i++) {
        float3 p = ro + rd * tCube;
        float d = sdLavaBox(p, boxSize);
        if (d < 0.001) {
            hitCube = true;
            break;
        }
        if (tCube > 15.0) break;
        tCube += d;
    }
    
    if (!hitCube) {
        return half4(0.03, 0.03, 0.05, 1.0);
    }
    
    float3 pCube = ro + rd * tCube;
    float3 nCube = getLavaCubeNormal(pCube);
    
    float3 rdR = refract(rd, nCube, 1.0 / 1.38);
    float3 rdG = refract(rd, nCube, 1.0 / 1.42);
    float3 rdB = refract(rd, nCube, 1.0 / 1.46);
    
    float3 roInside = pCube + rd * 0.02;
    
    half3 finalColor = half3(0.0);
    finalColor.r = renderLavaInside(roInside, rdR, time).r;
    finalColor.g = renderLavaInside(roInside, rdG, time).g;
    finalColor.b = renderLavaInside(roInside, rdB, time).b;
    
    float fresnelCube = pow(1.0 - max(dot(-rd, nCube), 0.0), 4.5);
    finalColor += half3(0.8, 0.9, 1.0) * fresnelCube * 0.7;
    
    return half4(finalColor, 1.0);
}
