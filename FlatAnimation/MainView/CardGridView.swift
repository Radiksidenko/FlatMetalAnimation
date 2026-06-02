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
        AnimationItem(title: "ParticleMetalView", view: AnyView(ParticleMetalView())),
        AnimationItem(title: "LiquidLineView", view: AnyView(LiquidLineView())),
        AnimationItem(title: "ParticleSphereView", view: AnyView(ParticleSphereView())),
        AnimationItem(title: "CubeSwarmView", view: AnyView(CubeSwarmView())),
        AnimationItem(title: "GlassCubeAnimationView", view: AnyView(GlassCubeAnimationView())),
        AnimationItem(title: "NeonCubeView", view: AnyView(NeonCubeView())),
        AnimationItem(title: "NeonWavesOrbView", view: AnyView(NeonWavesOrbView())),
        AnimationItem(title: "HypnoticSphereView", view: AnyView(HypnoticSphereView())),
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
