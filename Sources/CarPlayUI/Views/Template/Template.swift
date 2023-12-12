//
//  Template.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import CarPlay

public protocol Template: _PrimitiveView {
    
    associatedtype CarPlayType: CPTemplate
    
    associatedtype Coordinator
        
    typealias Context = TemplateContext<Self>
    
    func makeTemplate(context: Context) -> CarPlayType
    
    func updateTemplate(_ template: CarPlayType, context: Context)
    
    static func dismantleTemplate(_ template: CarPlayType, coordinator: Coordinator)
    
    func makeCoordinator() -> Coordinator
}

public extension Template {
    
    static func dismantleTemplate(_ template: CarPlayType, coordinator: Coordinator) { }
}

extension Template where Coordinator == Void {
    
    public func makeCoordinator() -> Void { }
}

// MARK: - Supporting Types

public struct TemplateContext<Representable> where Representable : Template {
    
    /// The view's associated coordinator.
    public let coordinator: Representable.Coordinator
    
    /// The current transaction.
    public let transaction: Transaction
    
    /// Environment values that describe the current state of the system.
    ///
    /// Use the environment values to configure the state of your CarPlay view
    /// controller when creating or updating it.
    public let environment: EnvironmentValues
}

struct TemplateReducer<T: Template>: ViewReducer {
    
    typealias Result = [T]
    
    static func reduce<V: View>(into partialResult: inout Result, nextView: V) {
        if let view = nextView as? T {
            partialResult.append(view)
        }
    }
}

internal extension View {
    
    func reduce<T: Template>(_ type: T.Type) -> [T] {
        let reducer = ReducerVisitor<TemplateReducer<T>>(initialResult: [])
        reducer.visit(self)
        return reducer.result
    }
}
