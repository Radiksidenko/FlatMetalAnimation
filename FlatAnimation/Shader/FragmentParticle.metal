//
//  FragmentParticle.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 02.06.2026.
//

#include <metal_stdlib>
using namespace metal;

struct Particle {
    float3 position;
    float3 velocity;
    float4 color;
    float life;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

float hash11(float p) {
    p = fract(p * .1031f);
    p *= p + 33.33f;
    p *= p + p;
    return fract(p);
}

kernel void computeParticle(device Particle* particles [[buffer(0)]],
                            constant float2& resolution [[buffer(1)]],
                            constant float& time [[buffer(2)]],
                            uint id [[thread_position_in_grid]])
{
    Particle p = particles[id];
    
    float3 center = float3(resolution * 0.5f, 0.0f);
    float3 dir = center - p.position;
    float dist = length(dir);
    
    float eventHorizon = 50.0f;
    float maxRadius = 550.0f;
    
    if (dist < eventHorizon || p.life <= 0.0f || dist > maxRadius) {
        float randVal = hash11(id + time);
        
        float startRadius = eventHorizon + 10.0f + (pow(randVal, 3.0f) * (maxRadius - eventHorizon - 50.0f));
        
        float timePulse = sin(time * 2.5f + startRadius * 0.02f) * 0.4f;
        
        float spiralTwist = 5.5f;
        float angle = hash11(id * 17.31f) * 6.2831f + timePulse;
        
        float track = floor(hash11(id * 3.14f) * 24.0f) / 24.0f;
        angle += (startRadius * 0.012f * spiralTwist) + track * 0.5f;
        
        p.position.x = center.x + cos(angle) * startRadius;
        p.position.y = center.y + sin(angle) * startRadius;
        p.position.z = (hash11(id * 4.5f) - 0.5f) * 6.0f;
        
        float orbitalSpeed = 150.0f * rsqrt(startRadius + 1.0f);
        float3 tangent = normalize(float3(-sin(angle), cos(angle), 0.0f));
        
        float3 inward = normalize(dir);
        p.velocity = tangent * orbitalSpeed * 22.0f + inward * 12.0f;
        
        p.life = 0.3f + hash11(id * 9.4f) * 0.7f;
        p.color = float4(0.0f);
    } else {
        float3 gravityDir = normalize(dir);
        float invDistSq = 1.0f / (dist * dist + 400.0f);
        
        float3 gravityForce = gravityDir * (450000.0f * invDistSq);
        
        float dt = 0.005f;
        p.velocity += gravityForce * dt;
        p.velocity.z -= p.position.z * 5.0f * dt;
        
        p.velocity *= 0.994f;
        p.position += p.velocity * dt;
        p.life -= 0.0008f;
        
        float u = clamp((dist - eventHorizon) / (maxRadius - eventHorizon), 0.0f, 1.0f);
        
        float pulseMod = sin(time * 1.0f - dist * 0.03f) * 0.15f;
        float waveFactor = clamp(u + pulseMod, 0.0f, 1.0f);
        
        float3 coreWhite  = float3(1.00f, 0.98f, 0.95f);
        float3 brightGold = float3(0.98f, 0.55f, 0.10f);
        float3 neonRed    = float3(0.85f, 0.08f, 0.05f);
        float3 deepMaroon = float3(0.20f, 0.01f, 0.05f);
        
        float3 finalRGB = float3(0.0f);
        if (waveFactor < 0.10f) {
            finalRGB = mix(coreWhite, brightGold, waveFactor / 0.10f);
        } else if (waveFactor < 0.40f) {
            finalRGB = mix(brightGold, neonRed, (waveFactor - 0.10f) / 0.30f);
        } else {
            finalRGB = mix(neonRed, deepMaroon, (waveFactor - 0.40f) / 0.60f);
        }
        
        float dust = hash11(id * 0.03f);
        if (dust > 0.95f) {
            finalRGB = mix(finalRGB, coreWhite, 0.4f);
        }
        
        float innerFade = smoothstep(0.0f, 12.0f, dist - eventHorizon);
        float outerFade = smoothstep(0.0f, 60.0f, maxRadius - dist);
        
        float waveBrightness = 1.0f + sin(time * 3.0f + dist * 0.05f) * 0.25f;
        float brightness = mix(1.2f, 0.4f, u) * waveBrightness;
        
        p.color = float4(finalRGB, p.life * innerFade * outerFade * brightness);
    }
    
    particles[id] = p;
}

vertex VertexOut vertexParticle(device const Particle* particles [[buffer(0)]],
                               constant float2& resolution [[buffer(1)]],
                               constant float& time [[buffer(2)]],
                               uint id [[vertex_id]])
{
    VertexOut out;
    float3 pos = particles[id].position;
    float3 center = float3(resolution * 0.5f, 0.0f);
    
    float3 localPos = pos - center;
    
    float angleX = 1.35f;
    float cosX = cos(angleX), sinX = sin(angleX);
    float angleY = 0.20f;
    float cosY = cos(angleY), sinY = sin(angleY);
    
    float3 rotatedY;
    rotatedY.x = localPos.x * cosY - localPos.z * sinY;
    rotatedY.y = localPos.y;
    rotatedY.z = localPos.x * sinY + localPos.z * cosY;
    
    float3 finalRotated;
    finalRotated.x = rotatedY.x;
    finalRotated.y = rotatedY.y * cosX - rotatedY.z * sinX;
    finalRotated.z = rotatedY.y * sinX + rotatedY.z * cosX;
    
    float r = length(finalRotated.xy);
    float eventHorizonScreen = 45.0f;
    if (finalRotated.z < 10.0f && r > eventHorizonScreen) {
        float lensFactor = 1.0f + (3600.0f / (r * r + 10.0f));
        float zWeight = clamp((10.0f - finalRotated.z) * 0.015f, 0.0f, 1.0f);
        finalRotated.xy *= mix(1.0f, lensFactor, zWeight);
    }
    
    float3 finalWorldPos = finalRotated + center;
    float2 ndc = (finalWorldPos.xy / resolution) * 2.0f - 1.0f;
    ndc.y = -ndc.y;
    
    out.position = float4(ndc, 0.0f, 1.0f);
    out.color = particles[id].color;
    
    float uDist = length(localPos) / 550.0f;
    out.pointSize = clamp(4.0f * (1.0f - uDist) + 1.0f, 1.2f, 5.0f);
    
    return out;
}

fragment float4 fragmentParticle(VertexOut input [[stage_in]],
                                 float2 pointCoord [[point_coord]])
{
    float distToCenter = length(pointCoord - float2(0.5f));
    if (distToCenter > 0.5f) {
        discard_fragment();
    }
    
    float alpha = 1.0f - smoothstep(0.1f, 0.5f, distToCenter);
    alpha = pow(alpha, 2.0f);
    
    return float4(input.color.rgb, input.color.a * alpha * 0.75f);
}
