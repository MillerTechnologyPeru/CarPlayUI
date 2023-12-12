//
//  State.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

protocol ValueStorage {
  var getter: (() -> Any)? { get set }
  var anyInitialValue: Any { get }
}

protocol WritableValueStorage: ValueStorage {
  var setter: ((Any, Transaction) -> ())? { get set }
}

@propertyWrapper
public struct State<Value>: DynamicProperty {
  private let initialValue: Value

  var anyInitialValue: Any { initialValue }

  var getter: (() -> Any)?
  var setter: ((Any, Transaction) -> ())?

  public init(wrappedValue value: Value) {
    initialValue = value
  }

  public var wrappedValue: Value {
    get { getter?() as? Value ?? initialValue }
    nonmutating set { setter?(newValue, Transaction._active ?? .init(animation: nil)) }
  }

  public var projectedValue: Binding<Value> {
    guard let getter = getter, let setter = setter else {
      fatalError("\(#function) not available outside of `body`")
    }
    // swiftlint:disable force_cast
    return .init(
      get: { getter() as! Value },
      set: { newValue, transaction in
        setter(newValue, Transaction._active ?? transaction)
      }
    )
    // swiftlint:enable force_cast
  }
}

extension State: WritableValueStorage {}

public extension State where Value: ExpressibleByNilLiteral {
  @inlinable
  init() { self.init(wrappedValue: nil) }
}
