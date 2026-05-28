//
//  MetalAnimationView.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

import SwiftUI

struct ParticleView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.particleShader(.float2(size), .float(time))
        }
    }
}

struct ParticleFView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.particleFShader(.float2(size), .float(time))
        }
    }
}

struct WaveView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.waveShader(.float2(size), .float(time))
        }
    }
}

struct OrbAnimationView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.abstractOrbShader(.float2(size), .float(time))
        }
    }
}

struct PlasmaView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.plasmaShader(.float2(size), .float(time))
        }
    }
}

struct LavaLampView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.lavaLampShader(.float2(size), .float(time))
        }
    }
}

struct AquariumView: View {
    @StateObject private var viewModel = AquariumViewModel()
    let startTime = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = startTime.distance(to: context.date)
            
            Rectangle()
                .fill(.black)
                .visualEffect { content, geometryProxy in
                    content.colorEffect(
                        viewModel.makeShader(size: geometryProxy.size, time: time)
                    )
                }
                .ignoresSafeArea()
        }
    }
}
