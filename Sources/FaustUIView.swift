// FaustUIView.swift

import SwiftUI

public struct FaustUIView<ViewModelType: FaustUIValueBinding>: View {
    public let ui: [FaustUI]
    @ObservedObject public var viewModel: ViewModelType
    private let scrollable: Bool

    @StateObject private var themeManager = FaustThemeManager()

    public init(ui: [FaustUI], viewModel: ViewModelType, scrollable: Bool = true) {
        self.ui = ui
        self.viewModel = viewModel
        self.scrollable = scrollable
    }

    public var body: some View {
        let content = VStack(alignment: .leading, spacing: 5) {
            ForEach(ui) { item in
                render(item)
            }
        }

        Group {
            if scrollable {
                ScrollView { content }
            } else {
                content
            }
        }.environmentObject(themeManager)
    }

    @ViewBuilder
    private func render(_ item: FaustUI) -> some View {
        if item.isHidden {
            EmptyView()
        } else if item.type == .vgroup, let items = item.items {
            GroupBox(label: Text(item.label)) {
                VStack(alignment: .leading, spacing: themeManager.theme.groupSpacing) {
                    ForEach(items) { child in
                        AnyView(render(child))
                    }
                }
            }
            .padding(5)
        } else if item.type == .hgroup, let items = item.items {
            GroupBox(label: Text(item.label)) {
                HStack(alignment: .center, spacing: themeManager.theme.groupSpacing) {
                    ForEach(items) { child in
                        AnyView(render(child))
                    }
                }
            }
            .padding(5)
        } else if item.type == .tgroup, let items = item.items {
            AnyView(
                GroupBox(label: Text(item.label)) {
                    TabView {
                        ForEach(items) { child in
                            VStack {
                                Text(child.label)
                                    .font(.headline)
                                render(child)
                            }.tabItem { Text(child.label) }
                        }
                    }
                }
                .padding(5)
            )
        } else if (item.type == .vslider || item.type == .hslider),
                  let address = item.address,
                  let min = item.min,
                  let max = item.max,
                  let step = item.step {
            if item.parsedStyle == .knob {
                FaustKnob(label: item.label, address: address, range: min ... max, step: step,
                          value: binding(for: address, default: min),
                          unit: item.unit, tooltip: item.tooltip, scale: item.scale)
            } else if item.parsedStyle == .numerical {
                FaustNumerical(label: item.label, address: address, range: min ... max, step: step,
                               value: binding(for: address, default: min),
                               unit: item.unit, tooltip: item.tooltip)
            } else if item.type == .vslider {
                FaustVSlider(label: item.label, address: address, range: min ... max, step: step,
                             value: binding(for: address, default: min),
                             unit: item.unit, tooltip: item.tooltip, scale: item.scale)
            } else {
                FaustHSlider(label: item.label, address: address, range: min ... max, step: step,
                             value: binding(for: address, default: min),
                             unit: item.unit, tooltip: item.tooltip, scale: item.scale)
            }
        } else if item.type == .nentry,
                  let address = item.address,
                  let min = item.min,
                  let max = item.max,
                  let step = item.step {
            if case .menu(let options) = item.parsedStyle {
                FaustMenu(label: item.label, address: address, options: options,
                          value: binding(for: address, default: min),
                          tooltip: item.tooltip)
            } else if case .radio(let options) = item.parsedStyle {
                FaustRadio(label: item.label, address: address, options: options,
                           value: binding(for: address, default: min),
                           tooltip: item.tooltip)
            } else if item.parsedStyle == .knob {
                FaustKnob(label: item.label, address: address, range: min ... max, step: step,
                          value: binding(for: address, default: min),
                          unit: item.unit, tooltip: item.tooltip)
            } else {
                FaustNSwitch(label: item.label, address: address, range: min ... max, step: step,
                             value: binding(for: address, default: min),
                             unit: item.unit, tooltip: item.tooltip)
            }
        } else if item.type == .checkbox,
                  let address = item.address {
            FaustCheckbox(label: item.label, address: address,
                          value: binding(for: address, default: 0.0),
                          tooltip: item.tooltip)
        } else if item.type == .button,
                  let address = item.address {
            FaustButton(label: item.label, address: address,
                        value: binding(for: address, default: 0.0),
                        tooltip: item.tooltip)
        } else if item.type == .vbargraph,
                  let address = item.address {
            if item.parsedStyle == .led {
                FaustLED(label: item.label, address: address,
                         min: item.min ?? 0.0, max: item.max ?? 1.0,
                         value: binding(for: address, default: 0),
                         tooltip: item.tooltip)
            } else if item.parsedStyle == .numerical {
                FaustNumerical(label: item.label, address: address,
                               range: (item.min ?? 0.0) ... (item.max ?? 1.0), step: item.step ?? 1.0,
                               value: binding(for: address, default: 0),
                               unit: item.unit, tooltip: item.tooltip)
            } else {
                FaustVBargraph(label: item.label, address: address,
                               min: item.min ?? 0.0, max: item.max ?? 1.0,
                               value: binding(for: address, default: 0),
                               unit: item.unit, tooltip: item.tooltip)
                    .frame(idealWidth: 45, maxWidth: 45)
            }
        } else if item.type == .hbargraph,
                  let address = item.address {
            if item.parsedStyle == .led {
                FaustLED(label: item.label, address: address,
                         min: item.min ?? 0.0, max: item.max ?? 1.0,
                         value: binding(for: address, default: 0),
                         tooltip: item.tooltip)
            } else if item.parsedStyle == .numerical {
                FaustNumerical(label: item.label, address: address,
                               range: (item.min ?? 0.0) ... (item.max ?? 1.0), step: item.step ?? 1.0,
                               value: binding(for: address, default: 0),
                               unit: item.unit, tooltip: item.tooltip)
            } else {
                FaustHBargraph(label: item.label, address: address,
                               min: item.min ?? 0.0, max: item.max ?? 1.0,
                               value: binding(for: address, default: 0),
                               unit: item.unit, tooltip: item.tooltip)
                    .frame(idealHeight: 45, maxHeight: 45)
            }
        }
    }

    // Helper function to create bindings for values stored in the viewModel
    private func binding<T>(for address: String, default defaultValue: T) -> Binding<T> where T: BinaryFloatingPoint {
        return Binding(
            get: { T(viewModel.getValue(for: address, default: Double(defaultValue))) },
            set: { newValue in viewModel.setValue(Double(newValue), for: address) }
        )
    }

    private func binding(for address: String, default defaultValue: Bool) -> Binding<Bool> {
        return Binding(
            get: { viewModel.getValue(for: address, default: 0.0) != 0.0 },
            set: { newValue in viewModel.setValue(newValue ? 1.0 : 0.0, for: address) }
        )
    }
}
