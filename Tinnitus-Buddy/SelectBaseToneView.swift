//
//  SelectBaseToneView.swift
//  Tinnitus-Buddy
//
//  Created by Thomas Sorensen on 3/3/21.
//

import SwiftUI

struct SelectBaseToneView: View {
    @ObservedObject var viewModel: TonePlayerViewModel
    @State var baseFrequency : Double
    
    init(viewModel : TonePlayerViewModel) {
        self.viewModel = viewModel
        self._baseFrequency = State(initialValue: viewModel.frequency)
    }
    
    var body: some View {
        VStack {
            Text("Select Basetone")
            .font(.largeTitle)
            .fontWeight(.heavy)
            
            Text("""
1. Turn the volumen all the way down
2. Press the Play Button
3. Slowly turn up the volume until you can hear the tone
4. Adjust the tone until it matches your tone
""").multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/).padding()

            HStack {
                Image(systemName: "minus")
                Slider(value: Binding(
                       get: {
                            self.baseFrequency
                       },
                       set: { (newValue) in
                            self.baseFrequency = newValue
                            self.viewModel.frequency = newValue
                       }
                ), in: 1000...9000, step: 0.2)
                Image(systemName: "plus")
            }.padding()
            Text(String(format: "Current tone is at %.1f Hz", baseFrequency))
            Spacer()
            
            PlayButtonView(isPlaying: viewModel.isPlaying,
                           frequency: viewModel.frequency).onTapGesture(perform : { viewModel.playOrStopBase() } )
        
            Button(action: {
                    viewModel.saveBaseTone(basetone: baseFrequency)}) {
                        Label("All Done", systemImage: "checkmark")
            }
        }
    }
}
