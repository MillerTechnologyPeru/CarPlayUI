//
//  ForEach.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

// ype-erased `ForEach`
protocol ForEachProtocol: GroupView {
  var elementType: Any.Type { get }
  func element(at: Int) -> Any
}

public struct ForEach<Data, ID, Content>: _PrimitiveView where Data: RandomAccessCollection,
  ID: Hashable,
  Content: View
{
  let data: Data
  let id: KeyPath<Data.Element, ID>
  public let content: (Data.Element) -> Content

  public init(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.data = data
    self.id = id
    self.content = content
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    for element in data {
      visitor.visit(content(element))
    }
  }
}

extension ForEach: ForEachProtocol where Data.Index == Int {
  var elementType: Any.Type { Data.Element.self }
  func element(at index: Int) -> Any { data[index] }
}

public extension ForEach where Data.Element: Identifiable, ID == Data.Element.ID {
  init(
    _ data: Data,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.init(data, id: \.id, content: content)
  }
}

public extension ForEach where Data == Range<Int>, ID == Int {
  init(
    _ data: Range<Int>,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.data = data
    id = \.self
    self.content = content
  }
}

extension ForEach: ParentView {
  @_spi(CarPlayUI)
  public var children: [AnyView] {
    data.map { AnyView(IDView(content($0), id: $0[keyPath: id])) }
  }
}

extension ForEach: GroupView {}

struct _IDKey: EnvironmentKey {
  static let defaultValue: AnyHashable? = nil
}

public extension EnvironmentValues {
  var _id: AnyHashable? {
    get {
      self[_IDKey.self]
    }
    set {
      self[_IDKey.self] = newValue
    }
  }
}

public protocol _AnyIDView {
  var anyId: AnyHashable { get }
  var anyContent: AnyView { get }
}

struct IDView<Content, ID>: View, _AnyIDView where Content: View, ID: Hashable {
  let content: Content
  let id: ID
  var anyId: AnyHashable { AnyHashable(id) }
  var anyContent: AnyView { AnyView(content) }

  init(_ content: Content, id: ID) {
    self.content = content
    self.id = id
  }

  var body: some View {
    content
      .environment(\._id, AnyHashable(id))
  }
}

public extension View {
  func id<ID>(_ id: ID) -> some View where ID: Hashable {
    IDView(self, id: id)
  }
}
