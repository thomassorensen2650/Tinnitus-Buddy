//
//  TonePlayer.swift
//  Tinitus Buddy
//
//  Created by Thomas Sorensen on 2/15/21.
//

import Foundation
import AVFoundation

class SingleTonePlayerNode : AVAudioPlayerNode {
    let bufferCapacity: AVAudioFrameCount = 512 * 4
    let sampleRate: Double = 44_100.0
    let amplitude: Double = 0.5 // was 0.25
    
    private var theta: Double = 0.0
    private(set) var audioFormat: AVAudioFormat!
    private var _frequency: Double
    
    var frequency: Double {
        set {
            _frequency = newValue
            print("Set Freq: \(newValue)")
        }
        get {
            print("Set Freq: \(_frequency)")
            return _frequency
        }
    }
    
    override init() {
        self._frequency = Double(1200) //Settings.sharedInstance.getTone())
        super.init()
        audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
    }
    
    func prepareBuffer() -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: bufferCapacity)
        fillBuffer(withData: buffer!)
        return buffer!
    }
    
    func fillBuffer(withData buffer: AVAudioPCMBuffer) {
        let data = buffer.floatChannelData?[0]
        let numberFrames = buffer.frameCapacity
        var theta = self.theta
        let theta_increment = 2.0 * .pi * self.frequency / self.sampleRate
        
        for frame in 0..<Int(numberFrames) {
            data?[frame] = Float32(sin(theta) * amplitude)
            
            theta += theta_increment
            if theta > 2.0 * .pi {
                theta -= 2.0 * .pi
            }
        }
        buffer.frameLength = numberFrames
        self.theta = theta
    }
    
    func scheduleBuffer() {
        let buffer = prepareBuffer()
        self.scheduleBuffer(buffer) {
            if self.isPlaying {
                self.scheduleBuffer()
            }
        }
    }
    
    func preparePlaying() {
        scheduleBuffer()
        scheduleBuffer()
        scheduleBuffer()
        scheduleBuffer()
    }
}
