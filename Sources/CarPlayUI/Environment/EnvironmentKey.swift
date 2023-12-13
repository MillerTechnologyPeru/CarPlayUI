//
//  Transaction.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

public protocol EnvironmentKey {
  associatedtype Value
  static var defaultValue: Value { get }
}

public protocol _EnvironmentModifier {
  func modifyEnvironment(_ values: inout EnvironmentValues)
}

public extension ViewModifier where Self: _EnvironmentModifier {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    var environment = inputs.environment.environment
    inputs.content.modifyEnvironment(&environment)
    return .init(inputs: inputs, environment: environment)
  }
}

public struct _EnvironmentKeyWritingModifier<Value>: ViewModifier, _EnvironmentModifier {
  public let keyPath: WritableKeyPath<EnvironmentValues, Value>
  public let value: Value

  public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
    self.keyPath = keyPath
    self.value = value
  }

  public typealias Body = Never

  public func modifyEnvironment(_ values: inout EnvironmentValues) {
    values[keyPath: keyPath] = value
  }
}

public extension View {
  func environment<V>(
    _ keyPath: WritableKeyPath<EnvironmentValues, V>,
    _ value: V
  ) -> some View {
    modifier(_EnvironmentKeyWritingModifier(keyPath: keyPath, value: value))
  }
}
