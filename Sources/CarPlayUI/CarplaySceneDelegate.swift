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
    
    private(set) var interfaceController: CPInterfaceController?
    
    static var rootTemplate: CPTemplate? {
        didSet {
            Self.shared?.updateControllerRootTemplate()
        }
    }
    
    // MARK: - Initialization
    
    public static var shared: CarplaySceneDelegate? {
        CarPlayAppCache.sceneDelegate
    }
    
    public override init() {
        super.init()
        
        // store singleton
        CarPlayAppCache.sceneDelegate = self
    }
    
    // MARK: - Methods
    
    private func updateControllerRootTemplate() {
        
        if let template = Self.rootTemplate, let controller = interfaceController {
            controller.setRootTemplate(template, animated: true)
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
        updateControllerRootTemplate()
    }
    
    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController,
        from window: CPWindow
    ) {
        self.interfaceController = nil
        
        // inform controller
        
    }
}
