//
//  TabView.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
public struct TabView <Content: View>: Template {
    
    public typealias SelectionValue = Int
        
    var selection: Binding<SelectionValue>?
        
    @available(iOS 17.0, *)
    public init(
        selection: Binding<SelectionValue>? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.selection = selection
        content()
    }
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.selection = nil
        content()
    }
    
    public func makeTemplate(context: Context) -> CPTabBarTemplate {
        CPTabBarTemplate(templates: [])
    }
    
    public func updateTemplate(_ template: CPTabBarTemplate, context: Context) {
        
        // update view
        context.coordinator.view = self
        
        // programatically select tab
        if #available(iOS 17.0, *),
           let selection = selection?.wrappedValue,
           let selectedTemplate = template.selectedTemplate,
           let index = template.templates.firstIndex(of: selectedTemplate),
           index != selection {
            template.selectTemplate(at: selection)
        }
        
        // update templates
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Coordinator

@available(iOS 14.0, *)
public extension TabView {
    
    final class Coordinator: NSObject, CPTabBarTemplateDelegate {
                
        var view: TabView<Content>
        
        fileprivate init(_ view: TabView<Content>) {
            self.view = view
        }
        
        public func tabBarTemplate(_ tabBarTemplate: CPTabBarTemplate, didSelect selectedTemplate: CPTemplate) {
            
            // update index binding
            if let selection = view.selection,
               let index = tabBarTemplate.templates.firstIndex(of: selectedTemplate),
                selection.wrappedValue != index {
                selection.wrappedValue = index
            }
        }
    }
}
