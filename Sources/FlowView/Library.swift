/// A macro that creates events listner, model and constructor for the page
/// For example,
///
///     @FlowView(InOutEmpty.self)
///     struct FlowView: FlowViewProtocol, View {
///         var body: some View {
///             EmptyView()
///         }
///     }
///
/// generates to
///
///     @FlowView(InOutEmpty.self)
///     struct FlowView: FlowViewProtocol, View {
///         var body: some View {
///             EmptyView()
///         }
///
///         let events = AsyncThrowingSubject<CoordinatorEvent>()
///         let model: InOutEmpty
///         init(model: InOutEmpty = InOutEmpty()) {
///             self.model = model
///         }
///     }
///
/// If the enum is `public`, the generated `ID` enum and the
/// generated `id` accessor will also be `public`

@attached(member, names: named(events), named(model), named(init(model:)))
public macro FlowView<Model>(_ model: Model.Type, init: Bool = true) = #externalMacro(module: "FlowViewMacro", type: "FlowViewMacro")

