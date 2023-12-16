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


final class CarplayRenderer: Renderer {
    
    private(set) var reconciler: StackReconciler<CarplayRenderer>!
        
    private static var rootTemplate: CPTemplate? {
        get {
            TemplateApplicationSceneDelegate.rootTemplate
        }
        set {
            TemplateApplicationSceneDelegate.rootTemplate = newValue
        }
    }
    
    private var interfaceController: CPInterfaceController? {
        TemplateApplicationSceneDelegate.shared?.interfaceController
    }
    
    public static var shared: CarplayRenderer {
        CarPlayAppCache.renderer
    }
    
    init(app: any App) {
        self.reconciler = StackReconciler(
            app: app,
            target: CarPlayTarget.application,
            environment: .defaultEnvironment, // merge environment with scene environment
            renderer: self,
            scheduler: { next in
                DispatchQueue.main.async {
                  next()
                }
            }
        )
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
            case .application:
                // initialize template
                let newTemplate = anyTemplate.build()
                Self.rootTemplate = newTemplate // set root template on Scene delegate
                return CarPlayTarget(host.view, template: newTemplate)
            case .template(let parentTemplate):
                let newTemplate = anyTemplate.build()
                if newTemplate is ModalTemplate {
                    // can only be presented modally
                    guard let interfaceController else {
                        assertionFailure("Missing interface controller")
                        return nil
                    }
                    interfaceController.presentTemplate(newTemplate, animated: true)
                } else if #available(iOS 14.0, *),
                    let tabBar = parentTemplate as? CPTabBarTemplate {
                    // add as tab view child
                    tabBar.insert(newTemplate, before: sibling?.template)
                } else if newTemplate is NavigationStackTemplate {
                    // push to navigation stack
                    guard let interfaceController else {
                        assertionFailure("Missing interface controller")
                        return nil
                    }
                    // associate destination with template
                    newTemplate.coordinator.navigationDestination = TemplateApplicationSceneDelegate.shared?.activeNavigationContext?.stack.last
                    // push controller
                    interfaceController.pushTemplate(newTemplate, animated: true)
                } else {
                    assertionFailure("Invalid parent \(parentTemplate) for \(newTemplate)")
                    return nil
                }
                return CarPlayTarget(host.view, template: newTemplate)
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
                guard let newComponent = anyComponent.build(parent: template, before: sibling?.component) else {
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
        case .application:
            return // nothing to do
        case .template(let template):
            guard let templateView = mapAnyView(host.view, transform: { (template: AnyTemplate) in template }) else {
                //assertionFailure("Underlying view is not a template")
                return
            }
            templateView.update(template)
            return
        case .component(var component):
            guard let componentView = mapAnyView(host.view, transform: { (component: AnyComponent) in component }) else {
                //assertionFailure("Underlying view is not a component")
                return
            }
            let parentObject: NSObject
            switch host.parentTarget.storage {
            case let .template(template):
                parentObject = template
            case let .component(component):
                parentObject = component
            case .application:
                assertionFailure("Invalid parent")
                return
            case .dashboard, .instrumentCluster:
                assertionFailure("Not implemented")
                return
            }
            // Update component
            componentView.update(component: &component, parent: parentObject)
            target.update(component: component) // might be new instance
            return
        case .dashboard:
            return
        case .instrumentCluster:
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
        case .application:
            return // do nothing
        case .template(let template):
            guard let templateView = mapAnyView(target.view, transform: { (template: AnyTemplate) in template }) else {
                //assertionFailure("Underlying view is not a template")
                return
            }
            if case let .template(parentTemplate) = parent.storage {
                if template is ModalTemplate,
                    let interfaceController,
                    interfaceController.presentedTemplate == template {
                    // dismiss modal template
                    interfaceController.dismissTemplate(animated: true)
                } else if #available(iOS 14.0, *),
                   let tabBar = parentTemplate as? CPTabBarTemplate,
                   let index = tabBar.templates.firstIndex(of: template) {
                    // Remove from Tab Bar template
                    var templates = tabBar.templates
                    templates.remove(at: index)
                    tabBar.updateTemplates(templates)
                } else if template is NavigationStackTemplate,
                    let interfaceController,
                    interfaceController.templates.contains(where: { $0 === template }),
                    interfaceController.templates.firstIndex(of: parentTemplate) != nil {
                    // attempt to pop to parent programatically
                    interfaceController.pop(to: parentTemplate, animated: true)
                }
            } else if case .application = parent.storage {
                // remove from root view
                Self.rootTemplate = nil // set root template on Scene delegate
            }
            return
        case .component(let component):
            guard let componentView = mapAnyView(target.view, transform: { (component: AnyComponent) in component }) else {
                //assertionFailure("Underlying view is not a component")
                return
            }
            let parentObject: NSObject
            switch parent.storage {
            case let .template(template):
                parentObject = template
            case let .component(component):
                parentObject = component
            case .application:
                assertionFailure("Invalid parent")
                return
            case .dashboard, .instrumentCluster:
                assertionFailure("Not implemented")
                return
            }
            // unmount
            componentView.remove(component: component, parent: parentObject)
            return
        case .dashboard:
            return
        case .instrumentCluster:
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
        case application
        
        /// CarPlay user interface templates
        case template(CPTemplate)
        
        /// CarPlay Template subview / component. These values are typically immutable, unlike the template.
        case component(NSObject)
        
        /// A CarPlay scene that controls your app’s dashboard navigation window.
        case dashboard
        
        /// Instrument Cluster
        case instrumentCluster
        
        /// Navigation Destination and Context
        //case navigation(NavigationDestination, NavigationContext)
    }
    
    private(set) var storage: Storage
    
    var view: AnyView
    
    private init<V: View>(_ view: V, _ storage: Storage) {
        self.view = AnyView(view)
        self.storage = storage
    }
    
    init(_ view: AnyView, template: CPTemplate) {
        assert(mapAnyView(view, transform: { (component: AnyTemplate) in component }) != nil)
        self.storage = .template(template)
        self.view = view
    }
    
    init(_ view: AnyView, component: NSObject) {
        assert(mapAnyView(view, transform: { (component: AnyComponent ) in component }) != nil)
        assert(component is CPTemplate == false, "\(type(of: component))")
        assert(component is UIScene == false, "\(type(of: component))")
        self.storage = .component(component)
        self.view = view
    }
    /*
    init(navigation destination: NavigationDestination, context: NavigationContext) {
        self.storage = .navigation(destination, context)
        self.view = destination.view
    }
    */
    static var application: CarPlayTarget {
        .init(EmptyView(), .application)
    }
    
    @available(iOS 13.4, *)
    static var dashboard: CarPlayTarget {
        .init(EmptyView(), .dashboard)
    }
    
    @available(iOS 15.4, *)
    static var instrumentCluster: CarPlayTarget {
        .init(EmptyView(), .instrumentCluster)
    }
}

internal extension CarPlayTarget {
    
    var template: CPTemplate? {
        get {
            guard case let .template(template) = storage else {
                return nil
            }
            return template
        }
    }
    
    var component: NSObject? {
        get {
            guard case let .component(component) = storage else {
                return nil
            }
            return component
        }
    }
    
    func update(component: NSObject) {
        guard case .component = storage else {
            assertionFailure("Not component target \(storage)")
            return
        }
        storage = .component(component)
    }
}
