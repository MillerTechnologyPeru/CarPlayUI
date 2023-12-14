//
//  Template.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

import Foundation
import UIKit
import CarPlay
import TokamakCore

internal protocol AnyTemplate {
    
    func build(_ scene: CPTemplateApplicationScene) -> CPTemplate
    
    func update(_ target: CarPlayTarget)
}

// MARK: - View

internal struct TemplateView <Content: View> : View, AnyTemplate {
    
    let _build: (CPTemplateApplicationScene) -> CPTemplate
    
    let _update: (CarPlayTarget) -> ()
    
    let content: Content
    
    init(
        build: @escaping (CPTemplateApplicationScene) -> CPTemplate,
        update: @escaping (CarPlayTarget) -> (),
        @ViewBuilder content: () -> Content
    ) {
        self._build = build
        self._update = update
        self.content = content()
    }
    
    func build(_ scene: CPTemplateApplicationScene) -> CPTemplate {
        _build(scene)
    }
    
    func update(_ target: CarPlayTarget) {
        // make sure its a template
        if case .template = target.storage {
          _update(target)
        }
    }
    
    var body: Never {
        neverBody("TemplateView")
    }
}

extension TemplateView: ParentView {
    
    var children: [AnyView] {
        [AnyView(content)]
    }
}
