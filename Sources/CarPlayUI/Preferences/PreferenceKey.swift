//
//  PreferenceKey.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

public protocol PreferenceKey {
  associatedtype Value
  static var defaultValue: Value { get }
  static func reduce(value: inout Value, nextValue: () -> Value)
}

public extension PreferenceKey where Self.Value: ExpressibleByNilLiteral {
  static var defaultValue: Value { nil }
}

final class _PreferenceValueStorage: CustomDebugStringConvertible {
  /// Every value the `Key` has had.
  var valueList: [Any]

  var debugDescription: String {
    valueList.debugDescription
  }

  init<Key: PreferenceKey>(_ key: Key.Type = Key.self) {
    valueList = []
  }

  init(valueList: [Any]) {
    self.valueList = valueList
  }

  func merge(_ other: _PreferenceValueStorage) {
    valueList.append(contentsOf: other.valueList)
  }

  func reset() {
    valueList = []
  }
}

public struct _PreferenceValue<Key> where Key: PreferenceKey {
  var storage: _PreferenceValueStorage

  init(storage: _PreferenceValueStorage) {
    self.storage = storage
  }

  /// The latest value.
  public var value: Key.Value {
    reduce(storage.valueList.compactMap { $0 as? Key.Value })
  }

  func reduce(_ values: [Key.Value]) -> Key.Value {
    values.reduce(into: Key.defaultValue) { prev, next in
      Key.reduce(value: &prev) { next }
    }
  }
}

public extension _PreferenceValue {
  func _force<V>(
    _ transform: @escaping (Key.Value) -> V
  ) -> _PreferenceReadingView<Key, V> where V: View {
    _PreferenceReadingView(value: self, transform: transform)
  }
}

public final class _PreferenceStore: CustomDebugStringConvertible {
  /// The values of the `_PreferenceStore` on the last update.
  private var previousValues: [ObjectIdentifier: _PreferenceValueStorage]
  /// The backing values of the `_PreferenceStore`.
  private var values: [ObjectIdentifier: _PreferenceValueStorage]

  weak var parent: _PreferenceStore?

  public var debugDescription: String {
    "Preferences (\(ObjectIdentifier(self))): \(values)"
  }

  init(values: [ObjectIdentifier: _PreferenceValueStorage] = [:]) {
    previousValues = [:]
    self.values = values
  }

  /// Retrieve a late-binding token for `key`, or save the default value if it does not yet exist.
  public func value<Key>(forKey key: Key.Type = Key.self) -> _PreferenceValue<Key>
    where Key: PreferenceKey
  {
    let keyID = ObjectIdentifier(key)
    let storage: _PreferenceValueStorage
    if let existing = values[keyID] {
      storage = existing
    } else {
      storage = .init(key)
      values[keyID] = storage
    }
    return _PreferenceValue(storage: storage)
  }

    
  func previousValue<Key>(forKey key: Key.Type = Key.self) -> _PreferenceValue<Key>
    where Key: PreferenceKey
  {
    _PreferenceValue(storage: previousValues[ObjectIdentifier(key)] ?? .init(key))
  }

  public func insert<Key>(_ value: Key.Value, forKey key: Key.Type = Key.self)
    where Key: PreferenceKey
  {
    let keyID = ObjectIdentifier(key)
    if !values.keys.contains(keyID) {
      values[keyID] = .init(key)
    }
    values[keyID]?.valueList.append(value)
    parent?.insert(value, forKey: key)
  }

  func merge(_ other: _PreferenceStore) {
    for (key, otherStorage) in other.values {
      if let storage = values[key] {
        storage.merge(otherStorage)
      } else {
        values[key] = .init(valueList: otherStorage.valueList)
      }
    }
  }

  func reset() {
    previousValues = values.mapValues {
      _PreferenceValueStorage(valueList: $0.valueList)
    }
    for storage in values.values {
      storage.reset()
    }
  }
}

public protocol _PreferenceReadingViewProtocol {
  func preferenceStore(_ preferenceStore: _PreferenceStore)
}

/// A protocol that allows a `View` to modify values from the current `_PreferenceStore`.
public protocol _PreferenceWritingViewProtocol {
  func modifyPreferenceStore(_ preferenceStore: inout _PreferenceStore) -> AnyView
}

/// A protocol that allows a `ViewModifier` to modify values from the current `_PreferenceStore`.
public protocol _PreferenceWritingModifierProtocol: ViewModifier
  where Body == AnyView
{
  func body(_ content: Self.Content, with preferenceStore: inout _PreferenceStore) -> AnyView
}

public extension _PreferenceWritingModifierProtocol {
  func body(content: Content) -> AnyView {
    content.view
  }
}

extension ModifiedContent: _PreferenceWritingViewProtocol
  where Content: View, Modifier: _PreferenceWritingModifierProtocol
{
  public func modifyPreferenceStore(_ preferenceStore: inout _PreferenceStore) -> AnyView {
    AnyView(
      modifier
        .body(.init(modifier: modifier, view: AnyView(content)), with: &preferenceStore)
    )
  }
}
