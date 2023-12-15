//
//  Grid.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

public struct Grid <Content: View> : View {
    
    let content: Content
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    public var body: some View {
        ToolbarReader { (title, toolbar) in
            return Template(
                title: title.flatMap { mapAnyView($0, transform: { (view: Text) in _TextProxy(view).rawText }) } ?? "",
                content: content
            )
        }
    }
}

extension Grid {
    
    struct Template: View {
        
        let title: String
        
        let content: Content
        
        public var body: Content {
            content
        }
    }
}

extension Grid.Template: CarPlayPrimitive {
    
    @_spi(TokamakCore)
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: {
                    CPGridTemplate(
                        title: title,
                        gridButtons: []
                    )
                },
                update: { gridTemplate in
                    
                    guard #available(iOS 15.0, *) else {
                        assertionFailure("Unable to update grid content")
                        return
                    }
                    
                    if gridTemplate.title != title {
                        gridTemplate.updateTitle(title)
                    }
                },
                content: { content }
            )
        )
    }
}
