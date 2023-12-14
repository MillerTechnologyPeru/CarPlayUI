//
//  WindowGroup.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

extension WindowGroup: SceneDeferredToRenderer {
    
    public var deferredBody: AnyView {
        AnyView(content)
    }
}
