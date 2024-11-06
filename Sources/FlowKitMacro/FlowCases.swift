/// A macro that creates named cases for an enum, CaseIterable implementation, function to update associated value.
/// For example,
///
///     @FlowCases
///     enum Out: FlowOutProtocol {
///         case empty2(InOutEmpty2)
///         case empty3(InOutEmpty3)
///     }
///
/// generates to
///
///     @FlowCases
///     enum Out: FlowOutProtocol {
///         case empty2(InOutEmpty2)
///         case empty3(InOutEmpty3)
///         
///         static var allCases: [Out] {
///             [.empty2(InOutEmpty2()), .empty3(InOutEmpty3())]
///         }
///
///         func udpate(associatedValue: some InOutProtocol) -> Self {
///             switch self {
///             case .empty2(_):
///                 guard let model = associatedValue as? InOutEmpty2 else {
///                     return self
///                 }
///                 return .empty2(model)
///             case .empty3(_):
///                 guard let model = associatedValue as? InOutEmpty3 else {
///                     return self
///                 }
///                 return .empty3(model)
///             }
///         }
///
///         static var empty2: (out: Self, model: InOutEmpty2) {
///             (.empty2(InOutEmpty2()), InOutEmpty2())
///         }
///
///         static var empty3: (out: Self, model: InOutEmpty3) {
///             (.empty3(InOutEmpty3()), InOutEmpty3())
///         }
///     }
///
/// If the enum is `public`, the generated `ID` enum and the
/// generated `id` accessor will also be `public`

@attached(member, names: arbitrary)
public macro FlowCases() = #externalMacro(module: "FlowCasesMacro", type: "FlowCasesMacro")
