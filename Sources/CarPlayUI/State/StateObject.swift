//
//  StateObject.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Combine

@propertyWrapper
public struct StateObject<ObjectType: ObservableObject>: DynamicProperty {
  public var wrappedValue: ObjectType { (getter?() as? ObservedObject.Wrapper)?.root ?? initial() }

  let initial: () -> ObjectType
  var getter: (() -> Any)?

  public init(wrappedValue initial: @autoclosure @escaping () -> ObjectType) {
    self.initial = initial
  }

  public var projectedValue: ObservedObject<ObjectType>.Wrapper {
    getter?() as? ObservedObject.Wrapper ?? ObservedObject.Wrapper(root: initial())
  }
}

extension StateObject: ObservedProperty {
  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }
}

extension StateObject: ValueStorage {
  var anyInitialValue: Any {
    ObservedObject.Wrapper(root: initial())
  }
}
