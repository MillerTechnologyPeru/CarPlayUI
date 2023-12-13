//
//  TupleView.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

/// A `View` created from a `Tuple` of `View` values.
public struct TupleView<T>: _PrimitiveView, GroupView {
  public let value: T

  public let children: [AnyView]
  private let visit: (ViewVisitor) -> ()

  internal init(_ value: T) {
    self.value = value
    children = []
    visit = { _ in }
  }

  internal init(_ value: T, children: [AnyView]) {
    self.value = value
    self.children = children
    visit = {
      for child in children {
        $0.visit(child)
      }
    }
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visit(visitor)
  }

  init<T1: View, T2: View>(_ v1: T1, _ v2: T2) where T == (T1, T2) {
    value = (v1, v2)
    children = [AnyView(v1), AnyView(v2)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
    }
  }

  // swiftlint:disable large_tuple
  init<T1: View, T2: View, T3: View>(_ v1: T1, _ v2: T2, _ v3: T3) where T == (T1, T2, T3) {
    value = (v1, v2, v3)
    children = [AnyView(v1), AnyView(v2), AnyView(v3)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4)
    where T == (T1, T2, T3, T4)
  {
    value = (v1, v2, v3, v4)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5
  ) where T == (T1, T2, T3, T4, T5) {
    value = (v1, v2, v3, v4, v5)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6
  ) where T == (T1, T2, T3, T4, T5, T6) {
    value = (v1, v2, v3, v4, v5, v6)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6,
    _ v7: T7
  ) where T == (T1, T2, T3, T4, T5, T6, T7) {
    value = (v1, v2, v3, v4, v5, v6, v7)
    children = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
    ]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
      $0.visit(v7)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6,
    _ v7: T7,
    _ v8: T8
  ) where T == (T1, T2, T3, T4, T5, T6, T7, T8) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8)
    children = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
      AnyView(v8),
    ]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
      $0.visit(v7)
      $0.visit(v8)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View, T9: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6,
    _ v7: T7,
    _ v8: T8,
    _ v9: T9
  ) where T == (T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8, v9)
    children = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
      AnyView(v8),
      AnyView(v9),
    ]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
      $0.visit(v7)
      $0.visit(v8)
      $0.visit(v9)
    }
  }

  init<
    T1: View,
    T2: View,
    T3: View,
    T4: View,
    T5: View,
    T6: View,
    T7: View,
    T8: View,
    T9: View,
    T10: View
  >(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6,
    _ v7: T7,
    _ v8: T8,
    _ v9: T9,
    _ v10: T10
  ) where T == (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
    children = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
      AnyView(v8),
      AnyView(v9),
      AnyView(v10),
    ]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
      $0.visit(v7)
      $0.visit(v8)
      $0.visit(v9)
      $0.visit(v10)
    }
  }
}
