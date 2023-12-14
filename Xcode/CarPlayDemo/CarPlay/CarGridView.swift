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
    
    @State
    var showButton = false
    
    @State
    var counter = 0
    
    var body: some CarPlayUI.View {
        Grid {
            Button {
                showButton.toggle()
            } label: {
                Text("Toggle")
                Image(systemName: "figure.walk.circle")
            }
                        
            if showButton {
                
                Button {
                    counter += 1
                } label: {
                    Text("\(counter.description)")
                    Image(systemName: "plus.app.fill")
                }
                
                Button {
                    showButton.toggle()
                } label: {
                    Text("Toggle")
                    Image(systemName: "figure.walk.circle")
                }
            }
        }
        .navigationTitle("Grid")
    }
}
