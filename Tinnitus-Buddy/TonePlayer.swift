//
//  TonePlayer.swift
//  Tinitus Buddy
//
//  Created by Thomas Sorensen on 2/28/21.
//

import Foundation
import AVFoundation

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
    
    init(withBaseTone:Double, sampleRate : Double) {
        audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        baseTone = SingleTonePlayerNode(withBaseTone: withBaseTone, audioFormat: audioFormat)
        tone = AVACRNTonePlayerNode(withBaseTone: withBaseTone, audioFormat: audioFormat)
        
        engine.attach(tone)
        engine.attach(baseTone)
        
        engine.connect(tone, to: engine.mainMixerNode, format: self.audioFormat)
        engine.connect(baseTone, to: engine.mainMixerNode, format: self.audioFormat)
        
        setSession(active: true)
    }

    private func startPlayingInternal(tone : AVAudioPlayerNode) {
        if (!engine.isRunning){
            engine.mainMixerNode.volume = 1.0
            try! engine.start()
            print("starting engine")
        }
        tone.play()
        isPlaying = true
    }
    
    private func stopPlayingInternal(tone : AVAudioPlayerNode) {
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
    func playBase() { startPlayingInternal(tone: baseTone) }
    func stopBase() { stopPlayingInternal(tone: baseTone) }
    func play() { startPlayingInternal(tone: tone) }
    func stop() { stopPlayingInternal(tone: tone) }
}
