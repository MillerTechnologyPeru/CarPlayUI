//
//  ListItem.swift
//  
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import CarPlay

/// List Row for CarPlay
public struct ListItem: View, _PrimitiveView {
    
    let text: String?
    
    let detailText: String?
    
    let image: Image?
    
    let accessory: Accessory?
    
    let action: () async -> ()
    
    public init(
        text: String?,
        detailText: String? = nil,
        image: Image? = nil,
        action: @escaping () async -> () = { }
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
        self.action = action
        self.accessory = nil
    }
    
    @available(iOS 14, *)
    public init(
        text: String?,
        detailText: String? = nil,
        image: Image? = nil,
        accessory: Accessory,
        action: @escaping () async -> () = { }
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
        self.action = action
        self.accessory = accessory
    }
}

// MARK: - Accessory

public extension ListItem {
    
    enum Accessory {
        
        /// The list item will render without a trailing accessory, or using your custom image.
        case image(Image)
        
        /// The list item will display a disclosure indicator on its trailing side.
        case disclosureIndicator
        
        /// The list item will display a cloud image on its trailing side, perhaps indicating remotely-available content.
        case cloud
    }
}

public extension ListItem.Accessory {
    
    var image: Image? {
        switch self {
        case .image(let image):
            return image
        case .cloud, 
            .disclosureIndicator:
            return nil
        }
    }
}

// MARK: - Navigation Link

public struct ListNavigationLink <Destination: View>: View {
    
    public typealias Accessory = ListItem.Accessory
    
    let text: String?
    
    let detailText: String?
    
    let image: Image?
    
    let accessory: Accessory?
    
    let destination: Destination
    
    @EnvironmentObject
    var navigationContext: NavigationContext
    
    public init(
        text: String?,
        detailText: String? = nil,
        image: Image? = nil,
        destination: Destination
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
        self.accessory = nil
        self.destination = destination
    }
    
    @available(iOS 14, *)
    public init(
        text: String?,
        detailText: String? = nil,
        image: Image? = nil,
        accessory: Accessory,
        destination: Destination
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
        self.accessory = accessory
        self.destination = destination
    }
    
    public var body: some View {
        ListItem(
            text: text,
            detailText: detailText,
            image: image,
            action: { await action() }
        )
    }
}

private extension ListNavigationLink {
    
    func action() async {
        await navigationActivated()
    }
    
    @MainActor
    func navigationActivated() {
        // update context
        let destination = NavigationDestination(self.destination)
        navigationContext.push(destination)
    }
}

// MARK: - CarPlayPrimitive

extension ListItem: CarPlayPrimitive {
    
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

extension ListItem {
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject? {
        if let section = parent as? CPListSection {
            return build(section: section, before: sibling as? CPListItem)
        }
        return nil
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if let section = component as? CPListItem,
           let template = parent as? CPListSection {
            //update(item, template: template)
        }
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if let section = component as? CPListItem,
           let section = parent as? CPListSection {
            //section.remove(section)
        }
    }
}

private extension ListItem {
    
    func buildItem() -> CPListItem {
        let action = self.action
        let listItem: CPListItem
        // create item
        if #available(iOS 14, *) {
            listItem = CPListItem(
                text: text,
                detailText: detailText,
                image: image.flatMap { .unsafe(_ImageProxy($0)) },
                accessoryImage: accessory?.image.flatMap { .unsafe(_ImageProxy($0)) },
                accessoryType: .init(accessory)
            )
        } else {
            listItem = CPListItem(
                text: text,
                detailText: detailText,
                image: image.flatMap { .unsafe(_ImageProxy($0)) }
            )
        }
        // set action handler
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
    
    func build(section: CPListSection, before sibling: CPListItem?) -> CPListItem {
        let newValue = buildItem()
        // build new section
        
        return newValue
    }
}
