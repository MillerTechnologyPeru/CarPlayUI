//
//  Form.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

@available(iOS 14.0, *)
public struct Form <Content: View> : View {
    
    let content: Content
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    public var body: some View {
        ToolbarReader { (title, toolbar) in
            return Template(
                title: title.flatMap { mapAnyView($0, transform: { (view: Text) in _TextProxy(view).rawText }) } ?? "",
                layout: .leading,
                content: content
            )
        }
    }
}

// MARK: - CarPlayPrimitive

@available(iOS 14.0, *)
extension Form {
    
    struct Template: View {
        
        let title: String
        
        let layout: CPInformationTemplateLayout
        
        let content: Content
        
        public var body: Content {
            content
        }
    }
}

@available(iOS 14.0, *)
extension Form.Template: CarPlayPrimitive {
    
    @_spi(TokamakCore)
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: {
                    return CPInformationTemplate(
                        title: title,
                        layout: layout,
                        items: [],
                        actions: []
                    )
                },
                update: { informationTemplate in
                    // update title
                    if informationTemplate.title != title {
                        informationTemplate.title = title
                    }
                    // cant update layout
                    if informationTemplate.layout != layout {
                        assertionFailure("Cannot change form style dynamically")
                    }
                },
                content: { content }
            )
        )
    }
}

@available(iOS 14.0, *)
public struct FormItem: View, _PrimitiveView {
    
    let title: String?
    
    let detail: String?
    
    public init(
        title: String?,
        detail: String? = nil
    ) {
        self.title = title
        self.detail = detail
    }
    
    public var body: Never {
        neverBody(String(reflecting: Self.self))
    }
}

@available(iOS 14.0, *)
extension FormItem: AnyComponent {
    
    func build(parent: NSObject) -> NSObject? {
        if let template = parent as? CPInformationTemplate {
            return build(template: template)
        }
        return nil
    }
    
    func buildItem() -> CPInformationItem {
        CPInformationItem(
            title: title,
            detail: detail
        )
    }
    
    func build(template: CPInformationTemplate) -> CPInformationItem {
        let informationItem = buildItem()
        print("Build \(informationItem) \(informationItem.title ?? "")")
        template.items.append(informationItem)
        return informationItem
    }
    
    func update(component: NSObject, parent: NSObject) {
        if let item = component as? CPInformationItem,
           let template = parent as? CPInformationTemplate {
            update(item, template: template)
        }
    }
    
    func update(_ oldValue: CPInformationItem, template: CPInformationTemplate) {
        let newValue = buildItem()
        print("Update \(oldValue) \(oldValue.title ?? "") \(oldValue.detail ?? "") -> \(self.title ?? "") \(self.detail ?? "")")
        guard let index = template.items.firstIndex(where: { $0 === oldValue }) else {
            assertionFailure("Unable to find item in graph")
            return
        }
        template.items[index] = newValue
    }
}

@available(iOS 14.0, *)
internal extension Text {
    
    func build(template: CPInformationTemplate) -> CPInformationItem {
        let title = _TextProxy(self).rawText
        let formItem = FormItem(title: title)
        return formItem.build(template: template)
    }
}

@available(iOS 14.0, *)
extension TupleView where T == (Text, Text) {
    
    func build(parent: NSObject) -> NSObject? {
        if let template = parent as? CPInformationTemplate {
            return build(template: template)
        }
        return nil
    }
    
    func build(template: CPInformationTemplate) -> CPInformationItem {
        let title = _TextProxy(self.value.0).rawText
        let detail = _TextProxy(self.value.1).rawText
        let informationItem = CPInformationItem(
            title: title,
            detail: detail
        )
        template.items.append(informationItem)
        return informationItem
    }
}
