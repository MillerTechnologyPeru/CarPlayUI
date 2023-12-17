//
//  PointOfInterest.swift
//
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import UIKit
import MapKit
import CarPlay

/// Point of Interest to show on the map.
///
/// A point of interest describes a geographical location on a map.
/// It also provides supplementary information about the location, such as a title and summary that the template displays in a scrollable picker and on a detail card.
///
/// A point of interest also provides the buttons the detail card presents to the user as contextual actions.
@available(iOS 14.0, *)
public struct PointOfInterest <Content>: View where Content : View {
    
    let title: String
    
    let location: MKMapItem
    
    let subtitle: String?
    
    let summary: String?
    
    let detailTitle: String?
    
    let detailSubtitle: String?
    
    let detailSummary: String?
    
    let pinImage: Image?
    
    let selectedPinImage: Image?
    
    let content: Content
    
    /// Creates a point of interest for a specific location.
    @available(iOS 16, *)
    public init(_ title: String,
        subtitle: String? = nil,
        location: MKMapItem,
        summary: String? = nil,
        detailTitle: String? = nil,
        detailSubtitle: String? = nil,
        detailSummary: String? = nil,
        pinImage: Image,
        selectedPinImage: Image,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.location = location
        self.subtitle = subtitle
        self.summary = summary
        self.detailTitle = detailTitle
        self.detailSubtitle = detailSubtitle
        self.detailSummary = detailSummary
        self.pinImage = pinImage
        self.selectedPinImage = selectedPinImage
        self.content = content()
    }
    
    /// Creates a point of interest for a specific location.
    public init(_ title: String,
        subtitle: String? = nil,
        location: MKMapItem,
        summary: String? = nil,
        detailTitle: String? = nil,
        detailSubtitle: String? = nil,
        detailSummary: String? = nil,
        pinImage: Image? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.location = location
        self.subtitle = subtitle
        self.summary = summary
        self.detailTitle = detailTitle
        self.detailSubtitle = detailSubtitle
        self.detailSummary = detailSummary
        self.pinImage = pinImage
        self.selectedPinImage = nil
        self.content = content()
    }
    
    public var body: Never {
        neverBody(String(reflecting: Self.self))
    }
}

@available(iOS 14.0, *)
public extension PointOfInterest where Content == EmptyView {
    
    init(_ title: String,
        subtitle: String? = nil,
        location: MKMapItem,
        summary: String? = nil,
        detailTitle: String? = nil,
        detailSubtitle: String? = nil,
        detailSummary: String? = nil,
        pinImage: Image? = nil
    ) {
        self.init(
            title,
            subtitle: subtitle,
            location: location,
            summary: summary,
            detailTitle: detailTitle,
            detailSubtitle: detailSubtitle,
            detailSummary: detailSummary,
            pinImage: pinImage,
            content: { EmptyView() })
    }
}

// MARK: - AnyComponent

@available(iOS 14.0, *)
extension PointOfInterest: AnyComponent {
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject? {
        if let template = parent as? CPPointOfInterestTemplate {
            return build(template: template, before: sibling as? CPPointOfInterest)
        }
        return nil
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if let item = component as? CPPointOfInterest,
           let template = parent as? CPPointOfInterestTemplate {
            component = update(item, template: template)
        }
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if let item = component as? CPPointOfInterest,
           let template = parent as? CPPointOfInterestTemplate {
            template.remove(item)
        }
    }
}

@available(iOS 14.0, *)
private extension PointOfInterest {
    
    func buildItem() -> CPPointOfInterest {
        if #available(iOS 16.0, *) {
            return CPPointOfInterest(
                location: location,
                title: title,
                subtitle: subtitle,
                summary: summary,
                detailTitle: detailTitle,
                detailSubtitle: detailSubtitle,
                detailSummary: detailSummary,
                pinImage: pinImage.flatMap { .unsafe(_ImageProxy($0)) },
                selectedPinImage: selectedPinImage.flatMap { .unsafe(_ImageProxy($0)) }
            )
        } else {
            return CPPointOfInterest(
                location: location,
                title: title,
                subtitle: subtitle,
                summary: summary,
                detailTitle: detailTitle,
                detailSubtitle: detailSubtitle,
                detailSummary: detailSummary,
                pinImage: pinImage.flatMap { .unsafe(_ImageProxy($0)) }
            )
        }
    }
    
    func build(template: CPPointOfInterestTemplate, before sibling: CPPointOfInterest?) -> CPPointOfInterest {
        let newValue = buildItem()
        template.insert(newValue, before: sibling)
        return newValue
    }
    
    func update(_ oldValue: CPPointOfInterest, template: CPPointOfInterestTemplate) -> CPPointOfInterest {
        let newValue = buildItem()
        template.update(oldValue: oldValue, newValue: newValue)
        return newValue
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
