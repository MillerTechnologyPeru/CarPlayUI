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
    
    private(set) var reconcilers = [UIScene: StackReconciler<CarplayRenderer>]()
    
    init() { }
    
    func connectScene(
        app: any App,
        scene: CPTemplateApplicationScene
    ) {
        let sceneReconciler = StackReconciler(
            app: app,
            target: CarPlayTarget(scene),
            environment: .defaultEnvironment, // merge environment with scene environment
            renderer: self,
            scheduler: { next in
                DispatchQueue.main.async {
                  next()
                }
            }
        )
        self.reconcilers[scene] = sceneReconciler
    }
    
    func disconnectScene(_ scene: UIScene) {
        reconcilers.removeValue(forKey: scene)
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
        guard let anyWidget = mapAnyView(
          host.view,
          transform: { (widget: AnyTemplate) in widget }
        ) else {
          // handle cases like `TupleView`
          if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
            return parent
          }

          return nil
        }
                
        switch parent.storage {
        case .scene(let scene):
            // initialize template
            let newTemplate = anyWidget.build(scene)
            scene.interfaceController.setRootTemplate(newTemplate, animated: false) // connect to interface
            return CarPlayTarget(host.view, newTemplate)
        case .template(let parentTemplate):
            if #available(iOS 14.0, *), let tabBar = parentTemplate as? CPTabBarTemplate {
                //let oldTemplates = tabBar.templates
                //oldTemplates.append()
                //tabBar.updateTemplates()
                return nil
            } else {
                return nil
            }
        case .dashboard(let scene):
            return nil
        case .instrumentCluster(let scene):
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
        guard let template = mapAnyView(host.view, transform: { (template: AnyTemplate) in template })
            else { return }
        
        template.update(target)
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

        guard mapAnyView(task.host.view, transform: { (widget: AnyTemplate) in widget }) != nil
            else { return }
        
        
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
        case scene(CPTemplateApplicationScene)
        
        /// CarPlay user interface templates
        case template(CPTemplate)
        
        /// A CarPlay scene that controls your app’s dashboard navigation window.
        case dashboard(UIScene) // CPTemplateApplicationDashboardScene
        
        /// Instrument Cluster
        case instrumentCluster(UIScene) // CPTemplateApplicationInstrumentClusterScene
    }
    
    let storage: Storage
    
    var view: AnyView
    
    init<V: View>(_ view: V, _ template: CPTemplate) {
        self.storage = .template(template)
        self.view = AnyView(view)
    }

    init(_ template: CPTemplate) {
        self.storage = .template(template)
        self.view = AnyView(EmptyView())
    }
    
    init(_ scene: CPTemplateApplicationScene) {
        self.storage = .scene(scene)
        self.view = AnyView(EmptyView())
    }
    
    @available(iOS 13.4, *)
    init(_ scene: CPTemplateApplicationDashboardScene) {
        self.storage = .dashboard(scene)
        self.view = AnyView(EmptyView())
    }
    
    @available(iOS 15.4, *)
    init(_ scene: CPTemplateApplicationInstrumentClusterScene) {
        self.storage = .instrumentCluster(scene)
        self.view = AnyView(EmptyView())
    }
}
