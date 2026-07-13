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
        ToolbarReader { (title, toolbar, onAppear, onDisappear) in
            Template(
                title: title.map { _TextProxy($0).rawText } ?? "",
                region: region,
                selection: selection,
                onAppear: onAppear,
                onDisappear: onDisappear,
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

        let onAppear: (() -> ())?

        let onDisappear: (() -> ())?

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
                    coordinator.appearAction = onAppear
                    coordinator.disappearAction = onDisappear
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
                       selection.wrappedValue != template._coordinator.lastSelection {
                        let newIndex = selection.wrappedValue.toFoundation()
                        template.setPointsOfInterest(template.pointsOfInterest, selectedIndex: newIndex)
                    }
                    template._coordinator.appearAction = onAppear
                    template._coordinator.disappearAction = onDisappear
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

        var appearAction: (() -> Void)?

        var disappearAction: (() -> Void)?

        var hasAppeared = false

        fileprivate var lastSelection: Int?

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

@available(iOS 14.0, *)
private extension CPPointOfInterestTemplate {
    
    var _coordinator: Coordinator! {
        userInfo as? Coordinator
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
        guard let selection else { return }
        guard let index = pointOfInterestTemplate.pointsOfInterest.firstIndex(where: { $0 === pointOfInterest }) else {
            assertionFailure()
            return
        }
        guard selection.wrappedValue != index else { return }
        lastSelection = index
        selection.wrappedValue = index
    }
}
