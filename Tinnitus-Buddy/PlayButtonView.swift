//
//  PlayButtonView.swift
//  Tinnitus-Buddy
//
//  Created by Thomas Sorensen on 3/3/21.
//

import SwiftUI

struct PlayButtonView: View  {
    var isPlaying: Bool
    var frequency: Double
    var body: some View {
        VStack() {
            if (isPlaying) {
                Image(systemName: "stop").resizable()
            }else {
                Image(systemName: "play").resizable()
            }
        }.padding()
         .frame(width: UIScreen.main.bounds.width / 2,
                height: UIScreen.main.bounds.width / 2)
        .aspectRatio(contentMode: .fit)
    }
}
