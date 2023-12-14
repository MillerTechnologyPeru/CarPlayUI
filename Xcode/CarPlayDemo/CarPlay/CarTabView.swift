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
    
    var body: some View {
        TabView {
            CarInformationView()
            CarGridView()
            CarListView()
        }
    }
}
