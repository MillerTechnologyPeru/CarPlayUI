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
                build: { scene in
                    var items = [String]()
                    for element in children {
                        if let text = mapAnyView(element, transform: { (view: Text) in view }) {
                            let string = _TextProxy(text).rawText
                            items.append(string)
                        }
                    }
                    return CPListTemplate(title: nil, sections: [
                        CPListSection(items: items.map { .init(text: $0, detailText: nil) })
                    ])
                }, update: { _, _ in
                    
                }, content: {
                    proxy.content
                }
            )
        )
    }
}

protocol ListSection {
    
    var listItems: [CPListItem] { get }
}

@available(iOS 14.0, *)
protocol ListItem {
    
    var item: CPListTemplateItem { get }
}

