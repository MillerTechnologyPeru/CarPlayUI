//
//  ColorScheme.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

public enum ColorScheme: CaseIterable, Equatable, Hashable {
  case dark
  case light
}

public struct _ColorSchemeKey: EnvironmentKey {
  public static var defaultValue: ColorScheme {
    fatalError("\(self) must have a renderer-provided default value")
  }
}

public extension EnvironmentValues {
  var colorScheme: ColorScheme {
    get { self[_ColorSchemeKey.self] }
    set { self[_ColorSchemeKey.self] = newValue }
  }
}

public extension View {
  func colorScheme(_ colorScheme: ColorScheme) -> some View {
    environment(\.colorScheme, colorScheme)
  }
}

public struct PreferredColorSchemeKey: PreferenceKey {
  public typealias Value = ColorScheme?
  public static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}

public extension View {
  func preferredColorScheme(_ colorScheme: ColorScheme?) -> some View {
    preference(key: PreferredColorSchemeKey.self, value: colorScheme)
  }
}
