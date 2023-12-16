//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation

internal extension Int {
    
    func filterNSNotFound() -> Int? {
        self == NSNotFound ? nil : self
    }
}

internal extension Int? {
    
    func toFoundation() -> NSInteger {
        self ?? NSNotFound
    }
}
