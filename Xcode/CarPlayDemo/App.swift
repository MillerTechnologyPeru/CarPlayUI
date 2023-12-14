//
//  CarPlayDemoApp.swift
//  CarPlayDemo
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        CarPlayApp.main() // setup CarPlayUI
    }
}
