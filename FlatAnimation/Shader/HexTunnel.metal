//
//  HexTunnel.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 02.06.2026.
//

#include <metal_stdlib>
using namespace metal;

float hashParticles(float3 p) {
    p = fract(p * float3(443.8975, 397.2973, 491.1871));
    p += dot(p.xyz, p.yzx + 19.19);
    return fract(p.x * p.y * p.z);
}

[[ stitchable ]] half4 hexTunnelShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = (position * 2.0 - size) / min(size.x, size.y);
    
    float cameraAngle = sin(time * 0.5) * 0.2;
    float2 cameraOffset = float2(sin(time * 1.0) * 0.2, cos(time * 0.7) * 0.1);
    
    float cosCam = cos(cameraAngle);
    float sinCam = sin(cameraAngle);
    uv = float2(uv.x * cosCam - uv.y * sinCam, uv.x * sinCam + uv.y * cosCam);
    uv -= cameraOffset;
    
    float r = length(uv);
    if (r < 0.01) return half4(0.0, 0.0, 0.0, 1.0);
    
    float angle = atan2(uv.y, uv.x) + time * 0.2;
    
    float roundHexFactor = cos(angle * 6.0) * 0.07;
    float hexRadius = r * (1.0 - roundHexFactor);
    
    float z = 1.0 / hexRadius;
    
    float pAngle = angle + z * 0.15 + time * 0.3;
    
    float twistedRoundHex = cos(pAngle * 6.0) * 0.07;
    float twistedZ = 1.0 / (r * (1.0 - twistedRoundHex));
    
    float xTunnel = pAngle * (3.0 / 3.14159265);
    float yTunnel = twistedZ + time * 2.5;
    
    float2 gridFract = abs(fract(float2(xTunnel, yTunnel)) - 0.5);
    
    float ringLine = smoothstep(0.46, 0.5, 0.5 - gridFract.y);
    float edgeLine = smoothstep(0.48, 0.5, 0.5 - gridFract.x) * 0.2;
    
    float finalGrid = max(ringLine, edgeLine);
    
    float glow = 0.02 / max(0.5 - max(gridFract.x, gridFract.y), 0.001);
    glow += finalGrid * 2.0;
    
    half3 neonPurple = half3(0.4, 0.1, 1.0);
    half3 neonBlue   = half3(0.1, 0.3, 1.0);
    half3 tunnelColor = mix(neonPurple, neonBlue, half(sin(z * 0.5) * 0.5 + 0.5));
    
    half3 finalTunnel = tunnelColor * glow;
    
    finalTunnel *= smoothstep(0.0, 0.3, r);
    
    float3 particlesColor = float3(0.0);
    for (float j = 1.0; j <= 3.0; j++) {
        float pTime = time * 2.0 + j * 15.0;
        float pZ = fract(-pTime * 0.25);
        
        float seed = floor(-pTime * 0.25) + j;
        float2 pCenter = float2(
            hashParticles(float3(seed, 2.0, j)) - 0.5,
            hashParticles(float3(seed, 7.0, j)) - 0.5
        ) * 1.5;
        
        float2 pScreenPos = pCenter / (pZ + 0.005);
        float pDist = length(uv - pScreenPos);
        
        float pSize = 0.005 * (1.0 - pZ);
        float pGlow = pSize / max(pDist, 0.001);
        
        particlesColor += float3(0.6, 0.4, 1.0) * pGlow * smoothstep(1.0, 0.2, pZ);
    }
    
    half3 finalColor = finalTunnel + half3(particlesColor);
    
    finalColor *= smoothstep(2.0, 0.7, length(uv));
    
    finalColor = finalColor / (finalColor + half3(1.0)) * 1.5;
    
    return half4(finalColor, 1.0);
}
