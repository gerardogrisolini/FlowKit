/// A macro that creates route associated to the flow, return model and constructor
/// For example,
///
///     @Flow(InOutEmpty.self, route: Routes.valid)
///     fileprivate final class ValidFlow: FlowProtocol {
///         let node = InOutEmptyView.node {
///             $0.empty2 ~ InOutEmpty2View.node
///             $0.empty3 ~ InOutEmpty3View.node
///         }
///     }
///
/// generates to
///
///     @Flow(InOutEmpty.self, route: Routes.valid)
///     fileprivate final class ValidFlow: FlowProtocol {
///         let node = InOutEmptyView.node {
///             $0.empty2 ~ InOutEmpty2View.node
///             $0.empty3 ~ InOutEmpty3View.node
///         }
///
///         static let route = Routes.valid
///         typealias Model = InOutEmpty
///         init() { }
///     }
///

@attached(member, names: named(route), named(Model), named(init()))
public macro Flow<Model, Route>(_ model: Model.Type, route: Route) = #externalMacro(module: "FlowMacro", type: "FlowMacro")
