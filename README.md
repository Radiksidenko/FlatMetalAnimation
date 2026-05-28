# FlatAnimation

A high-performance iOS gallery of fluid, procedural animations and visual effects powered by **SwiftUI** and **Metal Shading Language (MSL)**.
  
https://github.com/user-attachments/assets/8b28b54c-f9b2-4248-8935-778a297dd138  

## Summary

**FlatAnimation** is an iOS demo app showcasing complex visual effects created using the GPU. Instead of traditional frame-by-frame animations, large video files, or web wrappers, the project is entirely based on **procedural math (SDF, fractal noise, plasma algorithms)**, calculated in real time on the device's GPU.

The gallery contains 10 different 2D and 3D animations.

## How It Works

### 1. The Animation Engine (`ShaderContainerView.swift`)
At the core of the rendering loop is the `ShaderContainerView`. It bridges SwiftUI and Metal using two key components:
* **`TimelineView(.animation)`**: Generates a continuous frame update stream driven by the display’s maximum refresh rate (60Hz / 120Hz ProMotion), passing the precise elapsed `time` to the shader.
* **`.visualEffect` and `.colorEffect` Modifiers**: Leveraging SwiftUI APIs (iOS 17+), the app applies Metal shaders directly to a standard SwiftUI view bounding box (`Rectangle`). It dynamically feeds the geometry size and timeline data straight into the GPU pipeline.

### 2. GPU Mathematics (`.metal` Shaders)
Every pixel is drawn in parallel via `[[ stitchable ]]` MSL functions. The project showcases two primary shader techniques:
* **2D Procedural Effects (*Plasma*, *Waves*, *Fire*):** These compute color coordinates using trigonometric oscillations (`sin`, `cos`) mixed with value noise functions to simulate fluid, organic elements like flames and water.
* **3D Raymarching (*AbstractOrbShader*):** The shader defines a virtual camera view ray (`ro`, `rd`) and utilizes Signed Distance Fields (SDF). It performs raymarching to "probe" a 3D space, handles rotational matrices over time, and renders a complex twisted sphere mapped to a dynamic rainbow spectrum.

### 3. CPU Physics to GPU Pipeline (`AquariumViewModel.swift`)
The project demonstrates how to feed real-time CPU simulation data directly into fragment shaders:
* In the `AquariumViewModel`, a `CADisplayLink` loop computes a 2D physics simulation for 6 floating autonomous entities (`Blobs`). It calculates randomized velocity drift, speed clamping, and elastic boundary collisions inside a circular tank.
* Instead of heavy buffer setups, the positions and radii of these particles are packed into standard SwiftUI `Color` structures (acting as `float4` vector containers) and passed right into the `liquidAquariumShader`, which blends them into smooth, organic metaballs.
