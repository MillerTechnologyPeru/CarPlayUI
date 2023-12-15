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
        } else if let template = parent as? CPGridTemplate {
            return build(template: template, before: sibling as? CPGridButton)
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
        } else if let gridButton = component as? CPGridButton,
           let template = parent as? CPGridTemplate {
            component = self.update(gridButton, template: template)
        }
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if #available(iOS 14, *),
           let action = component as? CPTextButton,
           let template = parent as? CPInformationTemplate {
            template.remove(action: action)
        } else if let gridButton = component as? CPGridButton,
            let template = parent as? CPGridTemplate {
            template.remove(button: gridButton)
        }
    }
}

@available(iOS 14.0, *)
extension Button where Label == Text {
    
    func buildTextButton() -> CPTextButton {
        CPTextButton(button: self)
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
            let label = self.label as? Text {
            let title = _TextProxy(label).rawText
            if let template = parent as? CPInformationTemplate {
                return buildTextButton(title: title, template: template, before: sibling as? CPTextButton)
            } else if let template = parent as? CPPointOfInterestTemplate {
                return buildTextButton(title: title, template: template, before: sibling as? CPTextButton)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func update(component: inout NSObject, parent: NSObject) {
        if #available(iOS 14, *),
           let button = self as? Button<Text>,
           let action = component as? CPTextButton {
            if let template = parent as? CPInformationTemplate {
                component = button.update(action, template: template)
            } else if let pointOfInterest = parent as? CPPointOfInterest {
                // FIXME: POI Navigation
                //component = button.update(action, pointOfInterest: pointOfInterest)
            } else {
                // do nothing, navigation embedded in invalid template
                return
            }
        } else if let gridButton = component as? CPGridButton,
           let template = parent as? CPGridTemplate {
            component = self.update(gridButton, template: template)
        }
    }
    
    func remove(component: NSObject, parent: NSObject) {
        if #available(iOS 14, *),
           let action = component as? CPTextButton,
           let template = parent as? CPInformationTemplate {
            template.remove(action: action)
        } else if let gridButton = component as? CPGridButton,
            let template = parent as? CPGridTemplate {
            template.remove(button: gridButton)
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
        template: CPInformationTemplate,
        before sibling: CPTextButton?
    ) -> CPTextButton {
        let button = buildTextButton(title: title)
        template.insert(button, before: sibling)
        return button
    }
    
    func buildTextButton(
        title: String,
        template: CPPointOfInterestTemplate,
        before sibling: CPTextButton?
    ) -> CPTextButton {
        let button = buildTextButton(title: title)
        assertionFailure("Not implemented")
        return button
    }
}

