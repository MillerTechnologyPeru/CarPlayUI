//
//  CPListItem.swift
//
//
//  Created by Alsey Coleman Miller on 12/17/23.
//

import Foundation
import CarPlay

internal extension CPListItem {
    
    convenience init(_ item: ListItem) {
        // create item
        if #available(iOS 14, *) {
            self.init(
                text: item.text,
                detailText: item.detailText,
                image: item.image.flatMap { .unsafe(_ImageProxy($0)) },
                accessoryImage: item.accessory?.image.flatMap { .unsafe(_ImageProxy($0)) },
                accessoryType: .init(item.accessory)
            )
        } else {
            self.init(
                text: item.text,
                detailText: item.detailText,
                image: item.image.flatMap { .unsafe(_ImageProxy($0)) }
            )
        }
        /*
        // set action handler
        if #available(iOS 14.0, *) {
            self.handler = { (item, completion) in
                Task(priority: .userInitiated) {
                    await action()
                    await MainActor.run {
                        completion()
                    }
                }
            }
        }
        */
    }
}
