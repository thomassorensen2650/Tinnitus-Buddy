//
//  ContentView.swift
//  Tinitus Buddy
//
//  Created by Thomas Sorensen on 2/15/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = TonePlayerViewModel()
        
    var body: some View {
        if viewModel.showFrequencyView == false {
           MainToneView(viewModel: viewModel)
        }
        else {
            SelectBaseToneView(viewModel: viewModel)
        }
    }
}

struct MainToneView: View {
    @ObservedObject var viewModel: TonePlayerViewModel
    
    var body : some View {
        NavigationView {
            VStack {
                Text(String(format: "Modulating around %.0f Hz", viewModel.frequency))
                PlayButtonView(isPlaying: viewModel.isPlaying,
                               frequency: viewModel.frequency).onTapGesture(perform : { viewModel.playOrStop() } )
                    .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button(action: { viewModel.changeBaseTone()}) {
                                Label("Change Base Tone", systemImage: "waveform.path.ecg")
                            }
                        }
                        label: {
                            Label("Settings", systemImage: "pencil")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
