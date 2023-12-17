//
//  ListSection.swift
//  
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import CarPlay

public struct ListSection <Content>: View where Content : View {
    
    let header: String?
    
    let sectionIndexTitle: String?
    
    let content: Content
    
    public init(
        header: String? = nil,
        sectionIndexTitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.sectionIndexTitle = sectionIndexTitle
        self.content = content()
    }
    
    public var body: Content {
        content
    }
}

// MARK: - Section Convenience

public extension Section where Parent == EmptyView, Footer == EmptyView, Content == ListSection<AnyView> {
    
    init<Items: View>(@ViewBuilder content: () -> Items) {
        self.header = EmptyView()
        self.footer = EmptyView()
        self.content = ListSection(header: nil, content: { AnyView(content()) })
    }
}

public extension Section where Parent == Text, Footer == EmptyView, Content == ListSection<AnyView> {
    
    init<Items: View>(
        header: Text,
        sectionIndexTitle: String? = nil,
        @ViewBuilder content: () -> Items
    ) {
        self.header = header
        self.footer = EmptyView()
        self.content = ListSection(
            header: _TextProxy(header).rawText,
            sectionIndexTitle: sectionIndexTitle,
            content: { AnyView(content()) }
        )
    }
}

// MARK: - CarPlayPrimitive

extension ListSection: CarPlayPrimitive {
    
    var renderedBody: AnyView {
        AnyView(
            ComponentView(build: { parent, sibling in
                build(parent: parent, before: sibling)
            }, update: { (component, parent) in
                update(component: &component, parent: parent)
            }, remove: { (component, parent) in
                remove(component: component, parent: parent)
            }, content: {
                body
            })
        )
    }
}

extension ListSection {
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject? {
        if let template = parent as? CPListTemplate {
            return build(template: template, before: sibling as? CPListSection)
        }
        return nil
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if let section = component as? CPListSection,
           let template = parent as? CPListTemplate {
            update(section, template: template)
        }
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if let section = component as? CPListSection,
           let template = parent as? CPListTemplate {
            template.remove(section)
        }
    }
}

private extension ListSection {
    
    func buildItem() -> CPListSection {
        CPListSection(
            items: [],
            header: header,
            sectionIndexTitle: sectionIndexTitle
        )
    }
    
    func build(template: CPListTemplate, before sibling: CPListSection?) -> CPListSection {
        let newValue = buildItem()
        template.insert(newValue, before: sibling)
        return newValue
    }
    
    func update(_ section: CPListSection, template: CPListTemplate) -> CPListSection {
        
    }
}
