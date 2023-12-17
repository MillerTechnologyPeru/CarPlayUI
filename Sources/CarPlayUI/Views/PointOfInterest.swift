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
    public init(_ title: String,
        subtitle: String? = nil,
        summary: String? = nil,
        detailTitle: String? = nil,
        detailSubtitle: String? = nil,
        detailSummary: String? = nil,
        pinImage: Image? = nil,
        selectedPinImage: Image? = nil,
        location: MKMapItem,
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
        self.selectedPinImage = selectedPinImage ?? pinImage
        self.content = content()
    }
    
    public var body: Content {
        content
    }
}

@available(iOS 14.0, *)
public extension PointOfInterest where Content == EmptyView {
    
    init(_ title: String,
        subtitle: String? = nil,
        summary: String? = nil,
        detailTitle: String? = nil,
        detailSubtitle: String? = nil,
        detailSummary: String? = nil,
        pinImage: Image? = nil,
        selectedPinImage: Image? = nil,
        location: MKMapItem
    ) {
        self.init(
            title,
            subtitle: subtitle,
            summary: summary,
            detailTitle: detailTitle,
            detailSubtitle: detailSubtitle,
            detailSummary: detailSummary,
            pinImage: pinImage,
            selectedPinImage: selectedPinImage ?? pinImage,
            location: location,
            content: { EmptyView() })
    }
}

@available(iOS 14.0, *)
public extension PointOfInterest {
    
    init(
        item: MKMapItem,
        @ViewBuilder row: () -> TupleView<(Text, Text?, Text?)>,
        @ViewBuilder detail: () -> TupleView<(Text, Text?, Text?)>,
        @ViewBuilder pin: () -> TupleView<(Image, Image?)>,
        @ViewBuilder content: () -> Content
    ) {
        let row = row().value
        let detail = detail().value
        let pinImage = pin().value
        self.init(
            _TextProxy(row.0).rawText,
            subtitle: row.1.flatMap{ _TextProxy($0).rawText },
            summary: row.2.flatMap{ _TextProxy($0).rawText },
            detailTitle: _TextProxy(detail.0).rawText,
            detailSubtitle: detail.1.flatMap{ _TextProxy($0).rawText },
            detailSummary: detail.2.flatMap{ _TextProxy($0).rawText },
            pinImage: pinImage.0,
            selectedPinImage: pinImage.1,
            location: item,
            content: content
        )
    }
}

// MARK: - AnyComponent

@available(iOS 14.0, *)
extension PointOfInterest: CarPlayPrimitive {
    
    var renderedBody: AnyView {
        AnyView(
            ComponentView(build: { parent, sibling in
                build(parent: parent, before: sibling)
            }, update: { (component, parent) in
                update(component: &component, parent: parent)
            }, remove: { (component, parent) in
                remove(component: component, parent: parent)
            }, content: {
                body
            })
        )
    }
}

@available(iOS 14.0, *)
extension PointOfInterest {
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject? {
        if let template = parent as? CPPointOfInterestTemplate {
            return build(template: template, before: sibling as? CPPointOfInterest)
        }
        return nil
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if let item = component as? CPPointOfInterest,
           let template = parent as? CPPointOfInterestTemplate {
            update(item, template: template)
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
    
    func update(_ pointOfInterest: CPPointOfInterest, template: CPPointOfInterestTemplate) {
        pointOfInterest.title = self.title
        pointOfInterest.subtitle = self.subtitle
        pointOfInterest.summary = self.summary
        pointOfInterest.detailTitle = self.detailTitle
        pointOfInterest.detailSubtitle = self.detailSubtitle
        pointOfInterest.detailSummary = self.detailSummary
        pointOfInterest.location = self.location
        pointOfInterest.pinImage = self.pinImage.flatMap { .unsafe(_ImageProxy($0)) }
        if #available(iOS 16.0, *) {
            pointOfInterest.selectedPinImage = self.selectedPinImage.flatMap { .unsafe(_ImageProxy($0)) }
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
