//
//  Text.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation

public struct Text: Equatable, Hashable, Codable, _PrimitiveView {
    
    let variants: [String]
    
    internal var rawValue: String {
        guard let string = variants.first else {
            fatalError()
        }
        return string
    }
    
    public init<S>(_ string: S) where S: StringProtocol {
        self.init(verbatim: String(string))
    }
    
    public init(verbatim content: String) {
        self.variants = [content]
    }
    
    public init(variants: [String]) {
        assert(variants.isEmpty == false)
        self.variants = variants
    }
}

// MARK: - ExpressibleByArrayLiteral

extension Text: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: String...) {
        self.init(variants: elements)
    }
}
