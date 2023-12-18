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
