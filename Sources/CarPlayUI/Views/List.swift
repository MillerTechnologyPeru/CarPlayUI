//
//  List.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

extension List: CarPlayPrimitive {
    
    @_spi(TokamakCore)
    public var renderedBody: AnyView {
        let proxy = _ListProxy(self)
        let children = (proxy.content as? ParentView)?.children ?? []
        return AnyView(
            TemplateView(
                build: {
                    CPListTemplate(title: nil, sections: [])
                }, update: { template in
                    
                }, content: {
                    proxy.content
                }
            )
        )
    }
}
