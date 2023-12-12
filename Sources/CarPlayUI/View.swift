//
//  View.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation

public protocol View {
  associatedtype Body: View

  @ViewBuilder
  var body: Self.Body { get }
}

public extension Never {
  @_spi(CarPlayUI)
  var body: Never {
    fatalError()
  }
}

extension Never: View {}

/// A `View` that offers primitive functionality, which renders its `body` inaccessible.
public protocol _PrimitiveView: View where Body == Never {}

public extension _PrimitiveView {
    
  @_spi(CarPlayUI)
  var body: Never {
    neverBody(String(reflecting: Self.self))
  }
}

/// A `View` type that renders with subviews, usually specified in the `Content` type argument
public protocol ParentView {
  var children: [AnyView] { get }
}

/// A `View` type that is not rendered but "flattened", rendering all its children instead.
protocol GroupView: ParentView {}

/// Calls `fatalError` with an explanation that a given `type` is a primitive `View`
public func neverBody(_ type: String) -> Never {
  fatalError("\(type) is a primitive `View`, you're not supposed to access its `body`.")
}
