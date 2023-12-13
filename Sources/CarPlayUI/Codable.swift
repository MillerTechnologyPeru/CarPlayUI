//
//  Codable.swift
//
//
//  Created by Alsey Coleman Miller on 12/12/23.
//

import Foundation
import CarPlay

/// Encodable state of templates
public enum TemplateState: Equatable, Hashable, Codable {
    
    case tabBar(TabBar)
    case grid(Grid)
    case information(Information)
}

public extension TemplateState {
    
    var title: String? {
        switch self {
        case .tabBar:
            return nil
        case .grid(let template):
            return template.title
        case .information(let template):
            return template.title
        }
    }
    
    var children: [TemplateState] {
        switch self {
        case .tabBar(let tabBar):
            return tabBar.children
        default:
            return []
        }
    }
}

internal extension CPTemplate {
    
    static func template(
        with state: TemplateState,
        traitCollection: UITraitCollection? = nil,
        action: @escaping (Int, Int) -> ()
    ) -> CPTemplate {
        switch state {
        case .tabBar(let tabBar):
            guard #available(iOS 14.0, *) else {
                fatalError("API Unavailable")
            }
            return CPTabBarTemplate(tabBar, traitCollection: traitCollection, action: action)
        case .grid(let grid):
            return CPGridTemplate(grid, traitCollection: traitCollection) { index in
                action(0, index)
            }
        case .information(let information):
            guard #available(iOS 14.0, *) else {
                fatalError("API Unavailable")
            }
            return CPInformationTemplate(information, traitCollection: traitCollection) { index in
                action(0, index)
            }
        }
    }
}

// MARK: - Tab

public extension TemplateState {
    
    struct TabBar: Codable, Equatable, Hashable {
        
        public var selection: Int?
        
        public var children: [TemplateState]
    }
}

@available(iOS 14.0, *)
internal extension CPTabBarTemplate {
    
    convenience init(
        _ value: TemplateState.TabBar,
        traitCollection: UITraitCollection? = nil,
        action: @escaping (Int, Int) -> ()
    ) {
        let templates = value.children.enumerated().map { (index, template) in
            CPTemplate.template(with: template, traitCollection: traitCollection) { (templateIndex, buttonIndex) in
                assert(templateIndex == 0, "Cannot have nested Tab Bar")
                action(index, buttonIndex)
            }
        }
        assert(templates.allSatisfy { $0 is CPTabBarTemplate == false })
        self.init(templates: templates)
        
        // update selection
        if #available(iOS 17, *), let index = value.selection {
            self.selectTemplate(at: index)
        }
    }
    
    func update(
        _ newValue: TemplateState.TabBar,
        from oldValue: TemplateState.TabBar
    ) {
        
        // update selection
        if #available(iOS 17, *),
           oldValue.selection != newValue.selection,
           let newIndex = newValue.selection,
           let oldIndex = selectedTemplate.flatMap({ templates.firstIndex(of: $0) }),
           newIndex != oldIndex {
            // change selection
            self.selectTemplate(at: newIndex)
        }
    }
}

// MARK: - Grid

public extension TemplateState {
    
    struct Grid: Codable, Equatable, Hashable {
        
        public var title: String
        
        public var buttons: [Button]
    }
}

public extension TemplateState.Grid {
    
    struct Button: Codable, Equatable, Hashable {
        
        public var title: Text
        
        public var image: Image
        
        public var isEnabled: Bool
    }
}

internal extension CPGridTemplate {
    
    convenience init(
        _ value: TemplateState.Grid,
        traitCollection: UITraitCollection? = nil,
        action: @escaping (Int) -> ()
    ) {
        let buttons = value.buttons.enumerated().map { (index, button) in
            CPGridButton(button, traitCollection: traitCollection) {
                action(index)
            }
        }
        self.init(
            title: value.title,
            gridButtons: buttons
        )
    }
    
    func update(
        _ newValue: TemplateState.Grid,
        from oldValue: TemplateState.Grid,
        traitCollection: UITraitCollection? = nil,
        action: @escaping (Int) -> ()
    ) -> Bool {
        // cannot update in iOS 14
        guard #available(iOS 15, *) else {
            return false
        }
        // update title
        if oldValue.title != newValue.title {
            updateTitle(newValue.title)
        }
        // update buttons
        if oldValue.buttons != newValue.buttons {
            let buttons = newValue.buttons.enumerated().map { (index, button) in
                CPGridButton(button, traitCollection: traitCollection) {
                    action(index)
                }
            }
            updateGridButtons(buttons)
        }
        return true
    }
}

internal extension CPGridButton {
    
