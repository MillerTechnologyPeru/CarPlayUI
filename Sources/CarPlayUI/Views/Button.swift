//
//  Button.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

public extension ButtonRole {
    
    static var confirm: ButtonRole { ButtonRole(rawValue: 2) }
}

@available(iOS 14.0, *)
protocol TextButton {
    
    func textButton(for scene: CPTemplateApplicationScene) -> CPTextButton
}

@available(iOS 14.0, *)
extension Button: TextButton where Label == Text {
    
    func textButton(for scene: CPTemplateApplicationScene) -> CPTextButton {
        CPTextButton(
            title: _TextProxy(label).rawText,
            textStyle: .init(role: role),
            handler: { _ in
                action()
            }
        )
    }
}

@available(iOS 14.0, *)
extension _Button: TextButton where Label == Text {
    
    func textButton(for scene: CPTemplateApplicationScene) -> CPTextButton {
        CPTextButton(
            title: _TextProxy(label).rawText,
            textStyle: .init(role: role),
            handler: { _ in
                action()
            }
        )
    }
}

@available(iOS 14.0, *)
extension NavigationLink: TextButton where Label == Text {
    
    func textButton(for scene: CPTemplateApplicationScene) -> CPTextButton {
        CPTextButton(
            title: _TextProxy(label).rawText,
            textStyle: .normal,
            handler: { _ in
                // TODO: Navigation
            }
        )
    }
}

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
