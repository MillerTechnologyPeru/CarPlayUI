//
//  CPPointOfInterest.swift
//
//
//  Created by Alsey Coleman Miller on 12/17/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
internal extension CPPointOfInterest {
    
    convenience init(_ view: ViewObject) {
        if #available(iOS 16.0, *) {
            self.init(
                location: view.location,
                title: view.title,
                subtitle: view.subtitle,
                summary: view.summary,
                detailTitle: view.detailTitle,
                detailSubtitle: view.detailSubtitle,
                detailSummary: view.detailSummary,
                pinImage: view.pinImage.flatMap { .unsafe($0) },
                selectedPinImage: view.selectedPinImage.flatMap { .unsafe($0) }
            )
        } else {
            self.init(
                location: view.location,
                title: view.title,
                subtitle: view.subtitle,
                summary: view.summary,
                detailTitle: view.detailTitle,
                detailSubtitle: view.detailSubtitle,
                detailSummary: view.detailSummary,
                pinImage: view.pinImage.flatMap { .unsafe($0) }
            )
        }
    }
    
    func isEqual<Content: View>(to view: PointOfInterest<Content>) -> Bool {
        return self.title == view.title
            && self.subtitle == view.subtitle
            && self.summary == view.summary
            && self.location == view.location
            && self.detailTitle == view.detailTitle
            && self.detailSubtitle == view.detailSubtitle
            && self.detailSummary == view.detailSummary
            //&& self.pinImage == view.pinImage // TODO: Compare images
    }
}
