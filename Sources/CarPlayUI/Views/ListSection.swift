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
    
    func task(for action: ListItem.Action) -> () async -> () {
        switch action {
        case let .task(task):
            return task
        case let .navigate(destination):
            let destination = NavigationDestination(destination)
            // read environment
            let context: NavigationContext? = self.navigationContext
            return {
                await context?.push(destination)
            }
        }
    }
    
    func build(template: CPListTemplate, before sibling: CPListSection?) -> CPListSection {
        let newValue = CPListSection(self, userInfo: { item in
            CPListItem.Coordinator(item: item, task: self.task(for: item.action))
        })
        assert(newValue.items.count == self.items.count)
        template.insert(newValue, before: sibling)
        return newValue
    }
    
    func update(_ oldValue: CPListSection, template: CPListTemplate) -> CPListSection {
        let newValue = CPListSection(self, userInfo: { item in
            CPListItem.Coordinator(item: item, task: self.task(for: item.action))
        })
        // only update sections if changed
        if oldValue._isEqual(to: newValue) {
            for (index, item) in items.enumerated() {
                let coordinator = oldValue.items[index].userInfo as! CPListItem.Coordinator
                coordinator.item = item
                coordinator.task = self.task(for: item.action)
            }
            return oldValue
        } else {
            template.update(oldValue: oldValue, newValue: newValue)
            return newValue
        }
        return newValue
    }
}
