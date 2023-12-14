//
//  Button.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay
import TokamakCore

@available(iOS 14.0, *)
protocol TextButton {
    
    var textButton: CPTextButton { get }
}

@available(iOS 14.0, *)
extension Button: TextButton where Label == Text {
    
    var textButton: CPTextButton {
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
    
    var textButton: CPTextButton {
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
internal extension CPTextButtonStyle {
    
    init(role: ButtonRole?) {
        guard let role else {
            self = .normal
            return
        }
        switch role {
        case .cancel:
            self = .cancel
        case .destructive:
            self = .confirm
        default:
            self = .normal
        }
    }
}
