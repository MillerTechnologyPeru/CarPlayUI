//
//  NavigationView.swift
//
//
//  Created by Alsey Coleman Miller on 12/15/23.
//

public final class NavigationContext: ObservableObject {
    
    @Published
    var stack = [NavigationLinkDestination]()
    
    func push(_ destination: NavigationLinkDestination) {
        stack.append(destination)
    }
    
    func pop() {
        guard stack.isEmpty == false else {
            return
        }
        stack.removeLast()
    }
}

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

struct NavigationDestinationKey: EnvironmentKey {
  public static let defaultValue: Binding<AnyView>? = nil
}

extension EnvironmentValues {
  var navigationDestination: Binding<AnyView>? {
    get {
      self[NavigationDestinationKey.self]
    }
    set {
      self[NavigationDestinationKey.self] = newValue
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
