//
//  VisualizerView.swift
//  SceneKitSpatialAudioStudy
//
//  Created by mio kato on 2021/04/10.
//

import UIKit
import MetalKit

class VisualizerViewController: UIViewController, MTKViewDelegate {
          
    @IBOutlet weak var mtkView: MTKView!
    
    private let vertexData: [Float] = [
        -1, -1, 0, 1,
        1, -1, 0, 1,
        -1, 1, 0, 1,
        1, 1, 0, 1
    ]
    private var vertexBuffer: MTLBuffer!
    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    private var renderPipeline: MTLRenderPipelineState!
    
    var value: Float = 0.5
    var sinValue: Float = 0.0
    var sinTime: Float = 0.0
    var counter: Int = 0
    var count = SoundPlayer.shared.fftMagunitudes.count
    var resolution: simd_float2 = SIMD2<Float>(Float(UIScreen.main.nativeBounds.size.width),
                                               80)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mtkView.delegate = self
        mtkView.device = device
        
        commandQueue = device.makeCommandQueue()
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "soundVertexShader")
        let fragmentFunction = library?.makeFunction(name: "soundFragmentShader")
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        renderPipeline = try! device.makeRenderPipelineState(descriptor: descriptor)
            
        let size = vertexData.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: size)
        

    }
    
    func draw(in view: MTKView) {
        guard let drawable = mtkView.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        print(SoundPlayer.shared.fftMagunitudes)
        value = 10.0
        
        counter = (counter + 1) % 180
        sinTime = sin(Float(counter / 180) * Float.pi)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(renderPipeline)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentBytes(&SoundPlayer.shared.fftMagunitudes, length: MemoryLayout<Float>.stride * 128, index: 0)
        renderEncoder?.setFragmentBytes(&count, length: MemoryLayout<Int>.stride, index: 1)
        renderEncoder?.setFragmentBytes(&sinTime, length: MemoryLayout<Float>.stride, index: 2)
        renderEncoder?.setFragmentBytes(&resolution, length: MemoryLayout<SIMD2<Float>>.stride, index: 3)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder?.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
      
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
}
