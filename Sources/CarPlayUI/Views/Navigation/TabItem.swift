//
//  TabItem.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import UIKit
import CarPlay

@available(iOS 14.0, *)
public struct TabItem: Equatable, Hashable, Codable, _PrimitiveView {
    
    let storage: Storage
    
    public init(title: Text, image: Image? = nil) {
        self.storage = .custom(title, image)
    }
    
    public init(system: UITabBarItem.SystemItem) {
        self.storage = .system(system.rawValue)
    }
}

// MARK: - Supporting Types

@available(iOS 14.0, *)
internal extension TabItem {
    
    enum Storage: Equatable, Hashable, Codable {
        
        case custom(Text, Image?)
        case system(UITabBarItem.SystemItem.RawValue)
    }
}

@available(iOS 14.0, *)
struct TabItemKey: PreferenceKey {
  typealias Value = TabItem?
  static func reduce(value: inout TabItem?, nextValue: () -> TabItem?) {
    value = nextValue()
  }
}
