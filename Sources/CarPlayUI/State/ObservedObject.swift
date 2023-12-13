//
//  ObservedObject.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Combine

protocol ObservedProperty: DynamicProperty {
  var objectWillChange: AnyPublisher<(), Never> { get }
}

@propertyWrapper
public struct ObservedObject<ObjectType>: DynamicProperty where ObjectType: ObservableObject {
  @dynamicMemberLookup
  public struct Wrapper {
    let root: ObjectType
    public subscript<Subject>(
      dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>
    ) -> Binding<Subject> {
      .init(
        get: {
          self.root[keyPath: keyPath]
        },
        set: {
          self.root[keyPath: keyPath] = $0
        }
      )
    }
  }

  public var wrappedValue: ObjectType { projectedValue.root }

  public init(wrappedValue: ObjectType) {
    projectedValue = Wrapper(root: wrappedValue)
  }

  public let projectedValue: Wrapper
}

extension ObservedObject: ObservedProperty {
  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }
}
