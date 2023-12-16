//
//  TabBar.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
public struct TabView <Content: View> : View {
    
    public typealias SelectionValue = Int
        
    var selection: Binding<SelectionValue>?
    
    public let body: Content
    
    @available(iOS 17.0, *)
    public init(
        selection: Binding<SelectionValue>? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.selection = selection
        self.body = content()
    }
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.selection = nil
        self.body = content()
    }
}

@available(iOS 14.0, *)
extension TabView: CarPlayPrimitive {
    
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: {
                    let coordinator = CPTabBarTemplate.Coordinator()
                    let template = CPTabBarTemplate(templates: [])
                    template.userInfo = coordinator
                    template.delegate = coordinator
                    coordinator.selection = selection
                    return template
                },
                update: { (template: CPTabBarTemplate) in
                    
                    // programatically select tab
                    if #available(iOS 17.0, *),
                       let selection = selection?.wrappedValue {
                        template.selectTemplate(at: selection)
                    }
                },
                content: { body }
            )
        )
    }
}


@available(iOS 14.0, *)
internal extension CPTabBarTemplate {
    
    final class Coordinator: NSObject, TemplateCoordinator {
        
        fileprivate(set) var selection: Binding<Int>?
        
        var onAppear: (() -> ())?
        
        fileprivate override init() { 
            super.init()
        }
    }
}

@available(iOS 14.0, *)
extension CPTabBarTemplate.Coordinator: CPTabBarTemplateDelegate {
    
    public func tabBarTemplate(_ tabBarTemplate: CPTabBarTemplate, didSelect selectedTemplate: CPTemplate) {
        
        // update index binding
        if let selection = selection,
           let index = tabBarTemplate.templates.firstIndex(of: selectedTemplate),
            selection.wrappedValue != index {
            // update value
            selection.wrappedValue = index
            // inform appearence
        }
    }
}

@available(iOS 14.0, *)
internal extension CPTabBarTemplate {
    
    var coordinator: Coordinator! {
        userInfo as? Coordinator
    }
    
    func insert(_ template: CPTemplate, before sibling: CPTemplate? = nil) {
        // add template
        var templates = self.templates
        // move to before sibling
        if let sibling, let index = templates.firstIndex(of: sibling) {
            templates.insert(template, before: index)
        } else {
            // append to end
            templates.append(template)
        }
        // update children templates
        self.updateTemplates(templates)
    }
}
