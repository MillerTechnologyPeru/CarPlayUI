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
    var date = Date()
    
    @State
    var showButton = false
    
    @State
    var counter = 0
    
    @State
    var rating = 0.5
    
    var body: some CarPlayUI.View {
        Form {
            // Items
            if counter == 0 {
                Text("Use the increment button to increase the counter")
            }
            
            CounterView(counter: counter)
            
            if #available(iOS 15.0, *) {
                DateView(date: date)
            }
            
            Rating(
                title: Text("Rating"),
                rating: rating,
                maximum: 5.0
            )
            
            if counter == 0 {
                FormItem(title: nil, detail: "Detail Text")
                Rating()
            }
            
            // Buttons
            Button("Increment") { increment() }
            
            Button(role: .confirm) {
                reset()
            } label: {
                Text("Reset")
            }
            
            NavigationLink("Next", destination: CarInformationView())
        }
        .navigationTitle("Information")
        .onAppear {
            print("Show Information View")
        }
        .onDisappear {
            print("Information View Disappear")
            reset()
        }
    }
}

internal extension CarInformationView {
    
    struct CounterView: View {
        
        let counter: Int
        
        var body: some View {
            FormItem(
                title: "Counter",
                detail: "\(counter.description)"
            )
        }
    }
    
    struct DateView: View {
        
        let date: Date
        
        init(date: Date = Date()) {
            self.date = date
        }
        
        var body: some View {
            FormItem(
                title: "Date",
                detail: detail
            )
        }
        
        private var detail: String {
            if #available(iOS 15.0, *) {
                return date.formatted()
            } else {
                return "\(date)"
            }
        }
    }
}

private extension CarInformationView {
    
    func reset() {
        print("Reset")
        counter = 0
        rating = 0.5
        date = Date()
    }
    
    func increment() {
        print("Increment")
        counter += 1
        rating = rating == 5.0 ? 0.0 : rating + 0.5
    }
}
