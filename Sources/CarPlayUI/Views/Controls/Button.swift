//
//  Button.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

/// A control that performs an action when triggered.
///
/// Available when `Label` conforms to `View`.
///
/// A button is created using a `Label`; the `action` initializer argument (a method or closure)
/// is to be called on click.
///
///     @State private var counter: Int = 0
///     var body: some View {
///       Button(action: { counter += 1 }) {
///         Text("\(counter)")
///       }
///     }
///
/// When your label is `Text`, you can create the button by directly passing a `String`:
///
///     @State private var counter: Int = 0
///     var body: some View {
///       Button("\(counter)", action: { counter += 1 })
///     }
public struct Button<Label>: View where Label: View {
    
  let label: Label
  let action: () -> ()

  @_spi(CarPlayUI)
  public var body: some View {
      label
  }
}

public extension Button where Label == Text {
    
  init<S>(_ title: S, action: @escaping () -> ()) where S: StringProtocol {
      self.label = Text(title)
      self.action = action
  }
}

public extension Button {
  init(
    action: @escaping () -> (),
    @ViewBuilder label: () -> Label
  ) {
    self.label = label()
    self.action = action
  }
}
