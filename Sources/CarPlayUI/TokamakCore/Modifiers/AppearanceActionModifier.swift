// Copyright 2020 Tokamak contributors
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

protocol AppearanceActionType {
  var appear: (() -> ())? { get }
  var disappear: (() -> ())? { get }
}

/// Underscore is present in the name for SwiftUI compatibility.
struct _AppearanceActionModifier: ViewModifier {
  var appear: (() -> ())?
  var disappear: (() -> ())?

  typealias Body = Never
}

extension ModifiedContent: AppearanceActionType
  where Content: View, Modifier == _AppearanceActionModifier
{
  var appear: (() -> ())? { modifier.appear }
  var disappear: (() -> ())? { modifier.disappear }
}

struct OnAppearActionKey: EnvironmentKey {
  static let defaultValue: (() -> ())? = nil
}

struct OnDisappearActionKey: EnvironmentKey {
  static let defaultValue: (() -> ())? = nil
}

extension EnvironmentValues {
  /// Exposes the closure passed to `.onAppear(perform:)` to ancestors that
  /// render a native CarPlay template (e.g. `List`, `Grid`, `Form`, `Map`),
  /// so it can also be invoked when that template re-appears on screen.
  var onAppearAction: (() -> ())? {
    get { self[OnAppearActionKey.self] }
    set { self[OnAppearActionKey.self] = newValue }
  }

  var onDisappearAction: (() -> ())? {
    get { self[OnDisappearActionKey.self] }
    set { self[OnDisappearActionKey.self] = newValue }
  }
}

public extension View {
  func onAppear(perform action: (() -> ())? = nil) -> some View {
    modifier(_AppearanceActionModifier(appear: action))
      .environment(\.onAppearAction, action)
  }

  func onDisappear(perform action: (() -> ())? = nil) -> some View {
    modifier(_AppearanceActionModifier(disappear: action))
      .environment(\.onDisappearAction, action)
  }
}
