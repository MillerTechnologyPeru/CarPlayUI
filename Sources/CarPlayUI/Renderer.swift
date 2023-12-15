//
//  Renderer.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

import Foundation
import Dispatch
import UIKit
import CarPlay
@_spi(TokamakCore)
import TokamakCore

final class CarplayRenderer: Renderer {
    
    private(set) var reconciler: StackReconciler<CarplayRenderer>?
    
    private(set) var scene: CPTemplateApplicationScene?
    
    init() { }
    
    func connectScene(
        app: any App,
        scene: CPTemplateApplicationScene
    ) {
        self.scene = scene
        let sceneReconciler = StackReconciler(
            app: app,
            target: CarPlayTarget(scene: scene),
            environment: .defaultEnvironment, // merge environment with scene environment
            renderer: self,
            scheduler: { next in
                DispatchQueue.main.async {
                  next()
                }
            }
        )
        self.reconciler = sceneReconciler
    }
    
    func disconnectScene() {
        scene = nil
        reconciler = nil
    }
    
    /** Function called by a reconciler when a new target instance should be
     created and added to the parent (either as a subview or some other way, e.g.
     installed if it's a layout constraint).
     - parameter parent: Parent target that will own a newly created target instance.
     - parameter view: The host view that renders to the newly created target.
     - returns: The newly created target.
     */
    func mountTarget(
      before sibling: CarPlayTarget?,
      to parent: CarPlayTarget,
      with host: MountedHost
    ) -> CarPlayTarget? {
        
        // handle template view
        if let anyTemplate = mapAnyView(
            host.view,
            transform: { (template: AnyTemplate) in template }
        ) {
            switch parent.storage {
            case .application(let scene):
                // initialize template
                let newTemplate = anyTemplate.build()
                scene.interfaceController.setRootTemplate(newTemplate, animated: false) // connect to interface
                return CarPlayTarget(host.view, template: newTemplate)
            case .template(let parentTemplate):
                if #available(iOS 14.0, *), let tabBar = parentTemplate as? CPTabBarTemplate {
                    let newTemplate = anyTemplate.build()
                    var templates = tabBar.templates
                    templates.append(newTemplate)
                    tabBar.updateTemplates(templates)
                    return CarPlayTarget(host.view, template: newTemplate)
                } else {
                    assertionFailure("Only Tab Bar can be a parent template")
                    return nil
                }
            case .dashboard, .instrumentCluster, .component:
                assertionFailure("Templates can only be mounted to an CPTemplateApplicationScene or CPTabBarTemplate")
                return nil
            }
        } else if let anyComponent = mapAnyView(
            host.view,
            transform: { (component: AnyComponent) in component }
        ) {
            switch parent.storage {
            case .template(let template):
                guard let newComponent = anyComponent.build(parent: template) else {
                    return nil
                }
                return CarPlayTarget(host.view, component: newComponent)
            case .dashboard, .instrumentCluster, .application, .component:
                assertionFailure("Template components can only be a child of a CPTemplateApplicationScene")
                return nil
            }
            
        } else {
            
            // handle cases like `TupleView`
            if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
                return parent
            }
            
