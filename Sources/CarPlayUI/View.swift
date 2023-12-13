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
    
    func _visitChildren<V: ViewVisitor>(_ visitor: V)

    static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs
}

public extension View {
    
    func _visitChildren<V: ViewVisitor>(_ visitor: V) {
        visitor.visit(body)
    }
    
    static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
      .init(inputs: inputs)
    }
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
    
    func _visitChildren<V>(_ visitor: V) where V: ViewVisitor { }
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
