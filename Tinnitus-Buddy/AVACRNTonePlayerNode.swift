//
//  AVACRNTonePlayerUnit.swift
//  Tinitus Buddy
//
//  Created by Thomas Sorensen on 2/15/21.
//

import Foundation
import AVFoundation

class AVACRNTonePlayerNode: AVAudioPlayerNode {
    let bufferCapacity: AVAudioFrameCount = 512 * 4
  
    // Contains current Tone being Generated
    // When Empty, then tone should be pop'd from ToneList
    private var toneBuffer = [Float]()
    
    // List of tones
    private var toneList = [Double]()
    
    // Pointer to currently playing tone in toneList
    private(set) var currentToneIndex = 0
    
    // Current Theta (will be updated for each generated sample)
    private var theta: Double = 0.0
    
    private(set) var audioFormat: AVAudioFormat!
    
    init(withBaseTone:Double, audioFormat:AVAudioFormat) {
        super.init()
        self.audioFormat = audioFormat
        InitializeToneSequence(withBaseTone: withBaseTone)
    }
    
    private func prepareBuffer() -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: bufferCapacity)!
        fillBuffer(buffer)
        return buffer
    }
    
    func fillBuffer(_ buffer: AVAudioPCMBuffer) {
        let data = buffer.floatChannelData?[0]
        let numberFrames = buffer.frameCapacity

        for frame in 0..<Int(numberFrames) {
            if (toneBuffer.count == 0) {
                LoadNextToneIntoBuffer()
            }
            data?[frame] = toneBuffer.popLast()!
        }
        buffer.frameLength = numberFrames
    }
        
    func scheduleBuffer() {
        let buffer = prepareBuffer()
        self.scheduleBuffer(buffer) {
            if self.isPlaying {
                self.scheduleBuffer()
            }
        }
    }
    
    override func play() {
        preparePlaying()
        super.play()
    }
    
    private func preparePlaying() {
        scheduleBuffer()
        scheduleBuffer()
        scheduleBuffer()
        scheduleBuffer()
    }
    
    func InitializeToneSequence(withBaseTone baseTone : Double) {
        let tone1 = baseTone - 900.0
        let tone2 = baseTone - 400.0
        let tone3 = baseTone + 400.0
        let tone4 = baseTone + 1500.0
        let silence = 0.0
        
        toneList.removeAll()
        
        //            1-     2-     3-     4-     4-     2 -    1-     3 -    4-     3-     2-     1
        let seq1 = [tone1, tone2, tone3, tone4, tone4, tone2, tone1, tone3, tone4, tone3, tone2, tone1, silence]
        toneList.append(contentsOf: seq1)
        
        //            2-      4-    1-     3     -4-     2-     1-     3-    4-     3-      2-    1
        let seq2 = [tone2, tone4, tone1, tone3, tone4, tone2, tone1, tone3, tone4, tone3, tone2, tone1, silence]
        toneList.append(contentsOf: seq2)
        
        //            3-     2-     4-     1-     4-     2-     1-     3-     1-     4-     2-     2
        let seq3 = [tone3, tone2, tone4, tone1, tone4, tone2, tone1, tone3, tone1, tone4, tone2, tone2, silence]
        toneList.append(contentsOf: seq3)
        
        //             2-     3-     4-    1-     1-     2-     4-     3-     4-     3-     2-     1
        let seq4 = [tone2, tone3, tone4, tone1, tone1, tone2, tone4, tone3, tone4, tone3, tone2, tone1, silence]
        toneList.append(contentsOf: seq4)
        
        //           1-      3-     2-     4-     4-     2-     3-     1-     4-     1-    3-      2
        let seq5 = [tone1, tone3, tone2, tone4, tone4, tone2, tone3, tone1, tone4, tone1, tone3, tone2, silence]
        toneList.append(contentsOf: seq5)
        
        //           2-      3-     4-     1-     4-     1-     3-     2-     2-     4-     3-     1
        let seq6 = [tone2, tone3, tone4, tone1, tone4, tone1, tone3, tone2, tone2, tone4, tone3, tone1, silence]
        toneList.append(contentsOf: seq6)
        
        //           2-      3-     4-     1-     3-     1-     2-     4-     1-     2-     4-     3
        let seq7 = [tone2, tone3, tone4, tone1, tone3, tone1, tone2, tone4, tone1, tone2, tone4, tone3, silence]
        toneList.append(contentsOf: seq7)
        
        //            1-      2-     4-    3-     4-     3-     1-     2-     1-     4-    2 -      3
        let seq8 = [tone1, tone2, tone4, tone3, tone4, tone3, tone1, tone2, tone1, tone4, tone2, tone3, silence]
        toneList.append(contentsOf: seq8)
    }
    
    func LoadNextToneIntoBuffer() {
        if currentToneIndex == toneList.count-1 {
            currentToneIndex = 0
        } else {
            currentToneIndex += 1
        }
        GenerateToneData(toneFreq: toneList[currentToneIndex])
    }
    
    func GenerateToneData(toneFreq : Double) {
        // Amplitude: I did 0.5 (closest match to the sample)
        
        // 0.07 Fade in, 0.07 Fade out
        // 12 tones then 1.4 second silence
        // silense is 0 frequency in the array
        if (toneFreq == 0) { // Silence
            // After 12 tones we need to generate silent frames
            // We need to generate 1.4 seconds of Silence
            let numberFrames = Int(audioFormat.sampleRate * 1.4)
            for _ in 0..<Int(numberFrames) {
                toneBuffer.append(Float(0))
            }
        } else {
            // Duration: 0.15 seconds
            let numberFrames = Int(audioFormat.sampleRate * 0.15)
          
            // How much tone change in tone wave value over each sample
            let theta_increment = 2.0 * .pi * toneFreq / audioFormat.sampleRate
            
            // Calculate fadein/fadeout
            let maxAmplitude = 0.5
            let amplitudeFadeOut = Int(numberFrames / 2)
            let amplitudeChange = maxAmplitude / Double(amplitudeFadeOut)
            var frameAplitude = 0.0
            
            for frame in 0..<Int(numberFrames) {
                if (frame < amplitudeFadeOut) {
                    frameAplitude += amplitudeChange // Fade in
                } else {
                    frameAplitude -= amplitudeChange // Fade out
                }
                toneBuffer.append(Float(sin(theta) * frameAplitude))
                
                theta += theta_increment
                if theta > 2.0 * .pi {
                    theta -= 2.0 * .pi
                }
            }
            
            // make 0.01 seconds silence after each tone
            let numberOfSilenceFrames = Int(audioFormat.sampleRate * 0.01)
            for _ in 0..<Int(numberOfSilenceFrames) {
                toneBuffer.append(Float(0))
            }
        }
    }
}
