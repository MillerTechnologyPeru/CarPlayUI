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
        content
            .environmentObject(context)
        ForEach(context.stack) { destination in
            destination.view
                .environmentObject(context)
        }
    }
}

// MARK: - Supporting Types

internal final class NavigationContext: ObservableObject {
    
    @Published
    var stack = [NavigationDestination]()
    
    func push(_ destination: NavigationDestination) {
        stack.append(destination)
    }
    
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
