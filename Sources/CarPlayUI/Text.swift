//
//  Text.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation

public struct Text: Equatable, Hashable, Codable, RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init<S>(_ string: S) where S: StringProtocol {
        self.init(rawValue: String(string))
    }
}
