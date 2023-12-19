//
//  CarGridView.swift
//  CarPlaySample
//
//  Created by Alsey Coleman Miller on 12/12/23.
//  Copyright © 2023 Watanabe Toshinori. All rights reserved.
//

import Foundation
import CarPlayUI

struct CarGridView: CarPlayUI.View {
    
    let forceStatic: Bool
    
    @State
    var showButton = false
    
    @State
    var counter = 0
    
    init(forceStatic: Bool = false) {
        self.forceStatic = forceStatic
    }
    
    var body: some CarPlayUI.View {
        Grid(forceStatic: forceStatic) {
            
            Button {
                printAction(1)
            } label: {
                Text("Button")
                Image(systemName: "car")
            }
            
            Button {
                printAction(2)
            } label: {
                Label("Button 2", systemImage: "car.2")
            }
            
            Button {
                toggle()
            } label: {
                Label("Toggle", systemImage: showButton ? "headlight.high.beam" : "headlight.low.beam")
            }
            
            CounterButton()
            
            NavigationLink(destination: CarGridView(forceStatic: true), label: {
                Text("Next")
                Image(systemName: "arrow.forward.circle")
            })
            
            if showButton {
                Button {
                    toggle()
                } label: {
                    Text("Toggle")
                    Image(systemName: "figure.walk.circle")
                }
            }
        }
        .navigationTitle(forceStatic ? "Static Grid": "Grid")
        .onAppear {
            print("Show Grid View")
        }
        .onDisappear {
            print("Grid View Disappear")
        }
    }
}

private extension CarGridView {
    
    func printAction(_ button: Int) {
        print("Tapped button \(button)")
    }
    
    func toggle() {
        guard forceStatic == false else { return }
        showButton.toggle()
    }
    
    func incrementCounter() {
        guard forceStatic == false else { return }
        counter += 1
    }
}

extension CarGridView {
    
    struct CounterButton: View {
        
        @State
        var counter = 0
        
        var body: some View {
            Button {
                counter += 1
            } label: {
                Label(
                    "\(counter.description)",
                    systemImage: "plus.app.fill"
                )
            }
        }
    }
}
