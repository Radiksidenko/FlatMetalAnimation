//
//  GlassSphere.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 02.06.2026.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

float2 hash2(float2 p) {
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

float voronoi(float2 x) {
    float2 n = floor(x);
    float2 f = fract(x);
    float minDist = 1.0;
    
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            float2 g = float2(float(i), float(j));
            float2 o = hash2(n + g);
            float2 r = g - f + o;
            float d = dot(r, r);
            if (d < minDist) {
                minDist = d;
            }
        }
    }
    return minDist;
}

float3 rotate3D(float3 p, float time) {
    float sY = sin(time * 0.5);
    float cY = cos(time * 0.5);
    float3 p1 = float3(p.x * cY + p.z * sY, p.y, -p.x * sY + p.z * cY);
    
    float sX = sin(time * 0.2);
    float cX = cos(time * 0.2);
    return float3(p1.x, p1.y * cX - p1.z * sX, p1.y * sX + p1.z * cX);
}

[[ stitchable ]] half4 animatedGlassSphereLayer(float2 position, SwiftUI::Layer layer, float2 size, float time) {
    float2 center = size / 2.0;
    float radius = min(size.x, size.y) * 0.45;
    
    float2 uv = (position - center) / radius;
    float len = length(uv);
    
    if (len > 1.0) {
        return half4(0.0, 0.0, 0.0, 0.0); 
    }
    
    float z = sqrt(1.0 - len * len);
    float3 baseNormal = normalize(float3(uv.x, uv.y, z));
    
    float3 rotatedNormal = rotate3D(baseNormal, time);
    
    float2 crackUV = rotatedNormal.xy * 5.0;
    float noise1 = voronoi(crackUV);
    float noise2 = voronoi(crackUV + float2(0.1));
    
    float crackLine = abs(noise1 - noise2);
    float isCrack = step(crackLine, 0.05) * step(0.4, noise1);
    
    float rings = sin(length(rotatedNormal.xy) * 40.0) * 0.15;
    
    float3 finalNormal = normalize(float3(
        uv.x,
        uv.y,
        z + rings * (1.0 - len) - (isCrack * 2.0)
    ));
    
    float ior = 0.5 + (isCrack * 0.3);
    float2 refractionOffset = finalNormal.xy * ior * radius;
    
    float aberration = 0.08 + (isCrack * 0.1);
    
    float2 uvR = position - refractionOffset * (1.0 + aberration);
    float2 uvG = position - refractionOffset;
    float2 uvB = position - refractionOffset * (1.0 - aberration);
    
    half r = layer.sample(uvR).r;
    half g = layer.sample(uvG).g;
    half b = layer.sample(uvB).b;
    
    float3 viewDir = float3(0.0, 0.0, 1.0);
    float fresnel = pow(1.0 - max(dot(baseNormal, viewDir), 0.0), 3.0);
    
    half3 finalColor = half3(r, g, b);
    finalColor += half3(fresnel * 0.6);
    
    finalColor += half3(isCrack * 0.4);
    
    float edgeShadow = smoothstep(0.8, 1.0, len);
    finalColor -= half3(edgeShadow * 0.3);
    
    return half4(finalColor, 1.0);
}
