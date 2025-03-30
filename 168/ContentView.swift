//
//  ContentView.swift
//  Nexus
//
//  Created by Corwin Cheung on 3/29/25.
//

import SwiftUI

enum Tasks: String, CaseIterable {
    case Coding, Research, Fitness, Reading
}

struct ContentView: View {
    @State var selection: Tasks = .Coding
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("What are you going to do today")
                        .font(.system(size: 40))
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 50) // adjust as needed
                    Spacer()
                }
                VStack(spacing: 40) {
                    Text(selection.rawValue)
                        .font(.system(size: 100, weight: .regular))
                    
                    Picker("Select Task", selection: $selection) {
                        ForEach(Tasks.allCases, id: \.self) { task in
                            Text(task.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
