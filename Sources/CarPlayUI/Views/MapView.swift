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
@available(iOS 14.0, *)
public struct Map <Content: View>: View {
    
    public typealias SelectionValue = Int
    
    let region: Binding<MKCoordinateRegion>?
    
    let selection: Binding<Int?>?
    
    let content: Content
    
    public init(
        region: Binding<MKCoordinateRegion>? = nil,
        selection: Binding<SelectionValue?>? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.region = region
        self.selection = selection
        self.content = content()
    }
    
    public var body: some View {
        ToolbarReader { (title, toolbar) in
            Template(
                title: title.flatMap { mapAnyView($0, transform: { (view: Text) in _TextProxy(view).rawText }) } ?? "",
                region: region,
                selection: selection,
                content: content
            )
        }
    }
}

// MARK: - CarPlayPrimitive

@available(iOS 14.0, *)
extension Map {
    
    struct Template: View {
        
        let title: String
        
        let region: Binding<MKCoordinateRegion>?
        
        let selection: Binding<Int?>?
        
        let content: Content
        
        public var body: Content {
            content
        }
    }
}


@available(iOS 14.0, *)
extension Map.Template: CarPlayPrimitive {
    
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: {
                    let coordinator = CPPointOfInterestTemplate.Coordinator(
                        region: self.region,
                        selection: self.selection
                    )
                    let template = CPPointOfInterestTemplate(
                        title: title,
                        pointsOfInterest: [],
                        selectedIndex: NSNotFound
                    )
                    template.userInfo = coordinator
                    template.pointOfInterestDelegate = coordinator
                    return template
                },
                update: { (template: CPPointOfInterestTemplate) in
                    // update title
                    if template.title != title {
                        template.title = title
                    }
                    // update selection
                    if let selection,
                       selection.wrappedValue.toFoundation() != template.selectedIndex,
                       selection.wrappedValue.toFoundation() < template.pointsOfInterest.count {
                        let newIndex = selection.wrappedValue.toFoundation()
                        template.setPointsOfInterest(template.pointsOfInterest, selectedIndex: newIndex)
                    }
                },
                content: { content }
            )
        )
    }
}

// MARK: - Coordinator

@available(iOS 14.0, *)
public extension CPPointOfInterestTemplate {
    
    final class Coordinator: NSObject, NavigationStackTemplateCoordinator {
        
        let region: Binding<MKCoordinateRegion>?
        
        let selection: Binding<Int?>?
        
        var navigationDestination: NavigationDestination?
        
        var navigationContext: NavigationContext?
        
        fileprivate init(
            region: Binding<MKCoordinateRegion>?,
            selection: Binding<Int?>?
        ) {
            self.region = region
            self.selection = selection
            super.init()
        }
    }
}

// MARK: - CPPointOfInterestTemplateDelegate

@available(iOS 14.0, *)
extension CPPointOfInterestTemplate.Coordinator: CPPointOfInterestTemplateDelegate {
    
    /**
     The user has changed the map region on the `CPPointOfInterestTemplate`. Your application
     should respond by updating `pointsOfInterest` to show new points of interest for the new region.
     */
    public func pointOfInterestTemplate(_ pointOfInterestTemplate: CPPointOfInterestTemplate, didChangeMapRegion region: MKCoordinateRegion) {
        
        // update region
        self.region?.wrappedValue = region
    }
    
    /**
     The user has selected the `pointOfInterest` and the details are being shown.
     */
    public func pointOfInterestTemplate(_ pointOfInterestTemplate: CPPointOfInterestTemplate, didSelectPointOfInterest pointOfInterest: CPPointOfInterest) {
        
        // update selection index
        self.selection?.wrappedValue = pointOfInterestTemplate.selectedIndex.filterNSNotFound()
    }
}
