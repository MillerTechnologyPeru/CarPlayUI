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
//  Created by Carson Katri on 7/2/20.
//

public struct List<SelectionValue, Content>
  where SelectionValue: Hashable, Content: View
{
  public enum _Selection {
    case one(Binding<SelectionValue?>?)
    case many(Binding<Set<SelectionValue>>?)
  }

  let selection: _Selection
  let content: Content

  @Environment(\.listStyle)
  var style

  public init(selection: Binding<Set<SelectionValue>>?, @ViewBuilder content: () -> Content) {
    self.selection = .many(selection)
    self.content = content()
  }

  public init(selection: Binding<SelectionValue?>?, @ViewBuilder content: () -> Content) {
    self.selection = .one(selection)
    self.content = content()
  }
}

public enum _ListRow {
  static func buildItems<RowView>(
    _ children: [AnyView],
    @ViewBuilder rowView: @escaping (AnyView, Bool) -> RowView
  ) -> some View where RowView: View {
    ForEach(Array(children.enumerated()), id: \.offset) { offset, view in
      VStack(alignment: .leading, spacing: 0) {
        HStack { Spacer() }
        rowView(view, offset == children.count - 1)
      }
    }
  }

  @ViewBuilder
  public static func listRow<V: View>(_ view: V, _ style: ListStyle, isLast: Bool) -> some View {
    (style as? ListStyleDeferredToRenderer)?.listRow(view) ??
      AnyView(view.padding([.trailing, .top, .bottom]))
    if !isLast && style.hasDividers {
      Divider()
    }
  }
}
