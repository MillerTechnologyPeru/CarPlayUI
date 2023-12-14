//
//  Form.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

@available(iOS 14.0, *)
public struct Form <Content: View> : View {
    
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

// MARK: - CarPlayPrimitive

@available(iOS 14.0, *)
extension Form: CarPlayPrimitive {
    
    @_spi(TokamakCore)
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: { scene in
                    let children = (content as? ParentView)?.children ?? []
                    let items = children.compactMap { mapAnyView($0) { (view: InformationItem) in
                        view.informationItem
                    }}
                    let actions = children.compactMap { mapAnyView($0) { (view: TextButton) in
                        view.textButton(for: scene)
                    }}
                    return CPInformationTemplate(
                        title: "",
                        layout: .leading,
                        items: items,
                        actions: actions
                    )
                },
                update: { (target, scene) in
                    guard case let .template(template) = target.storage,
                        let informationTemplate = template as? CPInformationTemplate else {
                        return
                    }
                    let children = (content as? ParentView)?.children ?? []
                    let items = children.compactMap { mapAnyView($0) { (view: InformationItem) in
                        view.informationItem
                    }}
                    let actions = children.compactMap { mapAnyView($0) { (view: TextButton) in
                        view.textButton(for: scene)
                    }}
                    informationTemplate.items = items
                    informationTemplate.actions = actions
                },
                content: { content }
            )
        )
    }
}

// MARK: - Supporting Types

@available(iOS 14.0, *)
protocol InformationItem {
    
    var informationItem: CPInformationItem { get }
}

@available(iOS 14.0, *)
extension View where Body: InformationItem {
    
    var item: CPInformationItem {
        body.informationItem
    }
}

@available(iOS 14.0, *)
extension Text: InformationItem {
    
    var informationItem: CPInformationItem {
        .init(title: _TextProxy(self).rawText, detail: nil)
    }
}

@available(iOS 14.0, *)
extension ParentView {
    
    var informationItem: CPInformationItem {
        // extract labels
        let labels = children.prefix(2).compactMap {
            mapAnyView($0, transform: { (view: Text) in
                _TextProxy(view).rawText
            })
        }
        let rating = children.compactMap {
            mapAnyView($0, transform: { (view: Rating) in
                view
            })
        }.first
        let title = labels.count > 0 ? labels[0] : nil
        let detail = labels.count > 1 ? labels[1] : nil
        if let rating = rating {
            return CPInformationRatingItem(
                rating: rating.rating as NSNumber,
                maximumRating: rating.maximum as NSNumber,
                title: title,
                detail: detail
            )
        } else {
            return CPInformationItem(
                title: title,
                detail: detail
            )
        }
    }
}

@available(iOS 14.0, *)
extension _ConditionalContent: InformationItem { }

@available(iOS 14.0, *)
extension TupleView: InformationItem { }

@available(iOS 14.0, *)
extension ForEach: InformationItem { }

@available(iOS 14.0, *)
extension HStack: InformationItem { }

@available(iOS 14.0, *)
extension EmptyView: InformationItem {
    
    var informationItem: CPInformationItem {
        .init(title: nil, detail: nil)
    }
}

@available(iOS 14.0, *)
extension ModifiedContent: InformationItem where Content: InformationItem {
    
    var informationItem: CPInformationItem {
        content.informationItem
    }
}
