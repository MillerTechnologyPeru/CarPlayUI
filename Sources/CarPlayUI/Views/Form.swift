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
                    let coordinator = CPInformationTemplate.Coordinator()
                    let template = CPInformationTemplate(
                        title: title,
                        layout: layout,
                        items: [],
                        actions: []
                    )
                    template.userInfo = coordinator
                    return template
                },
                update: { (informationTemplate: CPInformationTemplate) in
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
internal extension CPInformationTemplate {
    
    final class Coordinator {
        
        // must keep original since template copies on demand
        fileprivate(set) var items = [CPInformationItem]()
        
        // must keep copy original template copies on demand
        fileprivate(set) var actions = [CPTextButton]()
        
        fileprivate init() { }
    }
}

@available(iOS 14.0, *)
internal extension CPInformationTemplate {
    
    var coordinator: Coordinator! {
        userInfo as? Coordinator
    }
    
    // to prevent fetching copied items
    private var _items: [CPInformationItem] {
        get {
            coordinator.items
        }
        set {
            // The template can display 10 items maximum. 
            // If the array contains more items, the template uses only the first 10.
            let items = Array(newValue.prefix(10))
            // store original instance
            coordinator.items = items
            // send to CarPlay IPC
            self.items = items
        }
    }
    
    func insert(_ item: CPInformationItem, before sibling: CPInformationItem? = nil) {
        // move to before sibling
        if let sibling, let index = _items.firstIndex(of: sibling) {
            _items.insert(item, before: index)
        } else {
            // append to end
            _items.append(item)
        }
    }
    
    func update(oldValue: CPInformationItem, newValue: CPInformationItem) {
        guard let index = _items.firstIndex(where: { $0 === oldValue }) else {
            assertionFailure("Unable to find item in graph")
            return
        }
        // update with new instance at
        _items[index] = newValue
    }
    
    func remove(item: CPInformationItem) {
        guard let index = _items.firstIndex(where: { $0 === item }) else {
            return
        }
        _items.remove(at: index)
    }
    
    // to prevent fetching copies items
    private var _actions: [CPTextButton] {
        get {
            coordinator.actions
        }
        set {
            // The template can display three actions maximum.
            // If the array contains more actions, the template uses only the first three.
            let actions = Array(newValue.prefix(3))
            // store original instance
            coordinator.actions = actions
            // send to CarPlay IPC
            self.actions = actions
        }
    }
    
    func insert(_ action: CPTextButton, before sibling: CPTextButton? = nil) {
        // move to before sibling
        if let sibling, let index = _actions.firstIndex(of: sibling) {
            _actions.insert(action, before: index)
        } else {
            // append to end
            _actions.append(action)
        }
    }
    
    func update(oldValue: CPTextButton, newValue: CPTextButton) {
        guard let index = _actions.firstIndex(where: { $0 === oldValue }) else {
            assertionFailure("Unable to find item in graph")
            return
        }
        // update with new instance at
        _actions[index] = newValue
    }
    
    func remove(action: CPTextButton) {
        guard let index = _actions.firstIndex(where: { $0 === action }) else {
            return
        }
        _actions.remove(at: index)
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
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject? {
        if let template = parent as? CPInformationTemplate {
            return build(template: template, before: sibling as? CPInformationItem)
        }
        return nil
    }
    
    func buildItem() -> CPInformationItem {
        CPInformationItem(
            title: title,
            detail: detail
        )
    }
    
    func build(template: CPInformationTemplate, before sibling: CPInformationItem?) -> CPInformationItem {
        let informationItem = buildItem()
        template.insert(informationItem, before: sibling)
        return informationItem
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if let item = component as? CPInformationItem,
           let template = parent as? CPInformationTemplate {
            component = update(item, template: template)
        }
    }
    
    func update(_ oldValue: CPInformationItem, template: CPInformationTemplate) -> CPInformationItem {
        let newValue = buildItem()
        template.update(oldValue: oldValue, newValue: newValue)
        return newValue
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if let item = component as? CPInformationItem,
           let template = parent as? CPInformationTemplate {
            remove(item, template: template)
        }
    }
    
    func remove(_ item: CPInformationItem, template: CPInformationTemplate) {
        template.remove(item: item)
    }
}

@available(iOS 14.0, *)
internal extension Text {
    
    func build(template: CPInformationTemplate, before sibling: CPInformationItem?) -> CPInformationItem {
        let title = _TextProxy(self).rawText
        let formItem = FormItem(title: title)
        return formItem.build(template: template, before: sibling)
    }
}

@available(iOS 14.0, *)
extension TupleView where T == (Text, Text) {
    
    func build(parent: NSObject, before sibling: CPInformationItem?) -> NSObject? {
        if let template = parent as? CPInformationTemplate {
            return build(template: template, before: sibling)
        }
        return nil
    }
    
    func build(template: CPInformationTemplate, before sibling: CPInformationItem?) -> CPInformationItem {
        let title = _TextProxy(self.value.0).rawText
        let detail = _TextProxy(self.value.1).rawText
        let informationItem = CPInformationItem(
            title: title,
            detail: detail
        )
        template.insert(informationItem, before: sibling)
        return informationItem
    }
}
