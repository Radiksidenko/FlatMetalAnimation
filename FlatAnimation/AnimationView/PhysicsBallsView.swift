//
//  PhysicsBallsView.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 02.06.2026.
//

import SwiftUI
import QuartzCore

struct PhysicsBall: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat = 0
    var velocityY: CGFloat = 0
    
    let radius: CGFloat = 50
    let mass: CGFloat = 1.0
    let shaderStartTime = Date()
}

class PhysicsEngine: ObservableObject {
    @Published var balls: [PhysicsBall] = []
    private var displayLink: CADisplayLink?
    
    var screenWidth: CGFloat = 390
    var screenHeight: CGFloat = 844
    
    let gravity: CGFloat = 0.8
    let bounceFriction: CGFloat = 0.7
    
    func start() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(updatePhysics))
            displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func addBall(x: CGFloat, y: CGFloat) {
        let randomVX = CGFloat.random(in: -5...5)
        let newBall = PhysicsBall(x: x, y: y, velocityX: randomVX, velocityY: 0)
        balls.append(newBall)
    }
    
    @objc private func updatePhysics() {
        guard !balls.isEmpty else { return }
        
        for i in 0..<balls.count {
            balls[i].velocityY += gravity
            balls[i].x += balls[i].velocityX
            balls[i].y += balls[i].velocityY
            
            let r = balls[i].radius
            
            if balls[i].y + r > screenHeight {
                balls[i].y = screenHeight - r
                balls[i].velocityY *= -bounceFriction
                balls[i].velocityX *= 0.95
            }
            
            if balls[i].x - r < 0 {
                balls[i].x = r
                balls[i].velocityX *= -bounceFriction
            } else if balls[i].x + r > screenWidth {
                balls[i].x = screenWidth - r
                balls[i].velocityX *= -bounceFriction
            }
        }
        
        for i in 0..<balls.count {
            for j in (i + 1)..<balls.count {
                handleCollision(between: i, and: j)
            }
        }
    }
    
    private func handleCollision(between i: Int, and j: Int) {
        let dx = balls[j].x - balls[i].x
        let dy = balls[j].y - balls[i].y
        let distance = sqrt(dx * dx + dy * dy)
        let minDist = balls[i].radius + balls[j].radius
        
        if distance < minDist {
            let nx = dx / distance
            let ny = dy / distance
            
            let overlap = minDist - distance
            
            balls[i].x -= nx * (overlap * 0.5)
            balls[i].y -= ny * (overlap * 0.5)
            balls[j].x += nx * (overlap * 0.5)
            balls[j].y += ny * (overlap * 0.5)
            
            let relativeVelocityX = balls[j].velocityX - balls[i].velocityX
            let relativeVelocityY = balls[j].velocityY - balls[i].velocityY
            
            let velocityAlongNormal = relativeVelocityX * nx + relativeVelocityY * ny
            
            if velocityAlongNormal > 0 { return }
            
            let restitution: CGFloat = 0.8
            
            let impulse = -(1.0 + restitution) * velocityAlongNormal
            let impulsePerMass = impulse / 2.0
            
            let impulseX = nx * impulsePerMass
            let impulseY = ny * impulsePerMass
            
            balls[i].velocityX -= impulseX
            balls[i].velocityY -= impulseY
            balls[j].velocityX += impulseX
            balls[j].velocityY += impulseY
        }
    }
}

struct PhysicsBallsView: View {
    @StateObject private var engine = PhysicsEngine()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        engine.screenWidth = geo.size.width
                        engine.screenHeight = geo.size.height
                        engine.start()
                    }
                    .onDisappear {
                        engine.stop()
                    }
                
                ForEach(engine.balls) { ball in
                    TimelineView(.animation) { context in
                        let time = context.date.timeIntervalSince(ball.shaderStartTime)
                        
                        ZStack {
                            Rectangle()
                                .colorEffect(
                                    ShaderLibrary.liquidMetalShader(
                                        .float(time),
                                        .float2(geo.size)
                                    )
                                )
                        }
                        .frame(width: ball.radius * 2, height: ball.radius * 2)
                        .layerEffect(
                            ShaderLibrary.animatedGlassSphereLayer(
                                .float2(Float(ball.radius * 2), Float(ball.radius * 2)),
                                .float(time)
                            ),
                            maxSampleOffset: .zero
                        )
                    }
                    .position(x: ball.x, y: ball.y)
                }
                .ignoresSafeArea()
                VStack {
                    Button(action: {
                        let randomX = CGFloat.random(in: 60...(geo.size.width - 60))
                        engine.addBall(x: randomX, y: -60)
                    }) {
                        Text("Drop")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(12)
                    }
                    .padding(.top)
                    Spacer()
                }
            }
        }
    }
}
