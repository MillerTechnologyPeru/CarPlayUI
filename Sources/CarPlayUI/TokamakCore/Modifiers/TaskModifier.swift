// Copyright 2021 Tokamak contributors
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

/// Backs the running `Task` with `@State` so its identity survives across
/// body re-evaluations. A plain local `var` captured by `onAppear`/`onDisappear`
/// would be re-created on every render, leaving the actual running task
/// (started by an earlier render's closure) with no way to be cancelled.
internal struct _TaskModifierView<Content>: View where Content: View {

  let priority: TaskPriority

  let action: @isolated(any) @Sendable () async -> ()

  let content: Content

  @State
  nonisolated(unsafe) private var task: Task<(), Never>?

  init(priority: TaskPriority, action: @escaping @isolated(any) @Sendable () async -> (), content: Content) {
    self.priority = priority
    self.action = action
    self.content = content
  }

  var body: some View {
    content
      .onAppear {
        task = Task(priority: priority, operation: action)
      }
      .onDisappear {
        task?.cancel()
        task = nil
      }
  }
}

public extension View {
  func task(
    priority: TaskPriority = .userInitiated,
    _ action: @escaping @isolated(any) @Sendable () async -> ()
  ) -> some View {
    _TaskModifierView(priority: priority, action: action, content: self)
  }
}
