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
    
    float eventHorizon = 60.0f;
    
    if (dist < eventHorizon || p.life <= 0.0f) {
        float randAngle = hash11(id + time) * 6.2831f;
        float startRadius = 300.0f + hash11(id * 2.3f) * 200.0f;
        
        p.position.x = center.x + cos(randAngle) * startRadius;
        p.position.y = center.y + sin(randAngle) * startRadius;
        p.position.z = (hash11(id * 5.7f) - 0.5f) * 30.0f;
        
        float3 tangent = normalize(float3(-sin(randAngle), cos(randAngle), 0.0f));
        p.velocity = tangent * (35.0f + hash11(id * 8.1f) * 15.0f);
        p.life = 1.0f + hash11(id * 4.4f) * 2.0f;
        p.color = float4(0.0f);
    } else {
        float3 gravityDir = normalize(dir);
        float gravityForce = 45000.0f / (dist * dist + 100.0f);
        
        float3 tangentDir = normalize(float3(-gravityDir.y, gravityDir.x, 0.0f));
        
        float3 acceleration = gravityDir * gravityForce + tangentDir * (gravityForce * 0.8f);
        acceleration.z -= p.position.z * 0.5f;
        
        p.velocity += acceleration * 0.16f;
        p.velocity *= 0.985f;
        p.position += p.velocity * 0.16f;
        
        p.life -= 0.003f;
        
        float speed = length(p.velocity);
        float temperature = clamp((speed - 10.0f) / 60.0f, 0.0f, 1.0f);
        
        float3 coldColor = float3(0.3f, 0.05f, 0.6f);
        float3 midColor  = float3(0.9f, 0.2f, 0.05f);
        float3 hotColor  = float3(1.0f, 0.95f, 0.7f);
        
        float3 finalRGB = mix(coldColor, midColor, smoothstep(0.0f, 0.5f, temperature));
        finalRGB = mix(finalRGB, hotColor, smoothstep(0.5f, 1.0f, temperature));
        
        float fade = min(p.life * 4.0f, (dist - eventHorizon) / 40.0f);
        p.color = float4(finalRGB, clamp(fade, 0.0f, 1.0f));
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
    
    float angleX = 1.2f;
    float cosX = cos(angleX), sinX = sin(angleX);
    
    float angleY = 0.5f;
    float cosY = cos(angleY), sinY = sin(angleY);
    
    float3 rotatedY;
    rotatedY.x = localPos.x * cosY - localPos.z * sinY;
    rotatedY.y = localPos.y;
    rotatedY.z = localPos.x * sinY + localPos.z * cosY;
    
    float3 finalRotated;
    finalRotated.x = rotatedY.x;
    finalRotated.y = rotatedY.y * cosX - rotatedY.z * sinX;
    finalRotated.z = rotatedY.y * sinX + rotatedY.z * cosX;
    
    float3 finalWorldPos = finalRotated + center;
    
    float2 ndc = (finalWorldPos.xy / resolution) * 2.0f - 1.0f;
    ndc.y = -ndc.y;
    
    out.position = float4(ndc, 0.0f, 1.0f);
    out.color = particles[id].color;
    
    float zDepth = finalRotated.z;
    out.pointSize = max(1.0f, 2.2f + (zDepth * 0.006f));
    
    return out;
}

fragment float4 fragmentParticle(VertexOut input [[stage_in]]) {
    float2 coord = float2(0.0f);
    return input.color;
}
