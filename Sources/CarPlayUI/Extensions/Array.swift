//
//  Array.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

internal extension Array {
    
    func inserting(_ element: Element, before index: Int) -> Array<Element> {
        Array(self.prefix(upTo: index))
            + [element]
            + Array(self.suffix(from: index))
    }
    
    mutating func insert(_ element: Element, before index: Int) {
        self = inserting(element, before: index)
    }
}
