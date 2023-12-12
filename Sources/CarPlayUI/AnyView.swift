//
//  AnyView.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

/// A type-erased view.
public struct AnyView: _PrimitiveView {
  /// The type of the underlying `view`.
  let type: Any.Type

  /** The name of the unapplied generic type of the underlying `view`. `Button<Text>` and
   `Button<Image>` types are different, but when reconciling the tree of mounted views
   they are treated the same, thus the `Button` part of the type (the type constructor)
   is stored in this property.
   */
  let typeConstructorName: String

  /// The actual `View` value wrapped within this `AnyView`.
  var view: Any

  /** Type-erased `body` of the underlying `view`. Needs to take a fresh version of `view` as an
   argument, otherwise it captures an old value of the `body` property.
   */
  let bodyClosure: (Any) -> AnyView

  /** The type of the `body` of the underlying `view`. Used to cast the result of the applied
   `bodyClosure` property.
   */
  let bodyType: Any.Type
    
  let visitChildren: (ViewVisitor, Any) -> ()
    
    public init<V>(_ view: V) where V: View {
        if let anyView = view as? AnyView {
            self = anyView
        } else {
            type = V.self
            
            typeConstructorName = CarPlayUI.typeConstructorName(type)
            
            bodyType = V.Body.self
            self.view = view
            // swiftlint:disable:next force_cast
            bodyClosure = { AnyView(($0 as! V).body) }
            // swiftlint:disable:next force_cast
            visitChildren = { $0.visit($1 as! V) }
        }
    }
    
    public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
      visitChildren(visitor, view)
    }
}

public func mapAnyView<T, V>(_ anyView: AnyView, transform: (V) -> T) -> T? {
  guard let view = anyView.view as? V else { return nil }

  return transform(view)
}

extension AnyView: ParentView {
  @_spi(CarPlayUI)
  public var children: [AnyView] {
    (view as? ParentView)?.children ?? []
  }
}

public struct _AnyViewProxy {
  public var subject: AnyView

  public init(_ subject: AnyView) { self.subject = subject }

  public var type: Any.Type { subject.type }
  public var view: Any { subject.view }
}
