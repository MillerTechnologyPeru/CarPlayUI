//
//  ViewVisitor.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

/// A type that can visit a `View`.
public protocol ViewVisitor {
  func visit<V: View>(_ view: V)
}

/// A type that creates a `Result` by visiting multiple `View`s.
protocol ViewReducer {
  associatedtype Result
  static func reduce<V: View>(into partialResult: inout Result, nextView: V)
  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result
}

extension ViewReducer {
  static func reduce<V: View>(into partialResult: inout Result, nextView: V) {
    partialResult = Self.reduce(partialResult: partialResult, nextView: nextView)
  }

  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result {
    var result = partialResult
    Self.reduce(into: &result, nextView: nextView)
    return result
  }
}

/// A `ViewVisitor` that uses a `ViewReducer`
/// to collapse the `View` values into a single `Result`.
final class ReducerVisitor<R: ViewReducer>: ViewVisitor {
  var result: R.Result

  init(initialResult: R.Result) {
    result = initialResult
  }

  func visit<V>(_ view: V) where V: View {
    R.reduce(into: &result, nextView: view)
  }
}

extension ViewReducer {
  typealias Visitor = ReducerVisitor<Self>
}
