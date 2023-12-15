//
//  TabBar.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

@available(iOS 14.0, *)
public struct TabView <Content: View> : View {
    
    let content: Content
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    public var body: Content {
        content
    }
}

@available(iOS 14.0, *)
extension TabView: CarPlayPrimitive {
    
    @_spi(TokamakCore)
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: {
                    CPTabBarTemplate(templates: [])
                },
                update: { template in
                    
                },
                content: { content }
            )
        )
    }
}

