//
//  Template.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import CarPlay

public protocol Template {
    
    associatedtype CarPlayType: CPTemplate
    
    func makeTemplate() -> CarPlayType
    
    func updateTemplate(_ template: CarPlayType)
}
