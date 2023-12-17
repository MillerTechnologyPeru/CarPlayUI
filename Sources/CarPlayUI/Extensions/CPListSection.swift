//
//  CPListSection.swift
//
//
//  Created by Alsey Coleman Miller on 12/17/23.
//

import Foundation
import CarPlay

internal extension CPListSection {
    
    convenience init(
        _ section: ListSection,
        userInfo: (ListItem) -> Any? = { _ in return nil }
    ) {
        self.init(
            items: section.items.map { CPListItem($0, userInfo: userInfo($0)) },
            header: section.header,
            sectionIndexTitle: section.sectionIndexTitle
        )
        assert(self.items.count == section.items.count)
    }
    
    func _isEqual(to other: CPListSection) -> Bool {
        guard self.items.count == other.items.count else {
            return false
        }
        for (index, item) in self.items.enumerated() {
            guard let otherItem = other.items[index] as? CPListItem, 
                let listItem = item as? CPListItem else {
                assertionFailure()
                return false
            }
            guard listItem._isEqual(to: otherItem) else {
                return false
            }
        }
        return true
    }
}
