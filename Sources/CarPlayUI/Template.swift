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

// MARK: - Component

internal protocol AnyComponent {
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject?
    
    func update(component: inout NSObject, parent: NSObject)
    
    func remove(component: NSObject, parent: NSObject)
}

internal struct ComponentView <Content: View> : View, AnyComponent {
    
    let _build: (NSObject, NSObject?) -> NSObject?
    
    let _update: (inout NSObject, NSObject) -> ()
    
    let _remove: (NSObject, NSObject) -> ()
    
    let content: Content
    
    init(
        build: @escaping (NSObject, NSObject?) -> NSObject?,
        update: @escaping (inout NSObject, NSObject) -> (),
        remove: @escaping (NSObject, NSObject) -> (),
        @ViewBuilder content: () -> Content
    ) {
        self._build = build
        self._update = update
        self._remove = remove
        self.content = content()
    }
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject? {
        _build(parent, sibling)
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        _update(&component, parent)
    }
    
    func remove(component: NSObject, parent: NSObject) {
        _remove(component, parent)
    }
    
    var body: Never {
        neverBody("ComponentView")
    }
}

extension ComponentView: ParentView {
    
    var children: [AnyView] {
        [AnyView(content)]
    }
}
