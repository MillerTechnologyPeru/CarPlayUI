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

// MARK: - CarPlayPrimitive

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
            return build(template: template, before: sibling as? CPPointOfInterest.ViewObject)
        }
        return nil
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if let item = component as? CPPointOfInterest.ViewObject,
           let template = parent as? CPPointOfInterestTemplate {
            update(item, template: template)
        }
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if let viewObject = component as? CPPointOfInterest.ViewObject,
           let template = parent as? CPPointOfInterestTemplate {
            template.remove(viewObject.view)
        }
    }
}

@available(iOS 14.0, *)
private extension PointOfInterest {
    
    func build(template: CPPointOfInterestTemplate, before sibling: CPPointOfInterest.ViewObject?) -> CPPointOfInterest.ViewObject {
        let viewObject = CPPointOfInterest.ViewObject(
            title: title,
            location: location,
            subtitle: subtitle,
            summary: summary,
            detailTitle: detailTitle,
            detailSubtitle: detailSubtitle,
            detailSummary: detailSummary,
            pinImage: pinImage,
            selectedPinImage: selectedPinImage,
            template: template
        )
        template.insert(viewObject.view)
        return viewObject
    }
    
    func update(
        _ viewObject: CPPointOfInterest.ViewObject,
        template: CPPointOfInterestTemplate
    ) {
        // recreate POI if changed
        let oldView = viewObject.view
        // apply changes
        viewObject.title = self.title
        viewObject.subtitle = self.subtitle
        viewObject.summary = self.summary
        viewObject.detailTitle = self.detailTitle
        viewObject.detailSubtitle = self.detailSubtitle
        viewObject.detailSummary = self.detailSummary
        viewObject.location = self.location
        viewObject.pinImage = self.pinImage
        viewObject.selectedPinImage = self.selectedPinImage
        // get new view if changed
        let newValue = viewObject.view
        guard oldView !== viewObject.view else {
            return // no changes
        }
        // update template if new view was created
        template.update(oldValue: oldView, newValue: newValue)
    }
}

// MARK: - Button

@available(iOS 14.0, *)
internal extension Button where Label == Text {
    
    func build(pointOfInterest: CPPointOfInterest.ViewObject, before sibling: CPTextButton? = nil) -> CPTextButton {
        let newButton = buildTextButton()
        //pointOfInterest.insert(newButton, before: sibling)
        //pointOfInterest.coordinator.template?.update(pointOfInterest)
        return newButton
    }
    
    func update(_ oldValue: CPTextButton, pointOfInterest: CPPointOfInterest.ViewObject) -> CPTextButton {
        let newValue = buildTextButton()
        //pointOfInterest.update(oldValue: oldValue, newValue: newValue)
        //pointOfInterest.coordinator.template?.update(pointOfInterest)
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

// MARK: - Coordinator

@available(iOS 14.0, *)
internal extension CPPointOfInterest {
    
    var coordinator: Coordinator {
        userInfo as! Coordinator
    }
    
    final class Coordinator {
        
        init(template: CPPointOfInterestTemplate) {
            self.template = template
        }
        
        weak var template: CPPointOfInterestTemplate?
    }
}

@available(iOS 14.0, *)
internal extension CPPointOfInterest {
    
    // represents a POI in the object graph
    final class ViewObject: NSObject {
        
        var title: String {
            didSet {
                if oldValue != self.title {
                    viewDidChange = true
                }
            }
        }
        
        var location: MKMapItem {
            didSet {
                if oldValue != self.location {
                    viewDidChange = true
                }
            }
        }
        
        var subtitle: String? {
            didSet {
                if oldValue != self.subtitle {
                    viewDidChange = true
                }
            }
        }
        
        var summary: String? {
            didSet {
                if oldValue != self.summary {
                    viewDidChange = true
                }
            }
        }
        
        var detailTitle: String? {
            didSet {
                if oldValue != self.detailTitle {
                    viewDidChange = true
                }
            }
        }
        
        var detailSubtitle: String? {
            didSet {
                if oldValue != self.detailSubtitle {
                    viewDidChange = true
                }
            }
        }
        
        var detailSummary: String? {
            didSet {
                if oldValue != self.detailSummary {
                    viewDidChange = true
                }
            }
        }
        
        var pinImage: Image? {
            didSet {
                if oldValue != self.pinImage {
                    viewDidChange = true
                }
            }
        }
        
        var selectedPinImage: Image? {
            didSet {
                if oldValue != self.selectedPinImage {
                    viewDidChange = true
                }
            }
        }
        
        unowned let template: CPPointOfInterestTemplate
        
        private var _view: CPPointOfInterest!
        
        var view: CPPointOfInterest {
            guard viewDidChange else {
                return _view
            }
            viewDidChange = false
            _view = CPPointOfInterest(self)
            return _view
        }
        
        private var viewDidChange = false
        
        init(title: String, 
             location: MKMapItem,
             subtitle: String?,
             summary: String?,
             detailTitle: String?,
             detailSubtitle: String?,
             detailSummary: String?,
             pinImage: Image?,
             selectedPinImage: Image?,
             template: CPPointOfInterestTemplate
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
            self.template = template
            super.init()
            self._view = CPPointOfInterest(self)
        }
    }
}
