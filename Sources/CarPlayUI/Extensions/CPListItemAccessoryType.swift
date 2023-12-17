//
//  CPListItemAccessoryType.swift
//
//
//  Created by Alsey Coleman Miller on 12/17/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
internal extension CPListItemAccessoryType {
    
    init(_ accessory: ListItem.Accessory?) {
        switch accessory {
        case .image:
            self = .none
        case .disclosureIndicator:
            self = .disclosureIndicator
        case .cloud:
            self = .cloud
        case nil:
            self = .none
        }
    }
}
