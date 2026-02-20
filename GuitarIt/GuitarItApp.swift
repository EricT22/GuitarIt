//
//  GuitarItApp.swift
//  GuitarIt
//
//  Created by Eric Tuesta on 2/1/26.
//

import SwiftUI

@main
struct GuitarItApp: App {
    let audio = AudioCapture()
    
    init() {
        try? audio.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
