//
//  SoundPlayer.swift
//  SceneKitSpatialAudioStudy
//
//  Created by mio kato on 2021/04/09.
//

import Foundation
import AVFoundation
import SceneKit
import Accelerate


class SoundPlayer {
    
    static var shared = SoundPlayer()
    
    let fileExtension = "mp3"
    var creatureSoundDict = [CreatureType: AVAudioPlayerNode]()
    var creatureFileNameDict: [CreatureType: String] = [
        .Amur: "Amur_loop",
        .Cotsucotsu: "Cotsucotsu_loop",
        .Hyuun: "Hyuun_loop",
    ]
    
    var prevRMSValue: Float = 0.3
    let fftSetup = vDSP_DFT_zop_CreateSetup(nil, 256, vDSP_DFT_Direction.FORWARD)
    var fftMagunitudes = [Float](repeating: 0, count: 128)
    
    var engine: AVAudioEngine?
    var environmentNode: AVAudioEnvironmentNode?
    var mixerNode = AVAudioMixerNode()

    var audioFormat: AVAudioFormat?
    var audioSampleRate: Float = 0.0
    var audioLengthSamples: AVAudioFramePosition = 0
    var audioLengthSeconds: Float = 0.0
    var audioFileUrl: URL? {
        didSet {
            if let audioFileUrl = audioFileUrl {
                audioFile = try? AVAudioFile(forReading: audioFileUrl)
            }
        }
    }
    var audioFile: AVAudioFile? {
        didSet {
            if let audioFile = audioFile {
                audioLengthSamples = audioFile.length
                audioFormat = audioFile.processingFormat
                audioSampleRate = Float(audioFormat?.sampleRate ?? 44100)
                audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
            }
        }
    }
    
    func setUp(engine: AVAudioEngine, environementNode: AVAudioEnvironmentNode) {
        engine.attach(environementNode)
        engine.connect(environementNode, to: engine.mainMixerNode, format: audioFormat)
        engine.prepare()
        self.engine = engine
        self.environmentNode = environementNode
        
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer, time) in
            self.processAudioData(buffer: buffer)
        }
        
        do {
            try engine.start()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func processAudioData(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frames = buffer.frameLength
        
        // rms
        let rmsValue = SignalProcessing.rms(data: channelData, frameLength: UInt(frames))
        let interpolatedResults = SignalProcessing.interpolate(current: rmsValue, previous: prevRMSValue)
        prevRMSValue = rmsValue
        
        // fft
        fftMagunitudes = SignalProcessing.fft(data: channelData, setup: fftSetup!)

    }
    
    func addSound(type: CreatureType) {
        guard let engine = engine,
              let environmentNode = environmentNode,
              let fileName = creatureFileNameDict[type] else { fatalError() }
        let playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        engine.connect(playerNode, to: environmentNode, format: audioFormat)
        
        creatureSoundDict[type] = playerNode
        
        audioFileUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        if let audioFile = audioFile {
            playerNode.scheduleFile(audioFile, at: nil)
        }
    }
    
    
    func play(type: CreatureType) {
        guard let playerNode = creatureSoundDict[type] else { return }
        do {
            try self.engine?.start()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        playerNode.play()
    }
    
    func pause(type: CreatureType) {
        guard let playerNode = creatureSoundDict[type] else { return }
        playerNode.pause()
    }
    
    func stop(type: CreatureType) {
        guard let playerNode = creatureSoundDict[type] else { return }
        playerNode.stop()
    }
}
