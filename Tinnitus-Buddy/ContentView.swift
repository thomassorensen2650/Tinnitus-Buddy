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
                PlayButtonView(isPlaying: viewModel.isPlaying, frequency: viewModel.frequency).onTapGesture(perform : { viewModel.playOrStop() } ) .toolbar {
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
                Slider(value: $baseFrequency, in: 1000...9000, step: 1)
                    .accentColor(Color.green)
                Image(systemName: "plus")
            }.foregroundColor(Color.green).padding()
            Text(String(format: "Current tone is at %.0f Hz", baseFrequency))
            Spacer()
            
            PlayButtonView(isPlaying: viewModel.isPlaying,
                           frequency: viewModel.frequency)
        
            Button(action: {
                    viewModel.frequency = baseFrequency
                    viewModel.saveBaseTone(basetone: baseFrequency)}) {
                Label("All Done", systemImage: "checkmark")
            }
        }
    }
}
    
struct PlayButtonView: View  {
    var isPlaying: Bool
    var frequency: Double
    var body: some View {
        VStack() {
        if (isPlaying) {
         
            Image(systemName: "stop")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width / 2,
                       height: UIScreen.main.bounds.width / 2)
        }else {
            Image(systemName: "play")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width / 2,
                       height: UIScreen.main.bounds.width / 2)
        }
           // Spacer()
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
