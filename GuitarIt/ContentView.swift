//
//  ContentView.swift
//  GuitarIt
//
//  Created by Eric Tuesta on 2/1/26.
//

import SwiftUI

// Main ContentView with tab navigation and swipe support
struct ContentView: View {
    // Tracks the selected tab index
    @State private var selectedTab = 0
    // For swipe gesture detection
    @GestureState private var dragOffset: CGFloat = 0
    
    // All tab views in order
    private let tabViews: [AnyView] = [
        AnyView(TunerView()),
        AnyView(MetronomeView()),
        AnyView(BackingTrackGeneratorView()),
        AnyView(TabWriterView())
    ]
    // SF Symbols for each tab
    private let tabIcons = [
        "tuningfork", // Tuner
        "metronome", // Metronome
        "music.note.list", // BackingTrackGenerator
        "pencil.and.outline" // TabWriter
    ]
    
    var body: some View {
        // TabView with custom icons and swipe gesture
        TabView(selection: $selectedTab) {
            ForEach(0..<tabViews.count, id: \.self) { index in
                tabViews[index]
                    .tag(index)
                    .tabItem {
                        Image(systemName: tabIcons[index])
                    }
            }
        }
        // Enables horizontal swipe to switch tabs
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold && selectedTab < tabViews.count - 1 {
                        selectedTab += 1
                    } else if value.translation.width > threshold && selectedTab > 0 {
                        selectedTab -= 1
                    }
                }
        )
    }
}

#Preview {
    ContentView()
}