    convenience init(
        _ button: TemplateState.Grid.Button,
        traitCollection: UITraitCollection? = nil,
        action: @escaping () -> ()
    ) {
        self.init(
            titleVariants: button.title.variants,
            image: .unsafe(button.image, traitCollection: traitCollection)) { _ in
            action()
        }
        self.isEnabled = button.isEnabled
    }
}

// MARK: - Information

public extension TemplateState {
    
    struct Information: Codable, Equatable, Hashable {
        
        public var title: String
        
        public var layout: Layout
        
        public var items: [Item]
        
        public var actions: [TextButton]
    }
}

public extension TemplateState.Information {
    
    enum Layout: String, Codable, CaseIterable {
        
        case leading
        
        case twoColumn
    }
}

public extension TemplateState.Information {
    
    /// A data object that provides content for an information template.
    enum Item: Codable, Equatable, Hashable {
        
        case information(InformationItem)
        case rating(Rating)
    }
}

public extension TemplateState.Information.Item {
    
    /// A data object that provides content for an information template.
    struct InformationItem: Codable, Equatable, Hashable {
        
        /// The text that the template displays as the item’s title.
        public var title: String?
        
        /// The text that the template displays below or beside the item’s title.
        public var detail: String?
    }
}

public extension TemplateState.Information.Item {
    
    /// A data object that provides rated content for an information template.
    struct Rating: Codable, Equatable, Hashable {
        
        public var title: String?
        
        public var detail: String?
        
        public var rating: Double
        
        public var maximumRating: UInt
    }
}

@available(iOS 14.0, *)
internal extension CPInformationTemplate {
    
    convenience init(
        _ value: TemplateState.Information,
        traitCollection: UITraitCollection? = nil,
        action: @escaping (Int) -> ()
    ) {
        let buttons = value.actions.enumerated().map { (index, button) in
            CPTextButton(button) {
                action(index)
            }
        }
        self.init(
            title: value.title,
            layout: .init(value.layout),
            items: value.items.map { .item(with: $0) },
            actions: buttons
        )
    }
    
    func update(
        _ newValue: TemplateState.Information,
        from oldValue: TemplateState.Information,
        traitCollection: UITraitCollection? = nil,
        action: @escaping (Int) -> ()
    ) -> Bool {
        // must create new template object if layout changed
        if oldValue.layout != newValue.layout {
            return false
        }
        // update title
        if oldValue.title != newValue.title {
            self.title = newValue.title
        }
        // update items
        if oldValue.items != newValue.items {
            self.items = newValue.items.map { .item(with: $0) }
        }
        // update buttons
        if oldValue.actions != newValue.actions {
            let buttons = newValue.actions.enumerated().map { (index, button) in
                CPTextButton(button) {
                    action(index)
                }
            }
            self.actions = actions
        }
        return true
    }
}

@available(iOS 14.0, *)
internal extension CPInformationItem {
    
    static func item(with value: TemplateState.Information.Item) -> CPInformationItem {
        switch value {
        case let .information(item):
            return CPInformationItem(
                title: item.title,
                detail: item.detail
            )
        case let .rating(rating):
            return CPInformationRatingItem(
                rating: rating.rating as NSNumber,
                maximumRating: rating.maximumRating as NSNumber,
                title: rating.title,
                detail: rating.detail
            )
        }
    }
}

@available(iOS 14.0, *)
internal extension CPInformationTemplateLayout {
    
    init(_ value: TemplateState.Information.Layout) {
        switch value {
        case .leading:
            self = .leading
        case .twoColumn:
            self = .twoColumn
        }
    }
}

// MARK: - Text Button

public extension TemplateState {
    
    struct TextButton: Codable, Equatable, Hashable {
        
        public var title: String
        
        public var textStyle: TextStyle
    }
}

public extension TemplateState.TextButton {
    
    /// The styles a button can apply to its title to communicate its action.
    enum TextStyle: String, Codable, CaseIterable {
        
        /// A style that indicates the button performs an action other than to confirm or cancel.
        case normal
        
        /// A style that indicates the button cancels an action and doesn’t change data.
        case cancel
        
        /// A style that indicates the button confirms an action and changes data.
        case confirm
    }
}

@available(iOS 14.0, *)
internal extension CPTextButton {
    
    convenience init(
        _ value: TemplateState.TextButton,
        action: @escaping () -> ()
    ) {
        self.init(
            title: value.title,
            textStyle: .init(value.textStyle),
            handler: { _ in
                action()
            }
        )
    }
}

@available(iOS 14.0, *)
internal extension CPTextButtonStyle {
    
    init(_ value: TemplateState.TextButton.TextStyle) {
        switch value {
        case .normal:
            self = .normal
        case .cancel:
            self = .cancel
        case .confirm:
            self = .confirm
        }
    }
}
