//
//  UITabBarItem.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

import Foundation
import UIKit

@available(iOS 14.0, *)
internal extension UITabBarItem.SystemItem {
    
    init(_ systemItem: TabItem.SystemItem) {
        switch systemItem {
        case .bookmarks:
            self = .bookmarks
        case .contacts:
            self = .contacts
        case .downloads:
            self = .downloads
        case .favorites:
            self = .favorites
        case .featured:
            self = .featured
        case .history:
            self = .history
        case .more:
            self = .more
        case .mostRecent:
            self = .mostRecent
        case .mostViewed:
            self = .mostViewed
        case .recents:
            self = .recents
        case .search:
            self = .search
        case .topRated:
            self = .topRated
        }
    }
}
