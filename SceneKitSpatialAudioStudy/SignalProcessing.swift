//
//  SignalProcessing.swift
//  SceneKitSpatialAudioStudy
//
//  Created by mio kato on 2021/04/10.
//

import Foundation
import Accelerate

class SignalProcessing {
        
    static func rms(data: UnsafeMutablePointer<Float>, frameLength: UInt) -> Float {
        var val: Float = 0
        vDSP_measqv(data, 1, &val, frameLength)
        var db = 10 * log10(val)
        db = 160 + db
        db = db - 120
        let dividor = Float(40 / 0.3)
        var adjustVal = 0.3 + db / dividor
        
        // cutoff
        if adjustVal < 0.3 {
            adjustVal = 0.3
        } else if adjustVal > 0.6 {
            adjustVal = 0.6
        }
        return adjustVal
    }
    
    static func interpolate(current: Float, previous: Float) -> [Float]{
        var vals = [Float](repeating: 0, count: 11)
        vals[10] = current
        vals[5] = (current + previous)/2
        vals[2] = (vals[5] + previous)/2
        vals[1] = (vals[2] + previous)/2
        vals[8] = (vals[5] + current)/2
        vals[9] = (vals[10] + current)/2
        vals[7] = (vals[5] + vals[9])/2
        vals[6] = (vals[5] + vals[7])/2
        vals[3] = (vals[1] + vals[5])/2
        vals[4] = (vals[3] + vals[5])/2
        vals[0] = (previous + vals[1])/2

        return vals
    }
    
    static func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        var realIn = [Float](repeating: 0, count: 256)
        var imagIn = [Float](repeating: 0, count: 256)
        var realOut = [Float](repeating: 0, count: 256)
        var imagOut = [Float](repeating: 0, count: 256)
        
        for i in 0...255 {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        
        var complex = DSPSplitComplex(realp: &realOut, imagp: &imagOut)
                
        // 大きさを計算
        var magnitudes = [Float](repeating: 0, count: 128)
        vDSP_zvabs(&complex, 1, &magnitudes, 1, 128)
        
        // 正規化
        var normalizedMagnitudes = [Float](repeating: 0.0, count: 128)
        var scalingFactor = Float(12.5/128)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, 128)
    
        return normalizedMagnitudes
    }

    
}


