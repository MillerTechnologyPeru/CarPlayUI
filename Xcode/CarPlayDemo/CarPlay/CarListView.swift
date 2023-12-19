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
    var rowToggle = false
    
    @State
    var count = 3
    
    var body: some View {
        List {
            Section(header: "Section 1", data: [
                ListItem(
                    text: "Row 1",
                    detailText: "Detail",
                    image: Image(systemName: rowToggle ? "car" : "car.fill"),
                    accessory: .image(Image(systemName: rowToggle ? "car.front.waves.down" : "car.front.waves.up"))) {
                    print("Tapped row 1")
                    if #available(iOS 16.0, *) {
                        try? await Task.sleep(for: .seconds(1))
                    }
                    await toggle()
                },
                ListItem(text: "Row 2") {
                    print("Tapped row 2")
                    await increment()
                    if #available(iOS 16.0, *) {
                        try? await Task.sleep(for: .seconds(2))
                    }
                    await toggle()
                },
                ListItem(
                    text: "Information",
                    image: Image(systemName: "list.bullet.rectangle.fill"),
                    accessory: .disclosureIndicator,
                    destination: CarInformationView()
                ),
                ListItem(
                    text: "Grid",
                    image: Image(systemName: "circle.grid.2x2.fill"),
                    accessory: .disclosureIndicator,
                    destination: CarGridView()
                ),
                ListItem(
                    text: "Map",
                    image: Image(systemName: "mappin"),
                    accessory: .disclosureIndicator,
                    destination: CarPointsOfInterestView()
                ),
                ListItem(
                    text: "List",
                    image: Image(systemName: "list.bullet.rectangle"),
                    accessory: .disclosureIndicator,
                    destination: CarListView()
                )
            ])
            Section(header: "Section 2", data: (1 ... count).map { ListItem(text: "Row \($0)") })
        }
        .navigationTitle("List")
        .onAppear {
            print("Show List View")
        }
        .onDisappear {
            print("List View Disappear")
        }
    }
}

private extension CarListView {
    
    @MainActor
    func toggle() {
        rowToggle.toggle()
    }
    
    @MainActor
    func increment() {
        count += 1
    }
}
