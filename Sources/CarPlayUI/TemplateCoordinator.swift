//
//  TemplateCoordinator.swift
//
//
//  Created by Alsey Coleman Miller on 12/16/23.
//

import Foundation
import CarPlay

@MainActor
protocol TemplateCoordinator: AnyObject {

    /// Mirrors the `.onAppear(perform:)` closure attached to the template's root view.
    var appearAction: (() -> Void)? { get set }

    /// Mirrors the `.onDisappear(perform:)` closure attached to the template's root view.
    var disappearAction: (() -> Void)? { get set }

    /// Whether this template has ever appeared on screen.
    var hasAppeared: Bool { get set }

    func willAppear(animated: Bool)

    func didAppear(animated: Bool)

    func willDisappear(animated: Bool)

    func didDisappear(animated: Bool)
}

@MainActor
protocol NavigationStackTemplateCoordinator: TemplateCoordinator {

    var navigationDestination: NavigationDestination? { get set }

    var navigationContext: NavigationContext? { get set }
}

extension TemplateCoordinator {

    func willAppear(animated: Bool) {

    }

    /// The very first appearance is already covered by the view's mount-time
    /// `onAppear`, so only forward re-appearances (e.g. navigating back to this
    /// template after it was covered by a pushed template).
    func didAppear(animated: Bool) {
        defer { hasAppeared = true }
        guard hasAppeared else { return }
        appearAction?()
    }

    func willDisappear(animated: Bool) {

    }

    func didDisappear(animated: Bool) {

    }
}
