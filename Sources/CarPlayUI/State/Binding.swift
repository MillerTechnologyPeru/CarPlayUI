//
//  Binding.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation

@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value>: DynamicProperty {
  public var wrappedValue: Value {
    get { get() }
    nonmutating set { set(newValue, transaction) }
  }

  public var transaction: Transaction

  private let get: () -> Value
  private let set: (Value, Transaction) -> ()

  public var projectedValue: Binding<Value> { self }

  public init(get: @escaping () -> Value, set: @escaping (Value) -> ()) {
    self.get = get
    self.set = { v, _ in set(v) }
    transaction = .init(animation: nil)
  }

  public init(get: @escaping () -> Value, set: @escaping (Value, Transaction) -> ()) {
    self.transaction = .init(animation: nil)
    self.get = get
    self.set = {
      set($0, $1)
    }
  }

  public subscript<Subject>(
    dynamicMember keyPath: WritableKeyPath<Value, Subject>
  ) -> Binding<Subject> {
    .init(
      get: {
        self.wrappedValue[keyPath: keyPath]
      }, set: {
        self.wrappedValue[keyPath: keyPath] = $0
      }
    )
  }

  public static func constant(_ value: Value) -> Self {
    .init(get: { value }, set: { _ in })
  }
}

public extension Binding {
  func transaction(_ transaction: Transaction) -> Binding<Value> {
    var binding = self
    binding.transaction = transaction
    return binding
  }

  func animation(_ animation: Animation? = .default) -> Binding<Value> {
    transaction(.init(animation: animation))
  }
}

@available(iOS 13.0, *)
extension Binding: Identifiable where Value: Identifiable {
  public var id: Value.ID { wrappedValue.id }
}

extension Binding: Sequence where Value: MutableCollection {
  public typealias Element = Binding<Value.Element>
  public typealias Iterator = IndexingIterator<Binding<Value>>
  public typealias SubSequence = Slice<Binding<Value>>
}

extension Binding: Collection where Value: MutableCollection {
  public typealias Index = Value.Index
  public typealias Indices = Value.Indices
  public var startIndex: Binding<Value>.Index { wrappedValue.startIndex }
  public var endIndex: Binding<Value>.Index { wrappedValue.endIndex }
  public var indices: Value.Indices { wrappedValue.indices }

  public func index(after i: Binding<Value>.Index) -> Binding<Value>.Index {
    wrappedValue.index(after: i)
  }

  public func formIndex(after i: inout Binding<Value>.Index) {
    wrappedValue.formIndex(after: &i)
  }

  public subscript(position: Binding<Value>.Index) -> Binding<Value>.Element {
    Binding<Value.Element> {
      wrappedValue[position]
    } set: {
      wrappedValue[position] = $0
    }
  }
}

extension Binding: BidirectionalCollection where Value: BidirectionalCollection,
  Value: MutableCollection
{
  public func index(before i: Binding<Value>.Index) -> Binding<Value>.Index {
    wrappedValue.index(before: i)
  }

  public func formIndex(before i: inout Binding<Value>.Index) {
    wrappedValue.formIndex(before: &i)
  }
}

extension Binding: RandomAccessCollection where Value: MutableCollection,
  Value: RandomAccessCollection {}
