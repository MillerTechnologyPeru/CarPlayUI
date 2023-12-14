//
//  CarInformationView.swift
//  CarPlaySample
//
//  Created by Alsey Coleman Miller on 12/14/23.
//  Copyright © 2023 Watanabe Toshinori. All rights reserved.
//

import Foundation
import CarPlayUI

struct CarInformationView: CarPlayUI.View {
    
    @State
    var showButton = false
    
    @State
    var counter = 0
    
    @State
    var rating = 0.5
    
    var body: some CarPlayUI.View {
        Form {
            // Items
            HStack {
                Text("Counter")
                Text("\(counter.description)")
            }
            
            if #available(iOS 15.0, *) {
                HStack {
                    Text("Date")
                    Text("\(Date().formatted().description)")
                }
            }
            
            HStack {
                Text("Rating")
                Rating(rating: rating, maximum: 5.0)
            }
            
            Text("Single Line")
            
            Rating()
            
            // Buttons
            Button {
                increment()
            } label: {
                Text("Increment")
            }
            
            if counter > 0 {
                Button(role: .confirm) {
                    reset()
                } label: {
                    Text("Reset")
                }
            }
            
            NavigationLink("Next", destination: CarInformationView())
        }
        .navigationTitle("Information")
        .onAppear {
            print("Show Information View")
        }
        .onDisappear {
            reset()
        }
    }
}

private extension CarInformationView {
    
    func reset() {
        print("Reset")
        counter = 0
        rating = 0.5
    }
    
    func increment() {
        print("Increment")
        counter += 1
        rating = rating == 5.0 ? 0.0 : rating + 0.5
    }
}
