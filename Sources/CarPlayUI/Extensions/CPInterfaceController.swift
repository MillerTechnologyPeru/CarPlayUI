//
//  CPInterfaceController.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay

internal extension CPInterfaceController {
    
    var traitCollection: UITraitCollection? {
        if #available(iOS 14.0, *) {
            return carTraitCollection
        } else {
            return nil
        }
    }
}
