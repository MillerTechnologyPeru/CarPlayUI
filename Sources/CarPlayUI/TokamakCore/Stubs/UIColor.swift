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

public struct UIColor {
  let color: Color

  public nonisolated(unsafe) static let clear: Self = .init(color: .clear)
  public nonisolated(unsafe) static let black: Self = .init(color: .black)
  public nonisolated(unsafe) static let white: Self = .init(color: .white)
  public nonisolated(unsafe) static let gray: Self = .init(color: .gray)
  public nonisolated(unsafe) static let red: Self = .init(color: .red)
  public nonisolated(unsafe) static let green: Self = .init(color: .green)
  public nonisolated(unsafe) static let blue: Self = .init(color: .blue)
  public nonisolated(unsafe) static let orange: Self = .init(color: .orange)
  public nonisolated(unsafe) static let yellow: Self = .init(color: .yellow)
  public nonisolated(unsafe) static let pink: Self = .init(color: .pink)
  public nonisolated(unsafe) static let purple: Self = .init(color: .purple)
}
