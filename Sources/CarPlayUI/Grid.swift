//
//  Grid.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import CarPlay

@available(iOS 15.0, *)
public struct Grid: Template {
    
    let title: Text
    
    let buttons: [Button]
    
    public func makeTemplate() -> CPGridTemplate {
        CPGridTemplate(
            title: title.rawValue,
            gridButtons: buttons.map { .init($0) }
        )
    }
    
    public func updateTemplate(_ template: CPGridTemplate) {
        // update title
        if title.rawValue != template.title {
            template.updateTitle(title.rawValue)
        }
        // reload buttons
        template.updateGridButtons(buttons.map { .init($0) })
    }
}

@available(iOS 15.0, *)
public extension Grid {
    
    struct Button {
        
        let titleVariants: [Text]
        
        let image: Image
        
        let isEnabled: Bool
        
        let action: () -> ()
    }
}

@available(iOS 15.0, *)
internal extension CPGridButton {
    
    convenience init(_ button: Grid.Button) {
        self.init(titleVariants: button.titleVariants.map { $0.rawValue }, image: .unsafe(button.image)) { _ in
            button.action()
        }
        self.isEnabled = button.isEnabled
    }
}
