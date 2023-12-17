//
//  NavigationView.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

public struct NavigationView<Content>: View where Content: View {
    
    let content: Content

    @StateObject
    var context = NavigationContext()

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        // root view
        rootView
        
        // pushed navigation stack views
        ForEach(Array(context.stack.enumerated()), id: \.offset) { (index, destination) in
            NavigationItemView(
                navigationContext: context,
                navigationDestination: destination
            )
        }
    }
}

private extension NavigationView {
    
    var rootView: some View {
        content
            .environmentObject(context)
    }
}

// MARK: - Supporting Types

internal final class NavigationContext: ObservableObject {
    
    @Published
    var stack = [NavigationDestination]()
    
    @MainActor
    func push(_ destination: NavigationDestination) {
        guard stack.firstIndex(where: { $0 === destination }) == nil else {
            assertionFailure("View already in stack")
            return
        }
        stack.append(destination)
    }
    
    @MainActor
    func pop() {
        guard stack.isEmpty == false else {
            return
        }
        stack.removeLast()
    }
}

internal struct ToolbarReader<Content>: View where Content: View {
  let content: (_ title: AnyView?, _ toolbarContent: [AnyToolbarItem]?) -> Content

  var body: some View {
    ToolbarKey._delay {
      $0._force { bar in
        NavigationTitleKey._delay {
          $0
            ._force {
              content($0, bar.items.isEmpty && $0 == nil ? nil : bar.items)
            }
        }
      }
    }
  }
}

struct NavigationTitleKey: PreferenceKey {
  typealias Value = AnyView?
  static func reduce(value: inout AnyView?, nextValue: () -> AnyView?) {
    value = nextValue()
  }
}

struct NavigationBarItemKey: PreferenceKey {
  static let defaultValue: NavigationBarItem = .init(displayMode: .automatic)
  static func reduce(value: inout NavigationBarItem, nextValue: () -> NavigationBarItem) {
    value = nextValue()
  }
}

internal protocol AnyNavigation {
    
    var navigationContext: NavigationContext { get }
    
    var navigationDestination: NavigationDestination { get }
}

extension NavigationView {
    
    struct Item: View, _PrimitiveView, CarPlayPrimitive {
        
        let navigationContext: NavigationContext
        
        let navigationDestination: NavigationDestination
        
        var body: Never {
            neverBody(String(reflecting: Self.self))
        }
        
        var renderedBody: AnyView {
            AnyView(
                NavigationItemView(
                    navigationContext: navigationContext,
                    navigationDestination: navigationDestination
                )
            )
        }
    }
}

internal struct NavigationItemView: View, _PrimitiveView, AnyNavigation {
    
    let navigationContext: NavigationContext
    
    let navigationDestination: NavigationDestination
    
    var body: Never {
        neverBody("NavigationItemView")
    }
}

extension NavigationItemView: ParentView {
    
    var children: [AnyView] {
        [AnyView(
            navigationDestination.view
                .environmentObject(navigationContext)
        )]
    }
}
