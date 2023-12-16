//
//  MapView.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

import Foundation
import UIKit
import MapKit
import CarPlay

/// Shows points of interest on CarPlay.
public struct Map: View {
    
    @Binding
    var region: MKCoordinateRegion
    
    @Binding
    var selection: MKCoordinateRegion
    
    public var body: some View {
        EmptyView()
    }
}

/// Point of Interest to show on the map.
public struct Annotation<Label, Content> where Label : View, Content : View {
    
    init(
        location: MKMapItem,
        title: String,
        subtitle: String?,
        summary: String?,
        detailTitle: String?,
        detailSubtitle: String?,
        detailSummary: String?,
        pinImage: UIImage?,
        selectedPinImage: UIImage?
    ) {
        
    }
    
    public var body: some View {
        EmptyView()
    }
}

@available(iOS 14.0, *)
public extension Map {
    
    final class Coordinator: NSObject, TemplateCoordinator, CPPointOfInterestTemplateDelegate {
        
        fileprivate init() {
            super.init()
        }
        
        /**
         The user has changed the map region on the `CPPointOfInterestTemplate`. Your application
         should respond by updating `pointsOfInterest` to show new points of interest for the new region.
         */
        public func pointOfInterestTemplate(_ pointOfInterestTemplate: CPPointOfInterestTemplate, didChangeMapRegion region: MKCoordinateRegion) {
            view.region = region
        }
        
        /**
         The user has selected the `pointOfInterest` and the details are being shown.
         */
        public func pointOfInterestTemplate(_ pointOfInterestTemplate: CPPointOfInterestTemplate, didSelectPointOfInterest pointOfInterest: CPPointOfInterest) {
            
        }
    }
}

// MARK: - Button

@available(iOS 14.0, *)
internal extension Button where Label == Text {
    
    func build(pointOfInterest: CPPointOfInterest, before sibling: CPTextButton? = nil) -> CPTextButton {
        let newButton = buildTextButton()
        pointOfInterest.insert(newButton, before: sibling)
        return newButton
    }
    
    func update(_ oldValue: CPTextButton, pointOfInterest: CPPointOfInterest) -> CPTextButton {
        let newValue = buildTextButton()
        pointOfInterest.update(oldValue: oldValue, newValue: newValue)
        return newValue
    }
}

@available(iOS 14.0, *)
internal extension CPPointOfInterest {
    
    var buttons: [CPTextButton] {
        get {
            [primaryButton, secondaryButton].compactMap { $0 }
        }
        set {
            assert(newValue.count <= 2, "Can add a maximum of 2 buttons")
            primaryButton = newValue.count > 0 ? newValue[0] : nil
            secondaryButton = newValue.count > 1 ? newValue[1] : nil
        }
    }
    
    func insert(_ button: CPTextButton, before sibling: CPTextButton? = nil) {
        // move to before sibling
        if let sibling, let index = buttons.firstIndex(of: sibling) {
            buttons.insert(button, before: index)
        } else {
            // append to end
            buttons.append(button)
        }
    }
    
    func update(oldValue: CPTextButton, newValue: CPTextButton) {
        guard let index = buttons.firstIndex(where: { $0 === oldValue }) else {
            assertionFailure("Unable to find item in graph")
            return
        }
        // update with new instance at index
        buttons[index] = newValue
    }
    
    func remove(button: CPTextButton) {
        guard let index = buttons.firstIndex(where: { $0 === button }) else {
            return
        }
        buttons.remove(at: index)
    }
}
