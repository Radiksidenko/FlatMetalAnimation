//
//  CubeSwarmShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 01.06.2026.
//

#include <metal_stdlib>
using namespace metal;

float2x2 rotateMetal(float alpha) {
    float s = sin(alpha), c = cos(alpha);
    return float2x2(c, -s, s, c);
}

float sdMetalBox(float3 p, float3 b, float r) {
    float3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sceneMetalSwarmSDF(float3 p, float time) {
    p.xz = p.xz * rotateMetal(time * 0.25);
    p.xy = p.xy * rotateMetal(time * 0.12);
    
    float explode = abs(sin(time * 0.7)) * 1.0;
    
    float minDist = 9999.0;
    float3 boxSize = float3(0.26);
    float roundness = 0.03;
    
    minDist = min(minDist, sdMetalBox(p, boxSize, roundness));
    
    minDist = min(minDist, sdMetalBox(p - float3(explode, 0.0, 0.0), boxSize, roundness));
    minDist = min(minDist, sdMetalBox(p - float3(-explode, 0.0, 0.0), boxSize, roundness));
    minDist = min(minDist, sdMetalBox(p - float3(0.0, explode, 0.0), boxSize, roundness));
    minDist = min(minDist, sdMetalBox(p - float3(0.0, -explode, 0.0), boxSize, roundness));
    minDist = min(minDist, sdMetalBox(p - float3(0.0, 0.0, explode), boxSize, roundness));
    minDist = min(minDist, sdMetalBox(p - float3(0.0, 0.0, -explode), boxSize, roundness));
    
    return minDist;
}

float3 getMetalNormal(float3 p, float time) {
    float3 eps = float3(0.0005, 0.0, 0.0);
    float3 n = float3(
        sceneMetalSwarmSDF(p + eps.xyz, time) - sceneMetalSwarmSDF(p - eps.xyz, time),
        sceneMetalSwarmSDF(p + eps.yxz, time) - sceneMetalSwarmSDF(p - eps.yxz, time),
        sceneMetalSwarmSDF(p + eps.yzx, time) - sceneMetalSwarmSDF(p - eps.yzx, time)
    );
    return normalize(n);
}

half3 getEnvironmentReflection(float3 refDir, float time) {
    half3 skyColor = half3(0.05, 0.08, 0.2);
    half3 groundColor = half3(0.02, 0.01, 0.04);
    half3 env = mix(groundColor, skyColor, refDir.y * 0.5 + 0.5);
    
    float light1 = smoothstep(0.85, 0.98, sin(refDir.x * 2.0) * cos(refDir.y + time * 0.2));
    env += half3(1.0, 0.95, 0.9) * light1 * 1.5;
    
    float light2 = smoothstep(0.7, 0.99, sin(refDir.z * 3.0 + time * 0.5) * refDir.y);
    env += half3(0.9, 0.1, 0.6) * max(light2, 0.0) * 2.0;
    
    float light3 = smoothstep(0.8, 0.99, -refDir.y * cos(refDir.x));
    env += half3(0.1, 0.8, 0.9) * max(light3, 0.0) * 1.2;

    return env;
}

[[ stitchable ]] half4 metalCubeSwarmShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position - size * 0.5) / min(size.x, size.y);
    
    float3 ro = float3(0.0, 0.0, -4.5);
    float3 rd = normalize(float3(uv, 1.8));
    
    float t = 0.0;
    bool hit = false;
    
    for (int i = 0; i < 90; i++) {
        float3 p = ro + rd * t;
        float d = sceneMetalSwarmSDF(p, time);
        if (d < 0.0005) {
            hit = true;
            break;
        }
        if (t > 8.0) break;
        t += d;
    }
    
    if (!hit) {
        return half4(0.0, 0.0, 0.0, 1.0);
    }
    
    float3 p = ro + rd * t;
    float3 n = getMetalNormal(p, time);
    
    float3 refDir = reflect(rd, n);
    
    half3 reflectionColor = getEnvironmentReflection(refDir, time);
    
    half3 metalBaseColor = half3(0.15, 0.15, 0.18);
    
    float fresnel = pow(1.0 - max(dot(-rd, n), 0.0), 3.5);
    
    half3 finalColor = metalBaseColor + reflectionColor * 1.3;
    finalColor += half3(1.0, 0.6, 0.9) * fresnel * 0.6;
    
    float ao = smoothstep(0.0, 0.2, sceneMetalSwarmSDF(p + n * 0.1, time));
    finalColor *= (ao * 0.7 + 0.3);
    
    return half4(finalColor, 1.0);
}
