//
//  Form.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
public struct Form <Content: View>: View {
    
    let content: Content
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    public var body: some View {
        ToolbarReader { (title, toolbar) in
            TemplateView(
                title: title?.rawValue ?? "",
                layout: .leading,
                items: [],
                actions: []
            )
        }
    }
}

// MARK: - Supporting Types

@available(iOS 14.0, *)
internal extension Form {
    
    struct TemplateView: Template {
        
        let title: String
        
        let layout: CPInformationTemplateLayout
        
        let items: [FormItem]
        
        let actions: [FormAction]
        
        public func makeTemplate(context: Context) -> CPInformationTemplate {
            CPInformationTemplate(
                title: title,
                layout: layout,
                items: items.map { .init($0) },
                actions: actions.map { .init($0) }
            )
        }
        
        public func updateTemplate(_ template: CPInformationTemplate, context: Context) {
            template.title = title
            template.items = items.map { .init($0) }
            template.actions = actions.map { .init($0) }
        }
    }
}

@available(iOS 14.0, *)
struct FormItem {
    
    let title: String?
    
    let detail: String?
}

@available(iOS 14.0, *)
struct FormAction {
    
    let title: String
    
    let textStyle: CPTextButtonStyle
    
    let action: () -> ()
}

// MARK: - Extensions

@available(iOS 14.0, *)
internal extension CPInformationItem {
    
    convenience init(_ item: FormItem) {
        self.init(
            title: item.title,
            detail: item.detail
        )
    }
}

@available(iOS 14.0, *)
internal extension CPTextButton {
    
    convenience init(_ action: FormAction) {
        self.init(
            title: action.title,
            textStyle: action.textStyle,
            handler: { _ in
                action.action()
            }
        )
    }
    
    func update(action: FormAction) {
        self.title = action.title
        self.textStyle = action.textStyle
    }
}
