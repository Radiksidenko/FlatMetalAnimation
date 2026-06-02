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
    var body: some View {
        TabView {
            AnimationGridView(
                title: "Gallery",
                items: [
                    AnimationItem(title: "PhysicsBalls", view: AnyView(PhysicsBallsView())),
                    AnimationItem(title: "GlassSphere", view: AnyView(GlassSphere())),
                    AnimationItem(title: "HypnoticSphere", view: AnyView(HypnoticSphereView())),
                    AnimationItem(title: "Orb", view: AnyView(OrbAnimationView())),
                    AnimationItem(title: "ParticleSphere", view: AnyView(ParticleSphereView())),
                ]
            )
            .tabItem {
                Label("Sphere", systemImage: "circle.hexagongrid.circle")
            }

            AnimationGridView(
                title: "Gallery",
                items: [
                    AnimationItem(title: "LiquidMetalView", view: AnyView(LiquidMetalView())),
                    AnimationItem(title: "BlackHole", view: AnyView(BlackHoleView())),
                    AnimationItem(title: "GlassCube", view: AnyView(GlassCubeAnimationView())),
                    AnimationItem(title: "CubeSwarm", view: AnyView(CubeSwarmView())),
                    AnimationItem(title: "NeonCube", view: AnyView(NeonCubeView())),
                    AnimationItem(title: "LavaLamp", view: AnyView(LavaLampView())),
                ]
            )
            .tabItem {
                Label("objects", systemImage: "cube.fill")
            }
            
            AnimationGridView(
                title: "Gallery",
                items: [
                    AnimationItem(title: "HexTunnelView", view: AnyView(HexTunnelView())),
                    AnimationItem(title: "NeonTunnelView", view: AnyView(NeonTunnelView())),
                ]
            )
            .tabItem {
                Label("Tunnel", systemImage: "tram.fill.tunnel")
            }
            
            AnimationGridView(
                title: "Gallery",
                items: [
                    AnimationItem(title: "Plasma", view: AnyView(PlasmaView())),
                    AnimationItem(title: "Waves", view: AnyView(WaveView())),
                    AnimationItem(title: "Particles", view: AnyView(ParticleView())),
                    AnimationItem(title: "Particle F", view: AnyView(ParticleFView())),
                    AnimationItem(title: "NeonWaves", view: AnyView(NeonWavesView())),
                    AnimationItem(title: "LiquidLine", view: AnyView(LiquidLineView())),
                ]
            )
            .tabItem {
                Label("Effects", systemImage: "sparkles")
            }
            
            AnimationGridView(
                title: "Gallery",
                items: [
                    AnimationItem(title: "NeonWavesOrb", view: AnyView(NeonWavesOrbView())),
                    AnimationItem(title: "Fire", view: AnyView(FireView())),
                    AnimationItem(title: "Aquarium", view: AnyView(AquariumView())),
                    AnimationItem(title: "PlasmaGlobe", view: AnyView(PlasmaGlobeView())),
                ]
            )
            .tabItem {
                Label("Circle", systemImage: "circle.dotted.circle")
            }
        }
    }
}

struct AnimationGridView: View {
    let title: String
    let items: [AnimationItem]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(destination: item.view) {
                            AnimationCard(title: item.title)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(16)
            }
            .navigationTitle(title)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}
