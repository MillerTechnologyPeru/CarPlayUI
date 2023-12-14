//
//  CarListView.swift
//  CarPlaySample
//
//  Created by Alsey Coleman Miller on 12/14/23.
//  Copyright © 2023 Watanabe Toshinori. All rights reserved.
//

import Foundation
import CarPlayUI

struct CarListView: CarPlayUI.View {
    
    @State
    var showButton = false
    
    var body: some View {
        List {
            Text("Item 1")
            Text("Item 2")
            Text("Item 3")
        }
    }
}
