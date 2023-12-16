//
//  TemplateCoordinator.swift
//
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import CarPlay

protocol TemplateCoordinator: AnyObject {
        
    func willAppear(animated: Bool)
    
    func didAppear(animated: Bool)
    
    func willDisappear(animated: Bool)
    
    func didDisappear(animated: Bool)
}

extension TemplateCoordinator {
    
    func willAppear(animated: Bool) {
        
    }
    
    func didAppear(animated: Bool) {
        
    }
    
    func willDisappear(animated: Bool) {
        
    }
    
    func didDisappear(animated: Bool) {
        
    }
}
