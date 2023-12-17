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
    
    let action: Action
    
    public init(
        text: String?,
        detailText: String? = nil,
        image: Image? = nil,
        action: @escaping () async -> () = { }
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
        self.action = .task(action)
        self.accessory = nil
    }
    
    @available(iOS 14, *)
    public init(
        text: String?,
        detailText: String? = nil,
        image: Image? = nil,
        accessory: Accessory?,
        action: @escaping () async -> () = { }
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
        self.action = .task(action)
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

// MARK: - Action

public extension ListItem {
    
    enum Action {
        
        case task(() async -> ())
        case navigate(AnyView)
    }
}

// MARK: - Navigation Link

public extension ListItem {
    
    init<Destination: View>(
        text: String?,
        detailText: String? = nil,
        image: Image? = nil,
        destination: Destination
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
        self.action = .navigate(AnyView(destination))
        self.accessory = nil
    }
    
    @available(iOS 14, *)
    init<Destination: View>(
        text: String?,
        detailText: String? = nil,
        image: Image? = nil,
        accessory: Accessory,
        destination: Destination
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
        self.action = .navigate(AnyView(destination))
        self.accessory = accessory
    }
}

// MARK: - Coordinator

extension CPListItem {
    
    final class Coordinator {
        
        init(
            item: ListItem,
            task: @escaping () async -> ()
        ) {
            self.item = item
            self.task = task
        }
        
        var item: ListItem
        
        var task: () async -> ()
    }
}
