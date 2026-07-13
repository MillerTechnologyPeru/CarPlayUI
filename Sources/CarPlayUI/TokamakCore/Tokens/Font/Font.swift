// Copyright 2018-2021 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

public struct Font: Hashable {
  let provider: AnyFontBox

  init(_ provider: AnyFontBox) {
    self.provider = provider
  }
}

public extension Font {
  struct Weight: Hashable {
    public let value: Int

    public nonisolated(unsafe) static let ultraLight: Self = .init(value: 100)
    public nonisolated(unsafe) static let thin: Self = .init(value: 200)
    public nonisolated(unsafe) static let light: Self = .init(value: 300)
    public nonisolated(unsafe) static let regular: Self = .init(value: 400)
    public nonisolated(unsafe) static let medium: Self = .init(value: 500)
    public nonisolated(unsafe) static let semibold: Self = .init(value: 600)
    public nonisolated(unsafe) static let bold: Self = .init(value: 700)
    public nonisolated(unsafe) static let heavy: Self = .init(value: 800)
    public nonisolated(unsafe) static let black: Self = .init(value: 900)
  }
}

public extension Font {
  enum Leading {
    case standard
    case tight
    case loose
  }
}

public enum _FontNames: Hashable {
  case system
  case custom(String)
}

public extension Font {
  static func system(
    size: CGFloat,
    weight: Weight = .regular,
    design: Design = .default
  ) -> Self {
    .init(
      _ConcreteFontBox(
        .init(
          name: .system,
          size: size,
          design: design,
          weight: weight,
          smallCaps: false,
          italic: false,
          bold: false,
          monospaceDigit: false,
          leading: .standard
        )
      )
    )
  }

  enum Design: Hashable {
    case `default`
    case serif
    case rounded
    case monospaced
  }
}

public extension Font {
  nonisolated(unsafe) static let largeTitle: Self = .init(_SystemFontBox(.largeTitle))
  nonisolated(unsafe) static let title: Self = .init(_SystemFontBox(.title))
  nonisolated(unsafe) static let title2: Self = .init(_SystemFontBox(.title2))
  nonisolated(unsafe) static let title3: Self = .init(_SystemFontBox(.title3))
  nonisolated(unsafe) static let headline: Font = .init(_SystemFontBox(.headline))
  nonisolated(unsafe) static let subheadline: Self = .init(_SystemFontBox(.subheadline))
  nonisolated(unsafe) static let body: Self = .init(_SystemFontBox(.body))
  nonisolated(unsafe) static let callout: Self = .init(_SystemFontBox(.callout))
  nonisolated(unsafe) static let footnote: Self = .init(_SystemFontBox(.footnote))
  nonisolated(unsafe) static let caption: Self = .init(_SystemFontBox(.caption))
  nonisolated(unsafe) static let caption2: Self = .init(_SystemFontBox(.caption2))

  static func system(_ style: TextStyle, design: Design = .default) -> Self {
    .init(_ModifiedFontBox(previously: style.font.provider) {
      $0._design = design
    })
  }

  enum TextStyle: Hashable, CaseIterable {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption
    case caption2

    var font: Font {
      switch self {
      case .largeTitle: return .largeTitle
      case .title: return .title
      case .title2: return .title2
      case .title3: return .title3
      case .headline: return .headline
      case .subheadline: return .subheadline
      case .body: return .body
      case .callout: return .callout
      case .footnote: return .footnote
      case .caption: return .caption
      case .caption2: return .caption2
      }
    }
  }
}

public extension Font {
  static func custom(_ name: String, size: CGFloat) -> Self {
    .init(_CustomFontBox(name, size: .dynamic(size)))
  }

  static func custom(_ name: String, size: CGFloat, relativeTo textStyle: TextStyle) -> Self {
    .init(_CustomFontBox(name, size: .dynamic(size), relativeTo: textStyle))
  }

  static func custom(_ name: String, fixedSize: CGFloat) -> Self {
    .init(_CustomFontBox(name, size: .fixed(fixedSize)))
  }
}

public struct _FontProxy {
  let subject: Font
  public init(_ subject: Font) { self.subject = subject }

  public var provider: AnyFontBox { subject.provider }

  @MainActor
  public func resolve(in environment: EnvironmentValues) -> AnyFontBox.ResolvedValue {
    if let deferred = subject.provider as? AnyFontBoxDeferredToRenderer {
      return deferred.deferredResolve(in: environment)
    } else {
      return subject.provider.resolve(in: environment)
    }
  }
}

enum FontPathKey: EnvironmentKey {
  nonisolated(unsafe) static let defaultValue: [Font] = []
}

public extension EnvironmentValues {
  @MainActor
  var _fontPath: [Font] {
    get {
      self[FontPathKey.self]
    }
    set {
      self[FontPathKey.self] = newValue
    }
  }

  @MainActor
  var font: Font? {
    get {
      _fontPath.first
    }
    set {
      if let newFont = newValue {
        _fontPath = [newFont] + _fontPath.filter { $0 != newFont }
      } else {
        _fontPath = []
      }
    }
  }
}

public extension View {
  func font(_ font: Font?) -> some View {
    environment(\.font, font)
  }
}
