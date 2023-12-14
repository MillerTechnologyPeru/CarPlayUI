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
public struct Rating: View {
    
    let rating: Double
    
    let maximum: Double
    
    public init(
        rating: Double = 0.0,
        maximum: Double = 5.0
    ) {
        assert(maximum <= 5.0)
        self.rating = rating
        self.maximum = maximum
    }
    
    // Should never be called
    public var body: some View {
        Text("\(rating)/\(maximum)")
    }
}

@available(iOS 14.0, *)
extension Rating: InformationItem {
    
    var informationItem: CPInformationItem {
        CPInformationRatingItem(
            rating: rating as NSNumber,
            maximumRating: maximum as NSNumber,
            title: nil,
            detail: nil
        )
    }
}
