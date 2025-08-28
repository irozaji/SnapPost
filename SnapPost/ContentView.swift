//
//  ContentView.swift
//  SnapPost
//
//  Created by Ilzat Rozaji on 8/27/25.
//

import SwiftUI

struct ContentView: View {
    
        
    var a:Int = 1;
    

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hi Ilzat" + String(a))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
