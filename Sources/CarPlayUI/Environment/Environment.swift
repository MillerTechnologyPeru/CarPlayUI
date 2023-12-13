//
//  Transaction.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

protocol EnvironmentReader {
  mutating func setContent(from values: EnvironmentValues)
}

@propertyWrapper
public struct Environment<Value>: DynamicProperty {
  enum Content {
    case keyPath(KeyPath<EnvironmentValues, Value>)
    case value(Value)
  }

  private var content: Content
  private let keyPath: KeyPath<EnvironmentValues, Value>
  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    content = .keyPath(keyPath)
    self.keyPath = keyPath
  }

  mutating func setContent(from values: EnvironmentValues) {
    content = .value(values[keyPath: keyPath])
  }

  public var wrappedValue: Value {
    switch content {
    case let .value(value):
      return value
    case let .keyPath(keyPath):
      // not bound to a view, return the default value.
      return EnvironmentValues()[keyPath: keyPath]
    }
  }
}

extension Environment: EnvironmentReader {}
