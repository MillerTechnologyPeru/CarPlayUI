//
//  Template.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

import Foundation
import UIKit
import CarPlay

internal protocol AnyTemplate {
    
    func build() -> CPTemplate
    
    func update(_ template: CPTemplate)
}

// MARK: - View

internal struct TemplateView <Content: View, Template: CPTemplate> : View, AnyTemplate {
    
    let _build: () -> Template
    
    let _update: (Template) -> ()
    
    let content: Content
    
    init(
        build: @escaping () -> Template,
        update: @escaping (Template) -> (),
        @ViewBuilder content: () -> Content
    ) {
        self._build = build
        self._update = update
        self.content = content()
    }
    
    func build() -> CPTemplate {
        _build()
    }
    
    func update(_ anyTemplate: CPTemplate) {
        guard let template = anyTemplate as? Template else {
            assertionFailure("Cannot update \(type(of: anyTemplate)) template of a different type than \(Template.self)")
            return
        }
        _update(template)
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
