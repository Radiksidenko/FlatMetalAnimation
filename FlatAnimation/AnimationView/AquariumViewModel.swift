//
//  AquariumView.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 28.05.2026.
//

import SwiftUI

struct Blob {
    var position: CGPoint
    var velocity: CGPoint
    let radius: Float
}

final class AquariumViewModel: ObservableObject {
    @Published var blobs: [Blob] = []
    let aquariumRadius: Double = 0.85
    private var lastUpdate = Date()
    private var displayLink: CADisplayLink?
    
    init() {
        self.blobs = (0..<6).map { _ in
            Blob(
                position: CGPoint(x: Double.random(in: -0.2...0.2), y: Double.random(in: -0.2...0.2)),
                velocity: CGPoint(x: Double.random(in: -0.6...0.6), y: Double.random(in: -0.6...0.6)),
                radius: Float.random(in: 0.15...0.22)
            )
        }
        setupDisplayLink()
    }
    
    func makeShader(size: CGSize, time: Double) -> Shader {
        let c1 = Color(.sRGB, red: blobs[0].position.x, green: blobs[0].position.y, blue: blobs[1].position.x, opacity: blobs[1].position.y)
        let c2 = Color(.sRGB, red: blobs[2].position.x, green: blobs[2].position.y, blue: blobs[3].position.x, opacity: blobs[3].position.y)
        let c3 = Color(.sRGB, red: blobs[4].position.x, green: blobs[4].position.y, blue: blobs[5].position.x, opacity: blobs[5].position.y)
        
        let r1 = Color(.sRGB, red: Double(blobs[0].radius), green: Double(blobs[1].radius), blue: Double(blobs[2].radius), opacity: Double(blobs[3].radius))
        let r2 = Color(.sRGB, red: Double(blobs[4].radius), green: Double(blobs[5].radius), blue: 0.0, opacity: 0.0)
        
        return ShaderLibrary.liquidAquariumShader(
            .float2(size),
            .float(Float(time * 1.6)),
            .color(c1),
            .color(c2),
            .color(c3),
            .color(r1),
            .color(r2)
        )
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func step() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastUpdate)
        lastUpdate = now
        
        let dt = min(elapsed, 0.04)
        
        for i in 0..<blobs.count {
            var blob = blobs[i]
            
            blob.velocity.x += Double.random(in: -0.3...0.3) * dt
            blob.velocity.y += Double.random(in: -0.3...0.3) * dt
            
            let speed = sqrt(blob.velocity.x * blob.velocity.x + blob.velocity.y * blob.velocity.y)
            if speed > 0.8 {
                blob.velocity.x = (blob.velocity.x / speed) * 0.8
                blob.velocity.y = (blob.velocity.y / speed) * 0.8
            }
            
            blob.position.x += blob.velocity.x * dt
            blob.position.y += blob.velocity.y * dt
            
            let distFromCenter = sqrt(blob.position.x * blob.position.x + blob.position.y * blob.position.y)
            let maxAllowedDist = aquariumRadius - Double(blob.radius * 0.5)
            
            if distFromCenter > maxAllowedDist {
                let nx = blob.position.x / distFromCenter
                let ny = blob.position.y / distFromCenter
                let dotProduct = blob.velocity.x * nx + blob.velocity.y * ny
                
                blob.velocity.x -= 2 * dotProduct * nx
                blob.velocity.y -= 2 * dotProduct * ny
                
                let randomAngle = Double.random(in: -0.5...0.5)
                let sinA = sin(randomAngle)
                let cosA = cos(randomAngle)
                
                let vx = blob.velocity.x
                let vy = blob.velocity.y
                blob.velocity.x = vx * cosA - vy * sinA
                blob.velocity.y = vx * sinA + vy * cosA
                
                blob.position.x = nx * maxAllowedDist
                blob.position.y = ny * maxAllowedDist
            }
            blobs[i] = blob
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
