//
//  TemplateApplicationSceneDelegate.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

import Foundation
import CarPlay

/// Car Play Scene Delegate
@objc(CarplayUITemplateApplicationSceneDelegate)
public final class TemplateApplicationSceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    // MARK: - Properties
    
    private(set) var interfaceController: CPInterfaceController?
    
    var activeNavigationContext: NavigationContext?
    
    static var rootTemplate: CPTemplate? {
        didSet {
            Self.shared?.updateControllerRootTemplate()
        }
    }
    
    // MARK: - Initialization
    
    public static var shared: TemplateApplicationSceneDelegate? {
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
    
    private func didConnect(_ interfaceController: CPInterfaceController, scene: CPTemplateApplicationScene) {
        
        // connect to interface controller
        self.interfaceController = interfaceController
        interfaceController.delegate = self
        
        // remount templates
        updateControllerRootTemplate()
        
        // update renderer with environment
        
    }
    
    private func didDisconnect(_ interfaceController: CPInterfaceController, scene: CPTemplateApplicationScene) {
        
        interfaceController.delegate = nil
        self.interfaceController = nil
    }
    
    // MARK: - CPTemplateApplicationSceneDelegate
    
    /**
     The CarPlay screen has connected and is ready to present content.
     
     Your app should create its view controller and assign it to the @c rootViewController property
     of this window.
     
     @note The interfaceController object will be strongly retained by the CPTemplateApplicationScene, the delegate does not need to retain it.
     
     @note This method is provided only for navigation apps; other apps should use the variant that does not provide a window.
     */
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
        didConnect(interfaceController, scene: templateApplicationScene)
    }

    
    /**
     The CarPlay screen has connected and is ready to present content.
     
     Your app should create its view controller and assign it to the @c rootViewController property
     of this window.
     
     @note The interfaceController object will be strongly retained by the CPTemplateApplicationScene, the delegate does not need to retain it.
      */
    @available(iOS 14.0, *)
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        didConnect(interfaceController, scene: templateApplicationScene)
    }
    
    /**
     The CarPlay screen has disconnected.
     
     @note This method is provided only for navigation apps; other apps should use the variant that does not provide a window.
     */
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController, from window: CPWindow) {
        didDisconnect(interfaceController, scene: templateApplicationScene)
    }
    
    /**
     The CarPlay screen has disconnected.
     */
    @available(iOS 14.0, *)
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        didDisconnect(interfaceController, scene: templateApplicationScene)
    }

    
    /**
     If your application posts a @c CPNavigationAlert while backgrounded, a notification banner may be presented to the user.
     If the user taps on that banner, your application will launch on the car screen and this method will be called
     with the alert the user tapped.
     */
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didSelect navigationAlert: CPNavigationAlert) {
        
    }

    
    /**
     If your application posts a @c CPManeuver while backgrounded, a notification banner may be presented to the user.
     If the user taps on that banner, your application will launch on the car screen and this method will be called
     with the maneuver the user tapped.
     */
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didSelect maneuver: CPManeuver) {
        
    }

    
    /**
     The CarPlay system suggested content style for this scene has changed.
     */
    @available(iOS 15.4, *)
    public func contentStyleDidChange(_ contentStyle: UIUserInterfaceStyle) {
        
    }
}

// MARK: - CPInterfaceControllerDelegate

extension TemplateApplicationSceneDelegate: CPInterfaceControllerDelegate {
    
    public func templateWillAppear(_ template: CPTemplate, animated: Bool) {
        (template.userInfo as? TemplateCoordinator)?.willAppear(animated: animated)
    }

    public func templateDidAppear(_ template: CPTemplate, animated: Bool) {
        (template.userInfo as? TemplateCoordinator)?.didAppear(animated: animated)
        
    }

    public func templateWillDisappear(_ template: CPTemplate, animated: Bool) {
        (template.userInfo as? TemplateCoordinator)?.willDisappear(animated: animated)
    }

    public func templateDidDisappear(_ template: CPTemplate, animated: Bool) {
        (template.userInfo as? TemplateCoordinator)?.didDisappear(animated: animated)
    }
}
