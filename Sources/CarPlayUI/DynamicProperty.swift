//
//  DynamicProperty.swift
//  
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation

public protocol DynamicProperty {
  mutating func update()
}

public extension DynamicProperty {
  mutating func update() {}
}
