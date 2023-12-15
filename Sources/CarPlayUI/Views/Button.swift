//
//  Button.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

// MARK: - ButtonRole

public extension ButtonRole {
    
    static var confirm: ButtonRole { ButtonRole(rawValue: 2) }
}

// MARK: - CarPlayPrimitive

extension Button: CarPlayPrimitive {
    
    var renderedBody: AnyView {
        AnyView(
            ComponentView(build: { parent in
                build(parent: parent)
            }, update: { (component, parent) in
                
            }, remove: { (component, parent) in
                
            }, content: {
                
            })
        )
    }
    
    func build(parent: NSObject) -> NSObject? {
        if #available(iOS 14.0, *), 
            let button = self as? Button<Text>,
            let template = parent as? CPInformationTemplate {
            return button.build(template: template)
        } else {
            return nil
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
    
    func build(template: CPInformationTemplate) -> CPTextButton {
        let button = buildTextButton()
        template.actions.append(button)
        return button
    }
}

extension NavigationLink: CarPlayPrimitive {
    
    var renderedBody: AnyView {
        AnyView(
            ComponentView(build: { parent in
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
        template.actions.append(button)
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

