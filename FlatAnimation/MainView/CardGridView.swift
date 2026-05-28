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
        AnimationItem(title: "Plasma", view: AnyView(MetalAnimationView())),
        AnimationItem(title: "Particles", view: AnyView(Text("Coming soon"))),
        AnimationItem(title: "Waves", view: AnyView(Text("Coming soon")))
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
