//
//  CPTemplate.swift
//
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import CarPlay

// MARK: - Coordinator

internal extension CPTemplate {
    
    var coordinator: TemplateCoordinator {
        guard let coordinator = userInfo as? TemplateCoordinator else {
            fatalError("Template \(self) userinfo \(String(describing: userInfo)) is not a TemplateCoordinator")
        }
        return coordinator
    }
}

// MARK: - NavigationStack Template

/// Template can be embedded in a navigation stack.
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

/// Template can only be presented modally.
protocol ModalTemplate { }

extension CPAlertTemplate: ModalTemplate { }

extension CPVoiceControlTemplate: ModalTemplate { }

extension CPActionSheetTemplate: ModalTemplate { }
