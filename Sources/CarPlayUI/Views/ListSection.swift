//
//  ListSection.swift
//  
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import CarPlay

public struct ListSection: View, _PrimitiveView {
    
    let header: String?
    
    let sectionIndexTitle: String?
    
    let items: [ListItem]
    
    @Environment(\.self)
    private var environment
    
    @EnvironmentObject
    var navigationContext: NavigationContext
    
    public init(
        header: String? = nil,
        sectionIndexTitle: String? = nil,
        items: [ListItem]
    ) {
        self.header = header
        self.sectionIndexTitle = sectionIndexTitle
        self.items = items
    }
}

// MARK: - Section Convenience

public extension Section where Parent == EmptyView, Footer == EmptyView, Content == ListSection {
    
    init(header: String? = nil,
         sectionIndexTitle: String? = nil,
         data: [ListItem]
    ) {
        self.header = EmptyView()
        self.footer = EmptyView()
        self.content = ListSection(
            header: header,
            sectionIndexTitle: sectionIndexTitle,
            items: data
        )
    }
    
    init<Content: View>(
        header: String? = nil,
        sectionIndexTitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        let children = (content as? ParentView)?.children ?? []
        let items = children.compactMap {
            mapAnyView($0, transform: { (view: ListItem) in view })
        }
        self.init(header: header, sectionIndexTitle: sectionIndexTitle, data: items)
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
                EmptyView()
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
            component = update(section, template: template)
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
    
    func buildSection() -> CPListSection {
        CPListSection(
            items: items.map { buildItem(for: $0) },
            header: header,
            sectionIndexTitle: sectionIndexTitle
        )
    }
    
    func buildItem(for item: ListItem) -> CPListItem {
        let listItem = CPListItem(item)
        let action = task(for: item.action)
        if #available(iOS 14.0, *) {
            listItem.handler = { (item, completion) in
                Task(priority: .userInitiated) {
                    await action()
                    await MainActor.run {
                        completion()
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            
        }
        return listItem
    }
    
    func task(for action: ListItem.Action) -> () async -> () {
        switch action {
        case let .task(task):
            return task
        case let .navigate(destination):
            let destination = NavigationDestination(destination)
            // read environment
            let context: NavigationContext? = self.navigationContext
            return {
                context?.push(destination)
            }
        }
    }
    
    func build(template: CPListTemplate, before sibling: CPListSection?) -> CPListSection {
        let newValue = buildSection()
        template.insert(newValue, before: sibling)
        return newValue
    }
    
    func update(_ oldValue: CPListSection, template: CPListTemplate) -> CPListSection {
        let newValue = buildSection()
        template.update(oldValue: oldValue, newValue: newValue)
        return newValue
    }
}