            return nil
        }
    }

    /** Function called by a reconciler when an existing target instance should be
     updated.
     - parameter target: Existing target instance to be updated.
     - parameter view: The host view that renders to the updated target.
     */
    func update(
      target: CarPlayTarget,
      with host: MountedHost
    ) {
        switch target.storage {
        case .application(let scene):
            return
        case .template(let template):
            guard let templateView = mapAnyView(host.view, transform: { (template: AnyTemplate) in template }) else {
                //assertionFailure("Underlying view is not a template")
                return
            }
            templateView.update(template)
            return
        case .component(let component):
            guard let componentView = mapAnyView(host.view, transform: { (component: AnyComponent) in component }) else {
                assertionFailure("Underlying view is not a component")
                return
            }
            let parentObject: NSObject
            switch host.parentTarget.storage {
            case let .template(template):
                parentObject = template
            case let .component(component):
                parentObject = component
            case .application, .dashboard, .instrumentCluster:
                return
            }
            // TODO: Update components
            componentView.update(component: component, parent: parentObject)
            return
        case .dashboard(let scene):
            return
        case .instrumentCluster(let scene):
            return
        }
        
    }
    
    /** Function called by a reconciler when an existing target instance should be
     unmounted: removed from the parent and most likely destroyed.
     - parameter target: Existing target instance to be unmounted.
     - parameter parent: Parent of target to direct interaction with parent.
     - parameter task: The state associated with the unmount.
     */
    func unmount(
      target: CarPlayTarget,
      from parent: CarPlayTarget,
      with task: UnmountHostTask<CarplayRenderer>
    ) {
        defer { task.finish() }
        
        switch target.storage {
        case .application(let scene):
            return
        case .template(let template):
            guard let templateView = mapAnyView(target.view, transform: { (template: AnyTemplate) in template }) else {
                //assertionFailure("Underlying view is not a template")
                return
            }
            // Remove from Tab Bar template
            if #available(iOS 14.0, *),
                case let .template(parentTemplate) = parent.storage,
                let tabBar = parentTemplate as? CPTabBarTemplate {
                
            }
            return
        case .component(let component):
            guard let componentView = mapAnyView(target.view, transform: { (component: AnyComponent) in component }) else {
                assertionFailure("Underlying view is not a component")
                return
            }
            let parentObject: NSObject
            switch parent.storage {
            case let .template(template):
                parentObject = template
            case let .component(component):
                parentObject = component
            case .application, .dashboard, .instrumentCluster:
                return
            }
            // TODO: Update components
            //componentView.update(component: component, parent: parentObject)
            return
        case .dashboard(let scene):
            return
        case .instrumentCluster(let scene):
            return
        }
    }

    /** Returns a body of a given pritimive view, or `nil` if `view` is not a primitive view for
     this renderer.
     */
    func primitiveBody(for view: Any) -> AnyView? {
        (view as? CarPlayPrimitive)?.renderedBody
    }

    /** Returns `true` if a given view type is a primitive view that should be deferred to this
     renderer.
     */
    func isPrimitiveView(_ type: Any.Type) -> Bool {
        type is CarPlayPrimitive.Type
    }
}

protocol CarPlayPrimitive {
    
    var renderedBody: AnyView { get }
}

internal final class CarPlayTarget: Target {
    
    enum Storage {
                
        ///  A CarPlay scene that controls your app’s user interface.
        case application(CPTemplateApplicationScene)
        
        /// CarPlay user interface templates
        case template(CPTemplate)
        
        /// CarPlay Template subview / component. These values are typically immutable, unlike the template.
        case component(NSObject)
        
        /// A CarPlay scene that controls your app’s dashboard navigation window.
        case dashboard(UIScene) // CPTemplateApplicationDashboardScene
        
        /// Instrument Cluster
        case instrumentCluster(UIScene) // CPTemplateApplicationInstrumentClusterScene
    }
    
    let storage: Storage
    
    var view: AnyView
    
    init(_ view: AnyView, template: CPTemplate) {
        assert(mapAnyView(view, transform: { (component: AnyTemplate) in component }) != nil)
        self.storage = .template(template)
        self.view = AnyView(view)
    }
    
    init(_ view: AnyView, component: NSObject) {
        assert(mapAnyView(view, transform: { (component: AnyComponent ) in component }) != nil)
        assert(component is CPTemplate == false, "\(type(of: component))")
        assert(component is UIScene == false, "\(type(of: component))")
        self.storage = .component(component)
        self.view = AnyView(view)
    }
    
    init(scene: CPTemplateApplicationScene) {
        self.storage = .application(scene)
        self.view = AnyView(EmptyView())
    }
    
    @available(iOS 13.4, *)
    init(scene: CPTemplateApplicationDashboardScene) {
        self.storage = .dashboard(scene)
        self.view = AnyView(EmptyView())
    }
    
    @available(iOS 15.4, *)
    init(scene: CPTemplateApplicationInstrumentClusterScene) {
        self.storage = .instrumentCluster(scene)
        self.view = AnyView(EmptyView())
    }
}
