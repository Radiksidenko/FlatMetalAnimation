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
    
    var body: some View {
        ShaderContainerView { size, time in
            viewModel.makeShader(size: size, time: Double(time))
        }
    }
}

struct FireView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.vectorFireCircleShader(.float2(size), .float(time))
        }
    }
}

struct NeonWavesView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.neonWavesShader(.float2(size), .float(time))
        }
    }
}

struct PlasmaGlobeView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.plasmaGlobeShader(.float2(size), .float(time))
        }
    }
}

struct HypnoticSphereView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.hypnoticSphereShader(.float2(size), .float(time))
        }
    }
}

struct NeonWavesOrbView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.neonOrbWithWavesShader(.float2(size), .float(time))
        }
    }
}

struct NeonCubeView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.abstractCubeShader(.float2(size), .float(time))
        }
        .ignoresSafeArea()
    }
}

struct GlassCubeAnimationView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.glassLavaLampCubeShader(.float2(size), .float(time))
        }
    }
}

struct CubeSwarmView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.metalCubeSwarmShader(
                .float2(size),
                .float(time)
            )
        }
    }
}

struct ParticleSphereView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.sphereParticleShader(
                .float2(size),
                .float(time)
            )
        }
    }
}
struct LiquidLineView: View {
    var body: some View {
        ShaderContainerView { size, time in
            ShaderLibrary.liquidLineShader(.float2(size), .float(time))
        }
    }
}
