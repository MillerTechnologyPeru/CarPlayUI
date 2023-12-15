//
//  Text.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

extension Text: AnyComponent {
        
    func build(parent: NSObject) -> NSObject? {
        if #available(iOS 14.0, *), let template = parent as? CPInformationTemplate {
            return build(template: template)
        } else {
            return nil
        }
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if #available(iOS 14, *),
           let item = component as? CPInformationItem,
           let template = parent as? CPInformationTemplate {
            let view = FormItem(title: _TextProxy(self).rawText)
            component = view.update(item, template: template)
        }
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if #available(iOS 14, *),
           let item = component as? CPInformationItem,
           let template = parent as? CPInformationTemplate {
            remove(item, template: template)
        }
    }
    
    @available(iOS 14.0, *)
    func remove(_ item: CPInformationItem, template: CPInformationTemplate) {
        template.remove(item: item)
    }
}
