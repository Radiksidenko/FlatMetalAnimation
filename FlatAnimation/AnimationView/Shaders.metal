//
//  Shaders.metal
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 plasmaShader(float2 position, half4 color, float2 size, float time) {
    float2 uv = position / size;
    
    float v = sin(uv.x * 10.0 + time) + sin(uv.y * 10.0 + time);
    
    return half4(v, v * 0.5, 1.0 - v, 1.0);
}
