//
//  CardGridView.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

import SwiftUI

struct AnimationItem: Identifiable {
    let id = UUID()
    let title: String
    let view: AnyView
}

struct CardGridView: View {
    let items = [
        AnimationItem(title: "HexTunnelView", view: AnyView(HexTunnelView())),
        AnimationItem(title: "NeonTunnelView", view: AnyView(NeonTunnelView())),
        AnimationItem(title: "ParticleMetal", view: AnyView(ParticleMetalView())),
        AnimationItem(title: "LiquidLine", view: AnyView(LiquidLineView())),
        AnimationItem(title: "ParticleSphere", view: AnyView(ParticleSphereView())),
        AnimationItem(title: "CubeSwarm", view: AnyView(CubeSwarmView())),
        AnimationItem(title: "GlassCubeAnimation", view: AnyView(GlassCubeAnimationView())),
        AnimationItem(title: "NeonCube", view: AnyView(NeonCubeView())),
        AnimationItem(title: "NeonWavesOrb", view: AnyView(NeonWavesOrbView())),
        AnimationItem(title: "HypnoticSphere", view: AnyView(HypnoticSphereView())),
        AnimationItem(title: "Plasma", view: AnyView(PlasmaView())),
        AnimationItem(title: "Waves", view: AnyView(WaveView())),
        AnimationItem(title: "Particles", view: AnyView(ParticleView())),
        AnimationItem(title: "Particle F", view: AnyView(ParticleFView())),
        AnimationItem(title: "Orb", view: AnyView(OrbAnimationView())),
        AnimationItem(title: "LavaLamp", view: AnyView(LavaLampView())),
        AnimationItem(title: "NeonWaves", view: AnyView(NeonWavesView())),
        AnimationItem(title: "PlasmaGlobe", view: AnyView(PlasmaGlobeView())),
        AnimationItem(title: "Aquarium", view: AnyView(AquariumView())),
        AnimationItem(title: "Fire", view: AnyView(FireView()))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(destination: item.view) {
                            AnimationCard(title: item.title)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(16)
            }
            .navigationTitle("Gallery")
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}
