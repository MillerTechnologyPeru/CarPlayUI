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
public struct TabItem {
    
    let storage: Storage
    
    public init(title: Text, image: Image? = nil) {
        self.storage = .custom(title, image)
    }
    
    public init(system: UITabBarItem.SystemItem) {
        self.storage = .system(system)
    }
}

// MARK: - Supporting Types

@available(iOS 14.0, *)
internal extension TabItem {
    
    enum Storage {
        
        case custom(Text, Image?)
        case system(UITabBarItem.SystemItem)
    }
}

@available(iOS 14.0, *)
struct TabItemKey: PreferenceKey {
  typealias Value = TabItem?
  static func reduce(value: inout TabItem?, nextValue: () -> TabItem?) {
    value = nextValue()
  }
}

@available(iOS 14.0, *)
extension View {
    
    public func tabItem<V>(@ViewBuilder _ label: () -> Text) -> some View where V : View {
        return tabItem(TabItem(title: label(), image: nil))
    }
    
    public func tabItem<V>(@ViewBuilder _ label: () -> Label<Text, Image>) -> some View where V : View {
        let label = label()
        return tabItem(TabItem(title: label.title, image: label.icon))
    }
    
    public func tabItem(system: UITabBarItem.SystemItem) -> some View {
        tabItem(.init(system: system))
    }
    
    public func tabItem<S>(title: S, image: Image? = nil) -> some View where S: StringProtocol {
        tabItem(.init(title: Text(title), image: image))
    }
    
    internal func tabItem(_ tabItem: TabItem) -> some View {
        preference(key: TabItemKey.self, value: tabItem)
    }
}
