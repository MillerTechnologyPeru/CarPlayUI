//
//  Marker.swift
//
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import UIKit
import MapKit
import CarPlay

/// A balloon-shaped annotation that marks a map location.
public struct Marker: View {
    
    public typealias Label = Text
    
    let title: String
    
    let image: Image?
    
    let item: MKMapItem
    
    public var body: some View {
        PointOfInterest(
            title,
            location: item,
            pinImage: image
        )
    }
}

public extension Marker {
    
    /// Creates a marker at the given location with the label you provide.
    init<S: StringProtocol>(
        _ title: S,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = String(title)
        self.image = nil
        self.item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }
    
    /// Creates a marker at the given location with the provided title and image resource to display as the balloon’s icon.
    init<S: StringProtocol>(
        _ title: S,
        image imageName: String,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = String(title)
        self.image = Image(imageName)
        self.item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }
    
    /// Creates a marker at the given location with the provided title and a system image the map displays as the balloon’s icon.
    init<S: StringProtocol>(
        _ title: S,
        systemImage: String,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = String(title)
        self.image = Image(systemName: systemImage)
        self.item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }
    
    /// Creates a marker at the given location with the provided label.
    init(coordinate: CLLocationCoordinate2D, label: () -> Label) {
        self.title = _TextProxy(label()).rawText
        self.image = nil
        self.item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }
    
    /// Creates a marker for a given map item using a MapKit-provided label.
    init(item: MKMapItem) {
        self.title = item.name ?? ""
        self.image = nil
        self.item = item
    }
}
