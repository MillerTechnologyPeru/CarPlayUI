//
//  CPTextButton.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
internal extension CPTextButton {
    
    convenience init(button: Button<Text>) {
        let title = _TextProxy(button.label).rawText
        let textStyle = CPTextButtonStyle(role: button.role)
        let action = button.action
        self.init(
            title: title,
            textStyle: textStyle,
            handler: { _ in
                action()
            }
        )
    }
}
