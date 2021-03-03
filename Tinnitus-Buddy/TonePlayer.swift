//
//  TonePlayer.swift
//  Tinitus Buddy
//
//  Created by Thomas Sorensen on 2/28/21.
//

import Foundation
import AVFoundation

// FIXME : Add support for multi tone.
class TonePlayer {

    let baseTone: SingleTonePlayerNode
    var tone: AVACRNTonePlayerNode
    
    let engine = AVAudioEngine()
    let audioFormat: AVAudioFormat!
    var isPlaying = false
    
    func SetBaseTone(toFrequency frequency : Double) {
            baseTone.frequency = frequency
            tone.InitializeToneSequence(withBaseTone: frequency)
    }
    
    init(sampleRate : Double) {
        audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        baseTone = SingleTonePlayerNode()
        tone = AVACRNTonePlayerNode(withBaseTone: 1400, audioFormat: audioFormat)
        
        engine.attach(tone)
        engine.attach(baseTone)
        
       
        engine.connect(tone, to: engine.mainMixerNode, format: self.audioFormat)
        engine.connect(baseTone, to: engine.mainMixerNode, format: self.audioFormat)
        
        setSession(active: true)
    }

    private func startPlayingInternal() {
        if (!engine.isRunning){
            engine.mainMixerNode.volume = 1.0
            try! engine.start()
            print("starting engine")
        }
        tone.play()
        isPlaying = true
    }
    
    private func stopPlayingInternal() {
        engine.mainMixerNode.volume = 0.0
        tone.pause()
        engine.reset()
        isPlaying = false
    }
    
    private func setSession(active: Bool) {
        #if os(iOS) // HACK to make it work in the simulator
        do {
            try AVAudioSession.sharedInstance().setActive(active)
        } catch {
            // Only print for now
            print("Could not set Audio Session active \(active). error: \(error).")
        }
        #endif
    }
    
    // MARK: - Intents
    func playOrStop() {
        if (isPlaying) {
            stopPlayingInternal()
        } else {
            startPlayingInternal()
        }
    }
}
