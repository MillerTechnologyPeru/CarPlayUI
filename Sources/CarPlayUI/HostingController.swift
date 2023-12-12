//
//  HostingController.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import CarPlay

public extension CPTemplate {
    
    /// Initialize a template with a hosting controller.
    static func hosting<Content: View>(_ view: Content, interface: CPInterfaceController) -> CPTemplate {
        if let templateView = view.reduce(GridTemplateView.self).first {
            return templateView.makeTemplate(
                rootView: view,
                controller: interface
            )
        } else {
            return CPGridTemplate(title: "", gridButtons: []) // default
        }
    }
}

internal extension CPTemplate {
    
    final class HostingController <V: View, T: Template> {
        
        private(set) var rootView: V
        
        let coordinator: T.Coordinator
        
        weak var interface: CPInterfaceController!
        
        fileprivate init(
            rootView: V,
            template: T,
            controller: CPInterfaceController
        ) {
            self.rootView = rootView
            self.coordinator = template.makeCoordinator()
            self.interface = controller
        }
    }
}

extension CPTemplate.HostingController {
    
    func templateWillAppear(_ template: CPTemplate, animated: Bool) {
        
    }

    func templateDidAppear(_ template: CPTemplate, animated: Bool) {
        
    }

    func templateWillDisappear(_ template: CPTemplate, animated: Bool) {
        
    }

    func templateDidDisappear(_ template: CPTemplate, animated: Bool) {
        
    }
}

internal extension Template {
    
    func makeTemplate<Content: View>(
        rootView: Content,
        controller: CPInterfaceController
    ) -> CarPlayType {
        let controller = CPTemplate.HostingController<Content, Self>(
            rootView: rootView,
            template: self,
            controller: controller
        )
        let context = Context(
            coordinator: controller.coordinator,
            transaction: ._active ?? .init(animation: nil),
            environment: .init()
        )
        let template = self.makeTemplate(context: context)
        template.userInfo = controller
        return template
    }
}
