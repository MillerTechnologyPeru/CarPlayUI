//
//  Grid.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay

public struct Grid <Content: View> : View {
        
    let storage: Storage
    
    public init(
        forceStatic: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        let content = content()
        if #available(iOS 15, *), forceStatic == false {
            storage = .dynamic(content)
        } else {
            // extract buttons
            let children = (content as? ParentView)?.children ?? []
            let buttons = children.compactMap { mapAnyView($0) { (view: GridButton) in
                view.gridButton()
            }}.prefix(8)
            storage = .static(Array(buttons))
        }
    }
    
    public var body: some View {
        ToolbarReader { (title, toolbar) in
            return Template(
                title: title.flatMap { mapAnyView($0, transform: { (view: Text) in _TextProxy(view).rawText }) } ?? "",
                storage: storage
            )
        }
    }
}

extension Grid {
    
    enum Storage {
        
        case `static`([CPGridButton])
        case dynamic(Content) // iOS 15 required
    }
    
    struct Template: View {
        
        let title: String
        
        let storage: Storage
                
        var body: AnyView {
            storage.view
        }
    }
}

// MARK: - Supporting Types

extension Grid.Storage {
    
    var buttons: [CPGridButton] {
        switch self {
        case .static(let buttons):
            return buttons
        case .dynamic:
            return []
        }
    }
    
    var view: AnyView {
        switch self {
        case .static:
            return AnyView(EmptyView())
        case let .dynamic(content):
            return AnyView(content)
        }
    }
}

// MARK: - CarPlayPrimitive

extension Grid.Template: CarPlayPrimitive {
    
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: {
                    let coordinator = CPGridTemplate.Coordinator()
                    let initialButtons = storage.buttons
                    coordinator.isImmutable = !initialButtons.isEmpty
                    let template = CPGridTemplate(
                        title: title,
                        gridButtons: initialButtons // load initial buttons
                    )
                    template.userInfo = coordinator
                    return template
                },
                update: { (gridTemplate: CPGridTemplate) in
                    
                    // update title
                    if gridTemplate.title != title {
                        guard #available(iOS 15.0, *) else {
                            assertionFailure("Unable to update grid content")
                            return
                        }
                        gridTemplate.updateTitle(title)
                    }
                },
                content: {
                    storage.view
                }
            )
        )
    }
}

// MARK: - Coordinator

internal extension CPGridTemplate {
    
    final class Coordinator: NavigationStackTemplateCoordinator {
        
        var navigationDestination: NavigationDestination?
        
        var navigationContext: NavigationContext?
        
        fileprivate(set) var isImmutable = false
        
        fileprivate(set) var gridButtons = [CPGridButton]()
        
        fileprivate init() { }
    }
}

internal extension CPGridTemplate {
    
    var _coordinator: Coordinator! {
        userInfo as? Coordinator
    }
    
    private var _gridButtons: [CPGridButton] {
        get {
            _coordinator.gridButtons
        }
        set {
            guard _coordinator.isImmutable == false else {
                assertionFailure("Buttons cannot be modified")
                return
            }
            // When there are more than eight buttons in the array, the template displays only the first eight.
            let gridButtons = Array(newValue.prefix(8))
            // store original instance
            _coordinator.gridButtons = gridButtons
            // send to CarPlay IPC
            if #available(iOS 15.0, *) {
                self.updateGridButtons(gridButtons)
            } else {
                assertionFailure("Unable to update grid buttons prior to iOS 15")
            }
        }
    }
    
    func insert(_ item: CPGridButton, before sibling: CPGridButton? = nil) {
        // move to before sibling
        if let sibling, let index = _gridButtons.firstIndex(of: sibling) {
            _gridButtons.insert(item, before: index)
        } else {
            // append to end
            _gridButtons.append(item)
        }
    }
    
    func update(oldValue: CPGridButton, newValue: CPGridButton) {
        guard let index = _gridButtons.firstIndex(where: { $0 === oldValue }) else {
            assertionFailure("Unable to find item in graph")
            return
        }
        // update with new instance at index
        _gridButtons[index] = newValue
    }
    
    func remove(button: CPGridButton) {
        guard let index = _gridButtons.firstIndex(where: { $0 === button }) else {
            return
        }
        _gridButtons.remove(at: index)
    }
}

// MARK: - Grid Button

extension Button {
    
    func buildGridButton() -> CPGridButton? {
        let action = self.action
        return mapAnyView(AnyView(label), transform: { (view: ParentView) in view })
            .flatMap { CPGridButton(label: $0, action: { _ in action() }) }
    }
    
    func build(template: CPGridTemplate, before sibling: CPGridButton? = nil) -> CPGridButton? {
        guard let newButton = buildGridButton() else {
            return nil
        }
        template.insert(newButton, before: sibling)
        return newButton
    }
    
    func update(_ oldValue: CPGridButton, template: CPGridTemplate) -> CPGridButton {
        guard let newValue = buildGridButton() else {
            assertionFailure("Could not extract grid button")
            return oldValue
        }
        template.update(oldValue: oldValue, newValue: newValue)
        return newValue
    }
}

protocol GridButton {
    
    func gridButton() -> CPGridButton
}

extension Button: GridButton where Label: ParentView {
    
    func gridButton() -> CPGridButton {
        CPGridButton(label: label) { _ in
            action()
        }
    }
}
