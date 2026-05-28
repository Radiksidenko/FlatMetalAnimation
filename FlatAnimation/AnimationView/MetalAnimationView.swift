//
//  MetalAnimationView.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

import SwiftUI

struct MetalAnimationView: View {
    let startTime = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = startTime.distance(to: context.date)
            
            Rectangle()
                .visualEffect { content, geometryProxy in
                    content
                        .colorEffect(
                            ShaderLibrary.plasmaShader(
                                .float2(geometryProxy.size),
                                .float(time)
                            )
                        )
                }
        }
    }
}
