//
//  EnvironmentObject.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Combine

@propertyWrapper
public struct EnvironmentObject<ObjectType>: DynamicProperty
  where ObjectType: ObservableObject
{
  @dynamicMemberLookup
  public struct Wrapper {
    internal let root: ObjectType
    public subscript<Subject>(
      dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>
    ) -> Binding<Subject> {
      .init(
        get: {
          self.root[keyPath: keyPath]
        }, set: {
          self.root[keyPath: keyPath] = $0
        }
      )
    }
  }

  var _store: ObjectType?
  var _seed: Int = 0

  mutating func setContent(from values: EnvironmentValues) {
    _store = values[ObjectIdentifier(ObjectType.self)]
  }

  public var wrappedValue: ObjectType {
    guard let store = _store else { error() }
    return store
  }

  public var projectedValue: Wrapper {
    guard let store = _store else { error() }
    return Wrapper(root: store)
  }

  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }

  func error() -> Never {
    fatalError("No ObservableObject found for type \(ObjectType.self)")
  }

  public init() {}
}

extension EnvironmentObject: ObservedProperty, EnvironmentReader {}

extension ObservableObject {
  static var environmentStore: WritableKeyPath<EnvironmentValues, Self?> {
    \.[ObjectIdentifier(self)]
  }
}

public extension View {
  func environmentObject<B>(_ bindable: B) -> some View where B: ObservableObject {
    environment(B.environmentStore, bindable)
  }
}
