//
//  CPListItem.swift
//
//
//  Created by Alsey Coleman Miller on 12/17/23.
//

import Foundation
import CarPlay

internal extension CPListItem {
    
    convenience init(_ item: ListItem, userInfo: Any? = nil) {
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
        self.userInfo = userInfo
    }
}

internal extension CPListItem {
    
    func _isEqual(to other: CPListItem) -> Bool {
        if #available(iOS 14, *) {
            return self.text == other.text
                && self.detailText == other.detailText
                && self.image == other.image
                && self.accessoryType == other.accessoryType
                && self.accessoryImage == other.accessoryImage
        } else {
            return self.text == other.text
                && self.detailText == other.detailText
                && self.image == other.image
        }
    }
}
