//
//  TonePlayerViewModel.swift
//  Tinitus Buddy
//
//  Created by Thomas Sorensen on 2/15/21.
//

import SwiftUI

class TonePlayerViewModel : ObservableObject {
    
    static let baseFrequencyKey = "baseFrequency"
    let tonePayer: TonePlayer
    let sampleRate: Double = 44_100.0
    static let defaultFrequency = 3000.0
    static func getBaseFrequency() -> Double {
            let defaults = UserDefaults.standard
            var baseFrequency = defaults.double(forKey: baseFrequencyKey)
            if baseFrequency == 0.0 {
                baseFrequency = defaultFrequency // Default
            }
            return baseFrequency
    }
    
    private(set) var showFrequencyView = false
    
    var frequency : Double {
        get {
            return TonePlayerViewModel.getBaseFrequency()
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue, forKey: TonePlayerViewModel.baseFrequencyKey)
            tonePayer.SetBaseTone(toFrequency: newValue)
            objectWillChange.send()
        }
    }

    var isPlaying : Bool {
        tonePayer.isPlaying
    }
    
    init() {
        tonePayer = TonePlayer(withBaseTone: TonePlayerViewModel.getBaseFrequency(),
                               sampleRate: sampleRate)
    }

    // MARK: - Intents
    func playOrStop() {
        if (tonePayer.isPlaying) {
            tonePayer.stop()
        }
        else {
            tonePayer.play()
        }
        objectWillChange.send()
    }
    
    func playOrStopBase() {
        if (tonePayer.isPlaying) {
            tonePayer.stopBase()
        }
        else {
            tonePayer.playBase()
        }
        objectWillChange.send()
    }
    
    func changeBaseTone() {
        tonePayer.stop()
        showFrequencyView = true
        objectWillChange.send()
    }
    
    func saveBaseTone(basetone: Double) {
        frequency = basetone
        tonePayer.stopBase()
        showFrequencyView = false
        objectWillChange.send()
    }
}
