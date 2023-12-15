//
//  CPTextButtonStyle.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
internal extension CPTextButtonStyle {
    
    init(role: ButtonRole?) {
        guard let role else {
            self = .normal
            return
        }
        switch role {
        case .cancel:
            self = .cancel
        case .confirm:
            self = .confirm
        case .destructive:
            self = .confirm
        default:
            self = .normal
        }
    }
}
