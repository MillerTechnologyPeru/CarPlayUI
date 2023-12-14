//
//  Grid.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

public struct Grid <Content: View> : View {
    
    let content: Content
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    public var body: Content {
        content
    }
}

extension Grid: CarPlayPrimitive {
    
    @_spi(TokamakCore)
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: { scene in
                    let children = (content as? ParentView)?.children ?? []
                    let buttons = children.compactMap { mapAnyView($0) { (view: GridButton) in
                        view.gridButton(scene: scene)
                    }}
                    return CPGridTemplate(
                        title: "",
                        gridButtons: buttons
                    )
                },
                update: { (target, scene) in
                    guard case let .template(template) = target.storage,
                        let gridTemplate = template as? CPGridTemplate else {
                        return
                    }
                    guard #available(iOS 15.0, *) else {
                        assertionFailure("Unable to update grid content")
                        return
                    }
                    let children = (content as? ParentView)?.children ?? []
                    let buttons = children.compactMap { mapAnyView($0) { (view: GridButton) in
                        view.gridButton(scene: scene)
                    }}
                    gridTemplate.updateTitle("")
                    gridTemplate.updateGridButtons(buttons)
                },
                content: { content }
            )
        )
    }
}

protocol GridButton {
    
    func gridButton(scene: CPTemplateApplicationScene) -> CPGridButton
}

extension View where Body: GridButton {
    
    func gridButton(scene: CPTemplateApplicationScene) -> CPGridButton {
        body.gridButton(scene: scene)
    }
}

extension ParentView {
    
    func gridButton(
        scene: CPTemplateApplicationScene,
        handler: @escaping (CPGridButton) -> ()
    ) -> CPGridButton {
        // extract labels
        var labels = children.compactMap {
            mapAnyView($0, transform: { (view: Text) in
                _TextProxy(view).rawText
            })
        }
        // Set default label if none are found
        if labels.isEmpty {
            labels.append("Button")
        }
        // extract image
        let image = children.compactMap {
            mapAnyView($0, transform: { (view: Image) in
                _ImageProxy(view)
            })
        }.first ?? _ImageProxy(Image(systemName: "car"))
        // create button
        return CPGridButton(
            titleVariants: labels,
            image: .unsafe(image.provider.resolve(in: .defaultEnvironment), traitCollection: scene.interfaceController.traitCollection),
            handler: handler
        )
    }
}

extension Button: GridButton where Label: ParentView {
    
    func gridButton(scene: CPTemplateApplicationScene) -> CPGridButton {
        label.gridButton(scene: scene, handler: { _ in
            action()
        })
    }
}

extension NavigationLink: GridButton where Label: ParentView {
    
    func gridButton(scene: CPTemplateApplicationScene) -> CPGridButton {
        return self.label.gridButton(scene: scene) { _ in
            // TODO: Push new template
            
        }
    }
}
