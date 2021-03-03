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
    static func getBaseFrequency() -> Double {
            let defaults = UserDefaults.standard
            var baseFrequency = defaults.double(forKey: baseFrequencyKey)
            if baseFrequency == 0.0 {
                baseFrequency = 3000.0 // Default
            }
            return baseFrequency
    }
    
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
    
    private(set) var showFrequencyView = false
    
    var isPlaying : Bool {
        tonePayer.isPlaying
    }
    
    init() {
        tonePayer = TonePlayer(sampleRate: sampleRate)
    }

    // MARK: - Intents
    func playOrStop() {
        tonePayer.playOrStop()
        print("Play :\(tonePayer.isPlaying)")
        objectWillChange.send()
    }
    
    func changeBaseTone() {
        showFrequencyView = true
        objectWillChange.send()
    }
    
    func saveBaseTone(basetone: Double) {
        showFrequencyView = false
        objectWillChange.send()
    }
}
