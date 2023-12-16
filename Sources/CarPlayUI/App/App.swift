//
//  App.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

import Foundation
import UIKit
import CarPlay
import Combine

public extension CarPlayUI.App {
    
    @MainActor
    static func _launch(_ app: Self, with configuration: _AppConfiguration) {
        // create renderer
        let renderer = CarplayRenderer(app: app)
        CarPlayAppCache.renderer = renderer
        CarPlayAppCache.configuration = configuration
    }

    static func _setTitle(_ title: String) { }

    var _phasePublisher: AnyPublisher<ScenePhase, Never> {
        CurrentValueSubject(.active).eraseToAnyPublisher()
    }

    var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> {
        CurrentValueSubject(.light).eraseToAnyPublisher()
    }
}

internal enum CarPlayAppCache {
    
    static var renderer: CarplayRenderer!
    
    static var sceneDelegate: TemplateApplicationSceneDelegate?
    
    static var configuration: _AppConfiguration?
}
