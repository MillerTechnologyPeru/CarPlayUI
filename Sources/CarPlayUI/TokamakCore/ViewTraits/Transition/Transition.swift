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
//
//  Created by Carson Katri on 7/10/21.
//

import Foundation

@frozen
public struct AnyTransition: @unchecked Sendable {
  fileprivate let box: _AnyTransitionBox

  private init(_ box: _AnyTransitionBox) {
    self.box = box
  }
}

@usableFromInline
struct TransitionTraitKey: _ViewTraitKey {
  @inlinable
  nonisolated(unsafe) static var defaultValue: AnyTransition { .opacity }

  @usableFromInline typealias Value = AnyTransition
}

@usableFromInline
struct CanTransitionTraitKey: _ViewTraitKey {
  @inlinable
  nonisolated(unsafe) static var defaultValue: Bool { false }

  @usableFromInline typealias Value = Bool
}

public extension _ViewTraitStore {
  @MainActor
  var transition: AnyTransition { value(forKey: TransitionTraitKey.self) }
  @MainActor
  var canTransition: Bool { value(forKey: CanTransitionTraitKey.self) }
}

enum TransitionPhase: Hashable {
  case willMount
  case normal
  case willUnmount
}

public extension View {
  @inlinable
  func transition(_ t: AnyTransition) -> some View {
    _trait(TransitionTraitKey.self, t)
  }
}

/// A `ViewModifier` used to apply a primitive transition to a `View`.
@MainActor
public protocol _AnyTransitionModifier: AnimatableModifier
  where Body == Content
{
  var isActive: Bool { get }
}

public extension _AnyTransitionModifier {
  func body(content: Content) -> Body {
    content
  }
}

public struct _MoveTransition: _AnyTransitionModifier {
  public let edge: Edge
  public let isActive: Bool
  public typealias Body = Self.Content
}

@MainActor
public extension AnyTransition {
  nonisolated(unsafe) static let identity: AnyTransition = .init(IdentityTransitionBox())

  static func move(edge: Edge) -> AnyTransition {
    modifier(
      active: _MoveTransition(edge: edge, isActive: true),
      identity: _MoveTransition(edge: edge, isActive: false)
    )
  }

  static func asymmetric(
    insertion: AnyTransition,
    removal: AnyTransition
  ) -> AnyTransition {
    .init(AsymmetricTransitionBox(insertion: insertion.box, removal: removal.box))
  }

  static func offset(_ offset: CGSize) -> AnyTransition {
    modifier(
      active: _OffsetEffect(offset: offset),
      identity: _OffsetEffect(offset: .zero)
    )
  }

  static func offset(
    x: CGFloat = 0,
    y: CGFloat = 0
  ) -> AnyTransition {
    offset(.init(width: x, height: y))
  }

  nonisolated(unsafe) static var scale: AnyTransition { MainActor.assumeIsolated { scale(scale: 0) } }
  static func scale(scale: CGFloat, anchor: UnitPoint = .center) -> AnyTransition {
    modifier(
      active: _ScaleEffect(scale: .init(width: scale, height: scale), anchor: anchor),
      identity: _ScaleEffect(scale: .init(width: 1, height: 1), anchor: anchor)
    )
  }

  nonisolated(unsafe) static let opacity: AnyTransition = MainActor.assumeIsolated {
    modifier(
      active: _OpacityEffect(opacity: 0),
      identity: _OpacityEffect(opacity: 1)
    )
  }

  nonisolated(unsafe) static let slide: AnyTransition = MainActor.assumeIsolated {
    asymmetric(
      insertion: .move(edge: .leading),
      removal: .move(edge: .trailing)
    )
  }

  static func modifier<E>(
    active: E,
    identity: E
  ) -> AnyTransition where E: ViewModifier {
    .init(
      ConcreteTransitionBox(
        (active: {
          AnyView($0.modifier(active))
        }, identity: {
          AnyView($0.modifier(identity))
        })
      )
    )
  }

  func combined(with other: AnyTransition) -> AnyTransition {
    .init(CombinedTransitionBox(a: box, b: other.box))
  }

  func animation(_ animation: Animation?) -> AnyTransition {
    .init(AnimatedTransitionBox(animation: animation, parent: box))
  }
}

public struct _AnyTransitionProxy {
  let subject: AnyTransition

  public init(_ subject: AnyTransition) { self.subject = subject }

  public func resolve(
    in environment: EnvironmentValues
  ) -> _AnyTransitionBox.ResolvedValue {
    subject.box.resolve(in: environment)
  }
}
