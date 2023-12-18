//
//  CPPointOfInterest.swift
//
//
//  Created by Alsey Coleman Miller on 12/17/23.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
internal extension CPPointOfInterest {
    
    convenience init(_ view: ViewObject) {
        if #available(iOS 16.0, *) {
            self.init(
                location: view.location,
                title: view.title,
                subtitle: view.subtitle,
                summary: view.summary,
                detailTitle: view.detailTitle,
                detailSubtitle: view.detailSubtitle,
                detailSummary: view.detailSummary,
                pinImage: view.pinImage.flatMap { .unsafe($0) },
                selectedPinImage: view.selectedPinImage.flatMap { .unsafe($0) }
            )
        } else {
            self.init(
                location: view.location,
                title: view.title,
                subtitle: view.subtitle,
                summary: view.summary,
                detailTitle: view.detailTitle,
                detailSubtitle: view.detailSubtitle,
                detailSummary: view.detailSummary,
                pinImage: view.pinImage.flatMap { .unsafe($0) }
            )
        }
        // set buttons
        self.buttons = view.buttons.prefix(2).enumerated().map { (index, buttonView) in
            CPTextButton(
                title: buttonView.title,
                textStyle: .init(role: buttonView.role),
                handler: { [weak buttonView] _ in
                    buttonView?.action()
            })
        }
    }
    
    var buttons: [CPTextButton] {
        get {
            [primaryButton, secondaryButton].compactMap { $0 }
        }
        set {
            assert(newValue.count <= 2, "Can add a maximum of 2 buttons")
            primaryButton = newValue.count > 0 ? newValue[0] : nil
            secondaryButton = newValue.count > 1 ? newValue[1] : nil
        }
    }
    
    func insert(_ button: CPTextButton, before sibling: CPTextButton? = nil) {
        // move to before sibling
        if let sibling, let index = buttons.firstIndex(of: sibling) {
            buttons.insert(button, before: index)
        } else {
            // append to end
            buttons.append(button)
        }
    }
    
    func update(oldValue: CPTextButton, newValue: CPTextButton) {
        guard let index = buttons.firstIndex(where: { $0 === oldValue }) else {
            assertionFailure("Unable to find item in graph")
            return
        }
        // update with new instance at index
        buttons[index] = newValue
    }
    
    func remove(button: CPTextButton) {
        guard let index = buttons.firstIndex(where: { $0 === button }) else {
            return
        }
        buttons.remove(at: index)
    }
}
