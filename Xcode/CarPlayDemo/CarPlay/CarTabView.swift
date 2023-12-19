//
//  CarTabView.swift
//  CarPlaySample
//
//  Created by Alsey Coleman Miller on 12/14/23.
//  Copyright © 2023 Watanabe Toshinori. All rights reserved.
//

import Foundation
import CarPlayUI

struct CarTabView: View {
    
    @State
    var selection: Int?
    
    var body: some View {
        NavigationView {
            if #available(iOS 17, *) {
                TabView(selection: $selection) {
                    tabs
                }
                .onAppear {
                    print("Tab View Appeared")
                }
            } else {
                TabView {
                    tabs
                }
            }
        }
    }
    
    @ViewBuilder
    var tabs: some View {
        CarListView()
        CarPointsOfInterestView()
        CarInformationView()
    }
}
