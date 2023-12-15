//
//  Rating.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

/// CarPlay Rating View
@available(iOS 14.0, *)
public struct Rating: View, _PrimitiveView {
    
    let title: String?
    
    let detail: String?
    
    let rating: Double
    
    let maximum: Double
    
    public init(
        title: Text? = nil,
        detail: Text? = nil,
        rating: Double = 0.0,
        maximum: Double = 5.0
    ) {
        assert(maximum <= 5.0)
        self.rating = rating
        self.maximum = maximum
        self.title = title.flatMap { _TextProxy($0).rawText }
        self.detail = detail.flatMap { _TextProxy($0).rawText }
    }
    
    public var body: Never {
      neverBody(String(reflecting: Self.self))
    }
}

@available(iOS 14.0, *)
extension Rating: AnyComponent {
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject? {
        if let template = parent as? CPInformationTemplate {
            return build(template: template, before: sibling as? CPInformationItem)
        } else {
            assertionFailure("Invalid parent: \(parent)")
            return nil
        }
    }
    
    func buildRatingItem() -> CPInformationRatingItem {
        CPInformationRatingItem(
            rating: rating as NSNumber,
            maximumRating: maximum as NSNumber,
            title: title,
            detail: detail
        )
    }
    
    func build(template: CPInformationTemplate, before sibling: CPInformationItem?) -> CPInformationRatingItem {
        let informationItem = buildRatingItem()
        template.insert(informationItem, before: sibling)
        return informationItem
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if let item = component as? CPInformationRatingItem,
           let template = parent as? CPInformationTemplate {
            component = update(item, template: template)
        }
    }
    
    func update(_ oldValue: CPInformationRatingItem, template: CPInformationTemplate) -> CPInformationRatingItem {
        let newValue = buildRatingItem()
        template.update(oldValue: oldValue, newValue: newValue)
        return newValue
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if let item = component as? CPInformationRatingItem,
           let template = parent as? CPInformationTemplate {
            remove(item, template: template)
        }
    }
    
    func remove(_ item: CPInformationRatingItem, template: CPInformationTemplate) {
        template.remove(item: item)
    }
}
