//
//  GlassOrbShader.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 01.06.2026.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 sphereParticleShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float3 finalColor = float3(0.0);
    
    const int numParticles = 60;
    
    float radius = 0.58 + sin(time * 1.5) * 0.08;
    
    for(int i = 0; i < numParticles; i++) {
        float id = float(i);
        float lat = acos(1.0 - 2.0 * (id + 0.5) / float(numParticles));
        float lon = id * 2.39996;
        
        float3 p = float3(
            sin(lat) * cos(lon),
            sin(lat) * sin(lon),
            cos(lat)
        ) * radius;
        
        float angleY = time * 0.5;
        float angleX = time * 0.3;
        
        float3 pRot = float3(
            p.x * cos(angleY) - p.z * sin(angleY),
            p.y,
            p.x * sin(angleY) + p.z * cos(angleY)
        );
        
        pRot = float3(
            pRot.x,
            pRot.y * cos(angleX) - pRot.z * sin(angleX),
            pRot.y * sin(angleX) + pRot.z * cos(angleX)
        );
        
        float2 p2d = pRot.xy;
        
        float d = length(uv - p2d);
        
        float3 particleColor = mix(float3(0.9, 0.1, 0.6), float3(0.1, 0.4, 1.0), smoothstep(-0.5, 0.5, pRot.x));
        
        float depthFade = smoothstep(-0.7, 0.7, pRot.z);
        
        finalColor += (0.003 / max(d, 0.001)) * particleColor * depthFade;
    }
    
    float distToCenter = length(uv);
    float sphereGlow = smoothstep(radius + 0.1, radius - 0.1, distToCenter) * 0.04;
    finalColor += sphereGlow * float3(0.4, 0.2, 0.8);
    
    return half4(half3(finalColor), 1.0);
}
