//
//  ParticleMetalView.swift
//  FlatAnimation
//
//  Created by Radomyr Sidenko on 01.06.2026.
//

import SwiftUI
import MetalKit

struct BlackHoleView: View {
    var body: some View {
        MetalParticleRenderer()
            .ignoresSafeArea()
    }
}

struct MetalParticleRenderer: UIViewRepresentable {
    typealias UIViewType = MTKView
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = context.coordinator
        mtkView.backgroundColor = .black
        mtkView.preferredFramesPerSecond = 60
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var commandQueue: MTLCommandQueue?
        var computePipelineState: MTLComputePipelineState?
        var renderPipelineState: MTLRenderPipelineState?
        
        var particleBuffer: MTLBuffer?
        let particleCount = 300_000
        let startTime = Date()
        
        struct Particle {
            var position: SIMD3<Float>
            var velocity: SIMD3<Float>
            var color: SIMD4<Float>
            var life: Float
        }
        
        override init() {
            super.init()
            guard let device = MTLCreateSystemDefaultDevice(),
                  let library = device.makeDefaultLibrary() else { return }
            
            self.commandQueue = device.makeCommandQueue()
            
            if let computeFunc = library.makeFunction(name: "computeParticle") {
                self.computePipelineState = try? device.makeComputePipelineState(function: computeFunc)
            }
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexParticle")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentParticle")
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .one
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
            
            self.renderPipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            
            var rawParticles = [Particle]()
            let screenSize = UIScreen.main.bounds.size
            let scale = UIScreen.main.scale
            let width = Float(screenSize.width * scale)
            let height = Float(screenSize.height * scale)
            let center = SIMD3<Float>(width * 0.5, height * 0.5, 0.0)
            
            for i in 0..<particleCount {
                let randVal = Float.random(in: 0...1)
                let eventHorizon: Float = 50.0
                let radius = eventHorizon + 10.0 + (pow(randVal, 3.0) * 490.0)
                
                let spiralTwist: Float = 5.5
                var angle = Float.random(in: 0...(Float.pi * 2))
                let track = Float(Int.random(in: 0...24)) / 24.0
                angle += (radius * 0.012 * spiralTwist) + track * 0.5
                
                let posX = center.x + cos(angle) * radius
                let posY = center.y + sin(angle) * radius
                let posZ = Float.random(in: -6...6)
                
                let orbitalSpeed = 150.0 * (1.0 / sqrt(radius + 1.0))
                let tangentX = -sin(angle)
                let tangentY = cos(angle)
                
                let vel = SIMD3<Float>(tangentX * orbitalSpeed * 22.0, tangentY * orbitalSpeed * 22.0, 0.0)
                let col = SIMD4<Float>(0, 0, 0, 0)
                let life = Float.random(in: 0.1...1.0)
                
                rawParticles.append(Particle(position: SIMD3<Float>(posX, posY, posZ), velocity: vel, color: col, life: life))
            }
            
            let bufferSize = particleCount * MemoryLayout<Particle>.stride
            self.particleBuffer = device.makeBuffer(bytes: rawParticles, length: bufferSize, options: .storageModeShared)
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let computeState = self.computePipelineState,
                  let renderState = self.renderPipelineState,
                  let commandQueue = self.commandQueue,
                  let pBuffer = self.particleBuffer else { return }
            
            let commandBuffer = commandQueue.makeCommandBuffer()
            
            let computeEncoder = commandBuffer?.makeComputeCommandEncoder()
            computeEncoder?.setComputePipelineState(computeState)
            computeEncoder?.setBuffer(pBuffer, offset: 0, index: 0)
            
            var resolution = float2(Float(view.drawableSize.width), Float(view.drawableSize.height))
            computeEncoder?.setBytes(&resolution, length: MemoryLayout<float2>.stride, index: 1)
            
            var time = Float(Date().timeIntervalSince(startTime))
            computeEncoder?.setBytes(&time, length: MemoryLayout<Float>.stride, index: 2)
            
            let threadExecutionWidth = computeState.threadExecutionWidth
            let threadsPerGroup = MTLSize(width: threadExecutionWidth, height: 1, depth: 1)
            let groupCount = (particleCount + threadExecutionWidth - 1) / threadExecutionWidth
            let threadgroupsPerGrid = MTLSize(width: groupCount, height: 1, depth: 1)
            
            computeEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerGroup)
            computeEncoder?.endEncoding()
            
            let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder?.setRenderPipelineState(renderState)
            
            renderEncoder?.setVertexBuffer(pBuffer, offset: 0, index: 0)
            renderEncoder?.setVertexBytes(&resolution, length: MemoryLayout<float2>.stride, index: 1)
            renderEncoder?.setVertexBytes(&time, length: MemoryLayout<Float>.stride, index: 2)
            
            renderEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: particleCount)
            renderEncoder?.endEncoding()
            
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
}
