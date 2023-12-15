//
//  Button.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay

// MARK: - ButtonRole

public extension ButtonRole {
    
    static var confirm: ButtonRole { ButtonRole(rawValue: 2) }
}

// MARK: - CarPlayPrimitive

extension Button: CarPlayPrimitive {
    
    var renderedBody: AnyView {
        AnyView(
            ComponentView(build: { parent, sibling in
                build(parent: parent, before: sibling)
            }, update: { (component, parent) in
                update(component: &component, parent: parent)
            }, remove: { (component, parent) in
                remove(component: component, parent: parent)
            }, content: {
                body
            })
        )
    }
    
    func build(parent: NSObject, before sibling: NSObject?) -> NSObject? {
        if #available(iOS 14.0, *),
            let button = self as? Button<Text>,
            let template = parent as? CPInformationTemplate {
            return button.build(template: template, before: sibling as? CPTextButton)
        } else {
            return nil
        }
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if #available(iOS 14, *),
           let button = self as? Button<Text>,
           let action = component as? CPTextButton,
           let template = parent as? CPInformationTemplate {
            component = button.update(action, template: template)
        }
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if #available(iOS 14, *),
           let action = component as? CPTextButton,
           let template = parent as? CPInformationTemplate {
            template.remove(action: action)
        }
    }
}

@available(iOS 14.0, *)
extension Button where Label == Text {
    
    func buildTextButton() -> CPTextButton {
        let title = _TextProxy(self.label).rawText
        let button = CPTextButton(
            title: title,
            textStyle: CPTextButtonStyle(role: role),
            handler: { _ in
                action()
            }
        )
        return button
    }
    
    func build(template: CPInformationTemplate, before sibling: CPTextButton? = nil) -> CPTextButton {
        let button = buildTextButton()
        template.insert(button, before: sibling)
        return button
    }
    
    func update(_ oldValue: CPTextButton, template: CPInformationTemplate) -> CPTextButton {
        let newValue = buildTextButton()
        template.update(oldValue: oldValue, newValue: newValue)
        return newValue
    }
}

extension NavigationLink: CarPlayPrimitive {
    
    var renderedBody: AnyView {
        AnyView(
            ComponentView(build: { (parent, sibling) in
                build(parent: parent)
            }, update: { (component, parent) in
                
            }, remove: { (component, parent) in
                
            }, content: {
                
            })
        )
    }
    
    func build(parent: NSObject) -> NSObject? {
        if #available(iOS 14.0, *),
            let label = self.label as? Text {
            let title = _TextProxy(label).rawText
            if let template = parent as? CPInformationTemplate {
                return buildTextButton(title: title, template: template)
            } else if let template = parent as? CPPointOfInterestTemplate {
                return buildTextButton(title: title, template: template)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

@available(iOS 14.0, *)
private extension NavigationLink {
    
    func buildTextButton(title: String) -> CPTextButton {
        
        let button = CPTextButton(
            title: title,
            textStyle: .normal,
            handler: { _ in
                //action()
                // todo
            }
        )
        return button
    }
    
    func buildTextButton(
        title: String,
        template: CPInformationTemplate
    ) -> CPTextButton {
        let button = buildTextButton(title: title)
        template.insert(button, before: nil)
        return button
    }
    
    func buildTextButton(
        title: String,
        template: CPPointOfInterestTemplate
    ) -> CPTextButton {
        let button = buildTextButton(title: title)
        assertionFailure("Not implemented")
        return button
    }
}

