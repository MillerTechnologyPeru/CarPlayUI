//
//  EnvironmentValues.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

import Foundation
import TokamakCore

extension EnvironmentValues {
    
    /// Returns default settings for the CarPlay environment
    static var defaultEnvironment: Self {
        var environment = EnvironmentValues()
        environment[_ColorSchemeKey.self] = .light
        return environment
    }
}
