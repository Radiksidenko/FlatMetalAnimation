//
//  NoiseSphere.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 01.06.2026.
//

#include <metal_stdlib>
using namespace metal;

float sphere_noise3D(float3 p) {
    float3 i = floor(p);
    float3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    #define hash(p) fract(sin(dot(p, float3(127.1, 311.7, 74.7))) * 43758.5453123)
    float n000 = hash(i + float3(0,0,0)); float n100 = hash(i + float3(1,0,0));
    float n010 = hash(i + float3(0,1,0)); float n110 = hash(i + float3(1,1,0));
    float n001 = hash(i + float3(0,0,1)); float n101 = hash(i + float3(1,0,1));
    float n011 = hash(i + float3(0,1,1)); float n111 = hash(i + float3(1,1,1));
    
    return mix(mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
               mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y), f.z);
}

float3 rotate3D(float3 p, float angleX, float angleY) {
    float cx = cos(angleX), sx = sin(angleX);
    float3 p1 = float3(p.x, p.y * cx - p.z * sx, p.y * sx + p.z * cx);
    
    float cy = cos(angleY), sy = sin(angleY);
    return float3(p1.x * cy + p1.z * sy, p1.y, -p1.x * sy + p1.z * cy);
}

float sceneSDF(float3 p, float time) {
    float radius = 1.1;
    float baseSphere = length(p) - radius;
    
    float3 rotatedP = rotate3D(p, time * 0.2, time * 0.25);
    
    float3 noisePos = rotatedP * 2.2 + float3(0.0, 0.0, time * 0.3);
    float n = sphere_noise3D(noisePos);
    
    float waves = sin(n * 11.0 + time * 0.8) * 0.06;
    
    float detailNoise = sphere_noise3D(rotatedP * 7.0 - float3(0.0, time * 0.2, 0.0)) * 0.015;
    
    return baseSphere + waves - detailNoise;
}

float3 getNormal(float3 p, float time) {
    float2 e = float2(0.001, 0.0);
    return normalize(float3(
        sceneSDF(p + e.xyy, time) - sceneSDF(p - e.xyy, time),
        sceneSDF(p + e.yxy, time) - sceneSDF(p - e.yxy, time),
        sceneSDF(p + e.yyx, time) - sceneSDF(p - e.yyx, time)
    ));
}

[[ stitchable ]] half4 hypnoticSphereShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float3 camPos = float3(0.0, 0.0, -3.0);
    float3 rayDir = normalize(float3(uv, 1.5));
    
    rayDir = rotate3D(rayDir, time * 0.05, time * 0.08);
    camPos = rotate3D(camPos, time * 0.05, time * 0.08);
    
    float distTraveled = 0.0;
    float3 currentPos = camPos;
    bool hit = false;
    
    for (int i = 0; i < 45; i++) {
        currentPos = camPos + rayDir * distTraveled;
        float d = sceneSDF(currentPos, time);
        
        if (d < 0.001) {
            hit = true;
            break;
        }
        if (distTraveled > 5.0) break;
        distTraveled += d;
    }
    
    half3 finalColor = half3(0.12, 0.16, 0.22);
    
    if (hit) {
        float3 normal = getNormal(currentPos, time);
        
        float3 lightDir = normalize(float3(-1.0, 1.3, -1.0));
        
        float diffuse = max(dot(normal, lightDir), 0.0);
        float ao = clamp(sceneSDF(currentPos + normal * 0.1, time) / 0.1, 0.0, 1.0);
        float fresnel = pow(1.0 - max(dot(normal, -rayDir), 0.0), 3.0);
        
        half3 plasticColor = half3(0.25, 0.45, 0.65);
        half3 lightColor = half3(1.0, 1.0, 1.0);
        
        finalColor = plasticColor * (diffuse * 0.85 + 0.15) * ao;
        finalColor += lightColor * fresnel * 0.35;
        
        float3 reflectDir = reflect(-lightDir, normal);
        float spec = pow(max(dot(-rayDir, reflectDir), 0.0), 24.0);
        finalColor += lightColor * spec * 0.3;
    }
    
    return half4(finalColor, 1.0);
}

