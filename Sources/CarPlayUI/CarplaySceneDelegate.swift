//
//  CarPlayDelegate.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

import Foundation
import CarPlay

/// Car Play Scene Delegate
public final class CarplaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    // MARK: - Properties
    
    var interfaceController: CPInterfaceController?
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        
        // store singleton
        CarPlayAppCache.sceneDelegate = self
    }
    
    // MARK: - Methods
    
    private func startRendering() {
        guard let interfaceController = self.interfaceController else {
            return
        }
        
    }
    
    // MARK: - CPTemplateApplicationSceneDelegate
    
    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController,
        to window: CPWindow
    ) {
        self.interfaceController = interfaceController
        
        // remount templates
        let app = CarPlayAppCache.app!
        CarPlayAppCache.renderer.connectScene(app: app, scene: templateApplicationScene)
    }
    
    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController,
        from window: CPWindow
    ) {
        self.interfaceController = nil
        CarPlayAppCache.renderer.disconnectScene(templateApplicationScene)
    }
}
