//
//  AnimationCard.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

import SwiftUI

struct AnimationCard: View {
    let title: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
        }
        .frame(height: 180)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}
