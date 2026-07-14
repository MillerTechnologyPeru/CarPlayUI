// Copyright 2018-2020 Tokamak contributors
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
//
//  Created by Max Desiatov on 16/10/2018.
//

public struct Color: Hashable, Equatable, Sendable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.provider == rhs.provider
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(provider)
  }

  let provider: AnyColorBox

  internal init(_ provider: AnyColorBox) {
    self.provider = provider
  }

  public init(
    _ colorSpace: RGBColorSpace = .sRGB,
    red: Double,
    green: Double,
    blue: Double,
    opacity: Double = 1
  ) {
    self.init(_ConcreteColorBox(
      .init(red: red, green: green, blue: blue, opacity: opacity, space: colorSpace)
    ))
  }

  public init(_ colorSpace: RGBColorSpace = .sRGB, white: Double, opacity: Double = 1) {
    self.init(colorSpace, red: white, green: white, blue: white, opacity: opacity)
  }

  // Source for the formula:
  // https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
  public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
    let a = saturation * min(brightness / 2, 1 - (brightness / 2))
    let f = { (n: Int) -> Double in
      let k = Double((n + Int(hue * 12)) % 12)
      return brightness - (a * max(-1, min(k - 3, 9 - k, 1)))
    }
    self.init(.sRGB, red: f(0), green: f(8), blue: f(4), opacity: opacity)
  }

  /// Create a `Color` dependent on the current `ColorScheme`.
  
  public static func _withScheme(_ resolver: @escaping @MainActor (ColorScheme) -> Self) -> Self {
    .init(_EnvironmentDependentColorBox { environment in
      resolver(environment.colorScheme)
    })
  }
}

public extension Color {
  func opacity(_ opacity: Double) -> Self {
    Self(_OpacityColorBox(provider, opacity: opacity))
  }
}

public struct _ColorProxy {
  let subject: Color
  public init(_ subject: Color) { self.subject = subject }
  @MainActor
  public func resolve(in environment: sending EnvironmentValues) -> AnyColorBox.ResolvedValue {
    if let deferred = subject.provider as? AnyColorBoxDeferredToRenderer {
      return deferred.deferredResolve(in: environment)
    } else {
      return subject.provider.resolve(in: environment)
    }
  }
}

public extension Color {
  enum RGBColorSpace: Sendable {
    case sRGB
    case sRGBLinear
    case displayP3
  }
}

extension Color: CustomStringConvertible {
  public var description: String {
    if let providerDescription = provider as? CustomStringConvertible {
      return providerDescription.description
    } else {
      return "Color: \(provider.self)"
    }
  }
}

public extension Color {
  private init(systemColor: _SystemColorBox.SystemColor) {
    self.init(_SystemColorBox(systemColor))
  }

  nonisolated(unsafe) static let clear: Self = .init(systemColor: .clear)
  nonisolated(unsafe) static let black: Self = .init(systemColor: .black)
  nonisolated(unsafe) static let white: Self = .init(systemColor: .white)
  nonisolated(unsafe) static let gray: Self = .init(systemColor: .gray)
  nonisolated(unsafe) static let red: Self = .init(systemColor: .red)
  nonisolated(unsafe) static let green: Self = .init(systemColor: .green)
  nonisolated(unsafe) static let blue: Self = .init(systemColor: .blue)
  nonisolated(unsafe) static let orange: Self = .init(systemColor: .orange)
  nonisolated(unsafe) static let yellow: Self = .init(systemColor: .yellow)
  nonisolated(unsafe) static let pink: Self = .init(systemColor: .pink)
  nonisolated(unsafe) static let purple: Self = .init(systemColor: .purple)
  nonisolated(unsafe) static let primary: Self = .init(systemColor: .primary)

  nonisolated(unsafe) static let secondary: Self = .init(systemColor: .secondary)
  nonisolated(unsafe) static let accentColor: Self = .init(_EnvironmentDependentColorBox { environment in
    environment.accentColor ?? Self.blue
  })

  init(_ color: UIColor) {
    self = color.color
  }
}

public extension ShapeStyle where Self == Color {
  nonisolated(unsafe) static var clear: Self { .clear }
  nonisolated(unsafe) static var black: Self { .black }
  nonisolated(unsafe) static var white: Self { .white }
  nonisolated(unsafe) static var gray: Self { .gray }
  nonisolated(unsafe) static var red: Self { .red }
  nonisolated(unsafe) static var green: Self { .green }
  nonisolated(unsafe) static var blue: Self { .blue }
  nonisolated(unsafe) static var orange: Self { .orange }
  nonisolated(unsafe) static var yellow: Self { .yellow }
  nonisolated(unsafe) static var pink: Self { .pink }
  nonisolated(unsafe) static var purple: Self { .purple }
}

extension Color: ExpressibleByIntegerLiteral {
  /// Allows initializing value of `Color` type from hex values
  public init(integerLiteral bitMask: UInt32) {
    self.init(
      .sRGB,
      red: Double((bitMask & 0xFF0000) >> 16) / 255,
      green: Double((bitMask & 0x00FF00) >> 8) / 255,
      blue: Double(bitMask & 0x0000FF) / 255,
      opacity: 1
    )
  }
}

public extension Color {
  init?(hex: String) {
    let cArray = Array(hex.count > 6 ? String(hex.dropFirst()) : hex)

    guard cArray.count == 6 else { return nil }

    guard
      let red = Int(String(cArray[0...1]), radix: 16),
      let green = Int(String(cArray[2...3]), radix: 16),
      let blue = Int(String(cArray[4...5]), radix: 16)
    else {
      return nil
    }
    self.init(
      .sRGB,
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255,
      opacity: 1
    )
  }
}

extension Color: ShapeStyle {
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .color(self)
  }

  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

extension Color: View {
  public typealias Body = _ShapeView<Rectangle, Self>
}
