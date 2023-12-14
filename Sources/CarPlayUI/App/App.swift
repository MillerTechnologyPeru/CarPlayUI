//
//  App.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

import Foundation
import UIKit
import CarPlay
import TokamakCore
import Combine

public extension TokamakCore.App {
    
    static func _launch(_ app: Self, with configuration: _AppConfiguration) {
        // create renderer
        let renderer = CarplayRenderer()
        CarPlayAppCache.renderer = renderer
        CarPlayAppCache.app = app
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
    
    static var sceneDelegate: CarplaySceneDelegate!
    
    static var renderer: CarplayRenderer!
    
    static var app: (any App)?
    
    static var configuration: _AppConfiguration?
}
