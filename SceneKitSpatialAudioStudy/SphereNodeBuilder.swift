//
//  SphereNodeBuilder.swift
//  SceneKitSpatialAudioStudy
//
//  Created by mio kato on 2021/04/09.
//

import SceneKit

class SphereNodeBuilder {
    static func create(worldPosition: SIMD3<Float>, color: UIColor) -> SoundNode {
        let node = SoundNode()
        let geometry = SCNSphere(radius: 0.05)
        geometry.firstMaterial?.diffuse.contents = color
        node.geometry = geometry
        node.simdWorldPosition = worldPosition
        return node
    }
}

