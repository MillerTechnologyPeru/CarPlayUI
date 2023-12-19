//
//  CarPointsOfInterestView.swift
//  CarPlaySample
//
//  Created by Alsey Coleman Miller on 12/16/23.
//  Copyright © 2023 Watanabe Toshinori. All rights reserved.
//

import Foundation
import MapKit
import CarPlayUI

struct CarPointsOfInterestView: View {
    
    @State
    private var _region = MKCoordinateRegion()
    
    @State
    private var _selection: Int?
    
    @State
    private var counter = 0
    
    @State
    private var buttonCounter = 0
    
    var body: some View {
        Map(region: region, selection: selection) {
            PointOfInterest(
                "CN Tower",
                subtitle: "\(counter > 0 ? "\(counter)" : "416-815-5500")",
                detailSummary: "Landmark, over 553-metre tower featuring a glass floor & a revolving eatery with panoramic views.",
                location: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
                    latitude: 43.65,
                    longitude: -79.38)))
            ) {
                Button(buttonCounter > 0 ? "\(buttonCounter)" : "Tap") {
                    print("Primary Button pressed")
                    buttonCounter += 1
                }
            }
            PointOfInterest(
                item: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
                latitude: 43.64358280036363,
                longitude: -79.37910987946465))), 
                row: {
                    Text("Scotiabank Arena")
                    Text("40 Bay St., Toronto")
                    Text("416-815-5500")
                }, detail: {
                    Text("Scotiabank Arena")
                    nil as Text?
                    Text("Scotiabank Arena, formerly known as Air Canada Centre, is a multi-purposed arena located on Bay Street in the South Core district of Downtown Toronto, Ontario, Canada.")
                }, pin: {
                    Image(systemName: "building.columns")
                    Image(systemName: "building.columns.fill")
                }) {
                        Button("Primary Button") {
                            print("Primary Button pressed")
                        }
                        NavigationLink("Information", destination: CarInformationView())
                }
            Marker("City Hall", systemImage: "building", coordinate: CLLocationCoordinate2D(latitude: 43.653734011477184, longitude: -79.38415146943686))
            Marker("Rogers Center", coordinate: CLLocationCoordinate2D(latitude: 43.64190399683823,  longitude: -79.38917588924176))
        }
        .navigationTitle("Map")
    }
}

private extension CarPointsOfInterestView {
    
    var selection: Binding<Int?> {
        Binding(get: { 
            _selection
        }, set: { newValue in
            if newValue == 0 {
                counter += 1
            }
            _selection = newValue
            if let newValue {
                print("Selected item \(newValue)")
            } else {
                print("Selection reset")
            }
        })
    }
    
    var region: Binding<MKCoordinateRegion> {
        Binding(get: {
            _region
        }, set: { newValue in
            _region = newValue
            print("Region changed")
        })
    }
}
