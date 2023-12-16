//
//  NavigationLink.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

public struct NavigationLink<Label, Destination>: View where Label: View, Destination: View {
    
    @State
    var destination: NavigationDestination
    
    let label: Label
    
    @EnvironmentObject
    var navigationContext: NavigationContext
  
    @Environment(\._navigationLinkStyle)
    var style
    
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        _destination = State(wrappedValue: NavigationDestination(destination))
        self.label = label()
    }
    
    public var body: some View {
        Button(action: {
            navigationActivated()
        }, label: {
            label
        })
        // destination is child view
        if isActive {
            destination.view
        }
    }
}

private extension NavigationLink {
    
    func navigationActivated() {
        // set active stack
        TemplateApplicationSceneDelegate.shared?.activeNavigationContext = navigationContext
        // update context
        navigationContext.push(destination)
    }
    
    var isActive: Bool {
        navigationContext.stack.firstIndex(where: { $0 === destination }) != nil
    }
}

public extension NavigationLink where Label == Text {
    /// Creates an instance that presents `destination`, with a `Text` label
    /// generated from a title string.
    init<S>(_ title: S, destination: Destination) where S: StringProtocol {
        self.init(destination: destination) { Text(title) }
    }
}
        
// MARK: - Supporting Types
        
final class NavigationDestination {
    
    let view: AnyView
    
    let _id: AnyHashable?
    
    init<V: View>(
        _ destination: V,
        id: AnyHashable? = nil
    ) {
        view = AnyView(destination)
        _id = id
    }
}

extension NavigationDestination: Identifiable {
    
    var id: AnyHashable {
        _id ?? AnyHashable(ObjectIdentifier(self))
    }
}
