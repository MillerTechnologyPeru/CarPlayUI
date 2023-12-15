//
//  CPGridButton.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

import Foundation
import CarPlay

internal extension CPGridButton {
    
    convenience init(label: ParentView, action: @escaping (CPGridButton) -> ()) {
        // extract labels
        var labels = label.children.compactMap {
            mapAnyView($0, transform: { (view: Text) in
                _TextProxy(view).rawText
            })
        }
        // Set default label if none are found
        if labels.isEmpty {
            labels.append("Button")
        }
        
        // extract image
        let defaultImage = _ImageProxy(Image(systemName: "car"))
        let image = label.children.compactMap {
            mapAnyView($0, transform: { (view: Image) in
                _ImageProxy(view)
            })
        }.first
        
        // create button
        self.init(
            titleVariants: labels,
            image: .unsafe((image ?? defaultImage).provider.resolve(in: .defaultEnvironment), traitCollection: nil),
            handler: action
        )
    }
}
