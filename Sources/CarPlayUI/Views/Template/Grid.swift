//
//  Grid.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import CarPlay

public struct Grid <Content: View>: View {
        
    let buttons: [GridButton]
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        let content = content()
        let reducer = ReducerVisitor<GridButtonReducer>(initialResult: [])
        reducer.visit(content)
        self.buttons = reducer.result
    }
    
    public var body: some View {
        ToolbarReader { (title, toolbar) in
            GridTemplateView(
                title: title?.rawValue ?? "",
                buttons: buttons
            )
        }
    }
}

// MARK: - Supporting Types

struct GridTemplateView: Template {
    
    let title: String
    
    let buttons: [GridButton]
    
    func makeTemplate(context: Context) -> CPGridTemplate {
        CPGridTemplate(
            title: title,
            gridButtons: buttons.map { .init($0, traitCollection: nil) }
        )
    }
    
    func updateTemplate(_ template: CPGridTemplate, context: Context) {
        
        if #available(iOS 15, *) {
            // update title
            if title != template.title {
                template.updateTitle(title)
            }
            // reload buttons
            template.updateGridButtons(buttons.map { .init($0, traitCollection: nil) })
        }
    }
    
    func makeCoordinator() -> GridCoordinator {
        GridCoordinator()
    }
}

final class GridCoordinator {
    
    fileprivate init() {
        
    }
}

struct GridButton {
    
    let text: Text
    
    let image: Image
    
    let isEnabled: Bool
    
    let action: () -> ()
}

struct GridButtonReducer: ViewReducer {
    
    typealias Result = [GridButton]
    
    static func reduce<V: View>(into partialResult: inout Result, nextView: V) {
        if let view = nextView as? Button<Label<Text, Image>> {
            let button = GridButton(
                text: view.label.title,
                image: view.label.icon,
                isEnabled: true,
                action: view.action
            )
            partialResult.append(button)
        }
    }
}

// MARK: - Extensions

internal extension CPGridButton {
    
    convenience init(_ button: GridButton, traitCollection: UITraitCollection?) {
        self.init(titleVariants: button.text.variants, image: .unsafe(button.image, traitCollection: traitCollection)) { _ in
            button.action()
        }
        self.isEnabled = button.isEnabled
    }
}
