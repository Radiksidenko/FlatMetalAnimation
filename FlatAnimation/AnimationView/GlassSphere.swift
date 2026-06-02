//
//  GlassSphere.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 02.06.2026.
//

import SwiftUI

struct GlassSphere: View {
    let startDate = Date()
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { context in
                let time = context.date.timeIntervalSince(startDate)
                
                ZStack {
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                        .edgesIgnoringSafeArea(.all)
                    
                    ZStack {
                        
                        Rectangle()
                            .colorEffect(
//                                ShaderLibrary.vectorFireCircleShader(.float2(geo.size), .float(time))
                                ShaderLibrary.liquidMetalShader(
                                    .float(time),
                                    .float2(geo.size)
                                )
                            )
                    }
                    .layerEffect(
                        ShaderLibrary.animatedGlassSphereLayer(
                            .float2(geo.size),
                            .float(time)
                        ),
                        maxSampleOffset: .zero
                    )
                }
            }
        }
    }
}
