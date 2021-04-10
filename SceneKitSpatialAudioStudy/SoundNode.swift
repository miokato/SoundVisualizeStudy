//
//  SoundNode.swift
//  SceneKitSpatialAudioStudy
//
//  Created by mio kato on 2021/04/09.
//

import Foundation
import SceneKit
import AVFoundation

class SoundNode: SCNNode {
    var playerNode: AVAudioPlayerNode?
    
    func addSound(type: CreatureType) {
        SoundPlayer.shared.addSound(type: type)
        guard let playerNode = SoundPlayer.shared.creatureSoundDict[type] else { fatalError() }
        let audioPlayer = SCNAudioPlayer(avAudioNode: playerNode)
        addAudioPlayer(audioPlayer)
        self.playerNode = playerNode
    }
    
    func play() {
        playerNode?.play()
    }
}
