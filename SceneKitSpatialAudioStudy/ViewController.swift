//
//  ViewController.swift
//  SceneKitSpatialAudioStudy
//
//  Created by mio kato on 2021/04/09.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var worldNode = SCNNode()
    
    let creatureTypes: [CreatureType] = [.Amur, .Cotsucotsu, .Hyuun]
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
            
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
                
        let scene = SCNScene()
                
        sceneView.scene = scene
        
        scene.rootNode.addChildNode(worldNode)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        SoundPlayer.shared.setUp(engine: sceneView.audioEngine,
                                 environementNode: sceneView.audioEnvironmentNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        let configuration = ARWorldTrackingConfiguration()
        
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - Gesture
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        print("tap")
        let location = gesture.location(in: sceneView)
        guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .horizontal),
              let hitResult = sceneView.session.raycast(query).first else { return }
        let worldPosition = hitResult.worldTransform.translation
        
        let node = SphereNodeBuilder.create(worldPosition: worldPosition, color: .red)
        worldNode.addChildNode(node)
        let nextCreature = creatureTypes[index]
        node.addSound(type: nextCreature)
        node.play()
        
        index = (index + 1) % creatureTypes.count
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    }
}

extension simd_float4x4 {
    var translation: simd_float3 {
        [columns.3.x, columns.3.y, columns.3.z]
    }
}
