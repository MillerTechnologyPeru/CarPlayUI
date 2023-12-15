//
//  Component.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

import Foundation
import UIKit
import CarPlay

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
