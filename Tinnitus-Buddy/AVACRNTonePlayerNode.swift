//
//  AVACRNTonePlayerUnit.swift
//  Tinitus Buddy
//
//  Created by Thomas Sorensen on 2/15/21.
//

import Foundation
import AVFoundation

class AVACRNTonePlayerNode: AVAudioPlayerNode {
    // Mark - Constants
    let bufferCapacity: AVAudioFrameCount = 512 * 4
    let NumberOfTimesToRepeatTones = 4
    let NumberOfToneSequences = 20
    let SilenceTimeBetweenTones = 0.01
    let SilenceTimeBetweenSeqences = 1.4
    let ToneLength = 0.15 // each tone is played for 0.15s
    let useFixedTonePattern = false
  
    
    
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
        for _ in 0..<3 {
            scheduleBuffer()
        }
    }
    
    func InitializeToneSequence(withBaseTone baseFreq : Double) {
        if useFixedTonePattern {
            // FIXME: This tone sequence came from the original post about the approach based on the official app
            // The frequencies spans much wider, need to investigate.. maybe make an option to select???
            generateFixedToneSequence(withBaseTone: baseFreq)
        }
        else {
            // This is the approach from https://github.com/headphonejames/acrn-react
            // Frequencies are much closer to baseTone. Which one is correct??
            generateRandomToneSequence(withBaseTone: baseFreq)
        }
    }
    
    private func generateRandomToneSequence(withBaseTone baseFreq: Double) {
        
        var tones = [floor(baseFreq * 0.773 - 44.5), floor(baseFreq * 0.903 - 21.5),
                     floor(baseFreq * 1.09 + 52), floor(baseFreq * 1.395 + 26.5)];
        let silence = 0.0
        toneList.removeAll()
            
        for _ in 0...NumberOfToneSequences {
            for _ in 0...NumberOfTimesToRepeatTones {
                tones.shuffle()
                toneList.append(contentsOf: tones)
            }
            toneList.append(silence)
        }
    }
    
    private func generateFixedToneSequence(withBaseTone baseFreq: Double) {
        let tones = [baseFreq - 900.0,baseFreq - 400.0,baseFreq + 400.0, baseFreq + 1500.0]
        let silence = 0.0
        
        toneList.removeAll()
        
        // Sequence 2
        for n in [1,2,3,4,4,2,1,3,4,3,2,1] {
            toneList.append(tones[n-1])
        }
        toneList.append(silence)
        
        // Sequence 3
        for n in [2,4,1,3,4,2,1,3,4,3,2,1] {
            toneList.append(tones[n-1])
        }
        toneList.append(silence)
    
        // Sequence 3
        for n in [3,2,4,1,4,2,1,3,1,4,2,2] {
            toneList.append(tones[n-1])
        }
        toneList.append(silence)
        
        // Sequence 4
        for n in [2,3,4,1,1,2,4,3,4,3,2,1] {
            toneList.append(tones[n-1])
        }
        toneList.append(silence)
        
        // Sequence 5
        for n in [1,3,2,4,4,2,3,1,4,1,3,2] {
            toneList.append(tones[n-1])
        }
        toneList.append(silence)
        
        // Sequence 6
        for n in [2,3,4,1,4,1,3,2,2,4,3,1] {
            toneList.append(tones[n-1])
        }
        toneList.append(silence)
        
        // Sequence 7
        for n in [2,3,4,1,3,1,2,4,1,2,4,3] {
            toneList.append(tones[n-1])
        }
        toneList.append(silence)

        // Sequence 8
        for n in [1,2,4,3,4,3,1,2,1,4] {
            toneList.append(tones[n-1])
        }
        toneList.append(silence)
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
            let numberFrames = Int(audioFormat.sampleRate * SilenceTimeBetweenSeqences)
            for _ in 0..<Int(numberFrames) {
                toneBuffer.append(Float(0))
            }
        } else {
            // Duration: 0.15 seconds
            let numberFrames = Int(audioFormat.sampleRate * ToneLength)
          
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
            let numberOfSilenceFrames = Int(audioFormat.sampleRate * SilenceTimeBetweenTones)
            for _ in 0..<Int(numberOfSilenceFrames) {
                toneBuffer.append(Float(0))
            }
        }
    }
}
