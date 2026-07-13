//
//  List.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import CarPlay

extension List: View { //where SelectionValue == Int {
    
    public var body: some View {
        ToolbarReader { (title, toolbar, onAppear, onDisappear) in
            Template(
                title: title.map { _TextProxy($0).rawText },
                selection: nil,//selection.single,
                onAppear: onAppear,
                onDisappear: onDisappear,
                content: content
            )
        }
    }
}

private extension List._Selection {
    
    var single: Binding<SelectionValue?>? {
        switch self {
        case let .one(binding):
            return binding
        case .many:
            return nil
        }
    }
}

// MARK: - CarPlayPrimitive

extension List {
    
    struct Template: View {

        let title: String?

        let selection: Binding<Int?>?

        let onAppear: (() -> ())?

        let onDisappear: (() -> ())?

        let content: Content

        var body: Content {
            content
        }
    }
}

extension List.Template: CarPlayPrimitive {
    
    public var renderedBody: AnyView {
        AnyView(
            TemplateView(
                build: {
                    let coordinator = CPListTemplate.Coordinator(
                        selection: self.selection
                    )
                    coordinator.appearAction = onAppear
                    coordinator.disappearAction = onDisappear
                    let template = CPListTemplate(
                        title: title,
                        sections: []
                    )
                    template.userInfo = coordinator
                    template.delegate = coordinator
                    return template
                },
                update: { (template: CPListTemplate) in
                    // update title
                    if template.title != title {
                        assertionFailure("Cannot dynamically change title")
                    }
                    template._coordinator.appearAction = onAppear
                    template._coordinator.disappearAction = onDisappear
                },
                content: { content }
            )
        )
    }
}

// MARK: - Coordinator

public extension CPListTemplate {
    
    final class Coordinator: NSObject, NavigationStackTemplateCoordinator {

        let selection: Binding<Int?>?

        var navigationDestination: NavigationDestination?

        var navigationContext: NavigationContext?

        var appearAction: (() -> Void)?

        var disappearAction: (() -> Void)?

        var hasAppeared = false

        fileprivate var lastSelection: Int?

        var sections = [CPListSection]()
                
        fileprivate init(
            selection: Binding<Int?>?
        ) {
            self.selection = selection
            super.init()
        }
    }
}

internal extension CPListTemplate {
    
    var _coordinator: Coordinator! {
        userInfo as? Coordinator
    }
    
    var _sections: [CPListSection] {
        get {
            _coordinator.sections
        }
        set {
            if #available(iOS 14.0, *) {
                assert(newValue.count <= CPListTemplate.maximumSectionCount, "Cannot display more than \(CPListTemplate.maximumSectionCount) sections")
            }
            _coordinator.sections = newValue
            updateSections(newValue)
        }
    }
    
    func insert(_ section: CPListSection, before sibling: CPListSection? = nil) {
        // move to before sibling
        if let sibling, let index = _sections.firstIndex(where: { $0 === sibling }) {
            _sections.insert(section, before: index)
        } else {
            // append to end
            _sections.append(section)
        }
    }
    
    func update(oldValue: CPListSection, newValue: CPListSection) {
        guard let index = _sections.firstIndex(where: { $0 === oldValue }) else {
            assertionFailure("Unable to find item in graph")
            return
        }
        // update with new instance at index
        _sections[index] = newValue
    }
    
    func remove(_ section: CPListSection) {
        guard let index = _sections.firstIndex(where: { $0 === section }) else {
            return
        }
        _sections.remove(at: index)
    }
}

// MARK: - CPListTemplateDelegate

extension CPListTemplate.Coordinator: CPListTemplateDelegate {
    
    @MainActor
    public func listTemplate(_ listTemplate: CPListTemplate, didSelect item: CPListItem) async {
        guard let coordinator = item.userInfo as? CPListItem.Coordinator else {
            assertionFailure()
            return
        }
        // action
        await coordinator.task()
    }
}
