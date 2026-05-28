//
//  ShaderContainerView.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

import SwiftUI

struct ShaderContainerView: View {
    let startTime = Date()
    let shaderProvider: (CGSize, Float) -> Shader

    var body: some View {
        TimelineView(.animation) { context in
            let time = Float(startTime.distance(to: context.date))
            
            Rectangle()
                .visualEffect { content, geometryProxy in
                    content
                        .colorEffect(
                            shaderProvider(geometryProxy.size, time)
                        )
                }
                .ignoresSafeArea()
        }
    }
}
