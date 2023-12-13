//
//  Section.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation

protocol SectionView {
    
}

public struct Section<Parent, Content, Footer> {
  let header: Parent
  let footer: Footer
  let content: Content
}

extension Section: View, SectionView where Parent: View, Content: View, Footer: View {
  public init(header: Parent, footer: Footer, @ViewBuilder content: () -> Content) {
    self.header = header
    self.footer = footer
    self.content = content()
  }

  @ViewBuilder
  @_spi(CarPlayUI)
  public var body: TupleView<(Parent, Content, Footer)> {
    header
    content
    footer
  }
}

public extension Section where Parent == EmptyView, Content: View, Footer: View {
  init(footer: Footer, @ViewBuilder content: () -> Content) {
    self.init(header: EmptyView(), footer: footer, content: content)
  }
}

public extension Section where Parent: View, Content: View, Footer == EmptyView {
  init(header: Parent, @ViewBuilder content: () -> Content) {
    self.init(header: header, footer: EmptyView(), content: content)
  }
}

public extension Section where Parent == EmptyView, Content: View, Footer == EmptyView {
  init(@ViewBuilder content: () -> Content) {
    self.init(header: EmptyView(), footer: EmptyView(), content: content)
  }
}
