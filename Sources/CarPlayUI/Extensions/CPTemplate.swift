//
//  CPTemplate.swift
//
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import CarPlay

// MARK: - NavigationStack Template

protocol NavigationStackTemplate { 
    
    var navigationTitle: String? { get }
}

extension CPGridTemplate: NavigationStackTemplate {
    
    var navigationTitle: String? {
        title
    }
}

extension CPListTemplate: NavigationStackTemplate {
    
    var navigationTitle: String? {
        title
    }
}

@available(iOS 14.0, *)
extension CPInformationTemplate: NavigationStackTemplate { 
    
    var navigationTitle: String? {
        title
    }
}

@available(iOS 14.0, *)
extension CPPointOfInterestTemplate: NavigationStackTemplate { 
    
    var navigationTitle: String? {
        title
    }
}

// MARK: - Modal Template

protocol ModalTemplate { }

extension CPAlertTemplate: ModalTemplate { }

extension CPVoiceControlTemplate: ModalTemplate { }

extension CPActionSheetTemplate: ModalTemplate { }
