//
//  CPPointOfInterestTemplate.swift
//
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
internal extension CPPointOfInterestTemplate {
    
    func insert(_ item: CPPointOfInterest, before sibling: CPPointOfInterest? = nil) {
        var items = self.pointsOfInterest
        // move to before sibling
        if let sibling, let index = items.firstIndex(of: sibling) {
            items.insert(item, before: index)
        } else {
            // append to end
            items.append(item)
        }
        // update points of interest
        setPointsOfInterest(items, selectedIndex: selectedIndex)
    }
    
    func update(
        oldValue: CPPointOfInterest,
        newValue: CPPointOfInterest
    ) {
        var items = self.pointsOfInterest
        guard let index = items.firstIndex(where: { $0 === oldValue }) else {
            assertionFailure("Unable to find item in graph")
            return
        }
        // update with new instance at index
        items[index] = newValue
        // update points of interest
        setPointsOfInterest(items, selectedIndex: selectedIndex)
    }
    
    func remove(_ item: CPPointOfInterest) {
        var items = self.pointsOfInterest
        guard let index = items.firstIndex(where: { $0 === item }) else {
            return
        }
        items.remove(at: index)
        // update points of interest
        setPointsOfInterest(items, selectedIndex: selectedIndex)
    }
}
