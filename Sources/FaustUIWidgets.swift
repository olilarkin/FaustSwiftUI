// FaustWidgets.swift

import SwiftUI

// MARK: - Helpers

private func valueString(_ value: Double, unit: String?) -> String {
    if let unit = unit {
        return String(format: "%.1f %@", value, unit)
    }
    return String(format: "%.1f", value)
}

extension View {
    @ViewBuilder
    func faustTooltip(_ tooltip: String?) -> some View {
        if let tooltip = tooltip {
            self.help(tooltip)
        } else {
            self
        }
    }
}

// MARK: - Checkbox

public struct FaustCheckbox: View {
    public let label: String
    public let address: String
    @Binding var value: Double
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    public init(label: String, address: String, value: Binding<Double>, tooltip: String? = nil) {
        self.label = label
        self.address = address
        _value = value
        self.tooltip = tooltip
    }

    public var body: some View {
        VStack {
            Toggle(isOn: Binding(
                get: { value > 0.5 },
                set: { value = $0 ? 1.0 : 0.0 }
            )) {
                Text(label.replacingOccurrences(of: "_", with: " "))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(minHeight: themeManager.theme.labelSize, maxHeight: themeManager.theme.labelSize * 2)
        }
        .padding(.leading, themeManager.theme.padding)
        .padding(.trailing, themeManager.theme.padding)
        .frame(height: themeManager.theme.labelSize)
        .faustTooltip(tooltip)
    }
}

// MARK: - Button

public struct FaustButton: View {
    public let label: String
    public let address: String
    @Binding var value: Double
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    public init(label: String, address: String, value: Binding<Double>, tooltip: String? = nil) {
        self.label = label
        self.address = address
        _value = value
        self.tooltip = tooltip
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                value = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    value = 0.0
                }
            }) {
                Text(label.replacingOccurrences(of: "_", with: " "))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding()
                    .cornerRadius(themeManager.theme.cornerRadius)
                    .frame(height: themeManager.theme.labelSize - 2)
            }
            .frame(height: themeManager.theme.labelSize)
        }
        .padding(.leading, themeManager.theme.padding)
        .padding(.trailing, themeManager.theme.padding)
        .padding(.top, themeManager.theme.padding)
        .padding(.bottom, themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}

// MARK: - VBargraph

public struct FaustVBargraph: View {
    public let label: String
    public let address: String
    public let min: Double
    public let max: Double
    @Binding var value: Double
    public let unit: String?
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    public init(label: String, address: String, min: Double, max: Double, value: Binding<Double>, unit: String? = nil, tooltip: String? = nil) {
        self.label = label
        self.address = address
        self.min = min
        self.max = max
        _value = value
        self.unit = unit
        self.tooltip = tooltip
    }

    public var body: some View {
        VStack(alignment: .center) {
            Text(label.replacingOccurrences(of: "_", with: " "))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(alignment: .center)

            VStack(alignment: .center, spacing: 0) {
                GeometryReader { geometry in
                    let percent = CGFloat((value - min) / (max - min))
                    ZStack(alignment: .bottom) {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        Rectangle().fill(Color.green)
                            .frame(height: geometry.size.height * percent)
                    }
                    .cornerRadius(themeManager.theme.cornerRadius)
                }
                .frame(width: 12.5)
                .frame(height: themeManager.theme.sliderSize)
            }

            HStack {
                Text(valueString(value, unit: unit))
                    .frame(height: themeManager.theme.labelSize)
                    .frame(minWidth: themeManager.theme.labelSize * 2, maxWidth: themeManager.theme.labelSize * 3)
                    .background(themeManager.theme.numboxBackgroundColor)
                    .foregroundColor(themeManager.theme.numboxTextColor)
                    .cornerRadius(themeManager.theme.cornerRadius)
            }
            .padding(.leading, themeManager.theme.padding)
            .padding(.trailing, themeManager.theme.padding)
        }
        .frame(width: themeManager.theme.labelSize * 2.5)
        .padding(.leading, themeManager.theme.padding)
        .padding(.trailing, themeManager.theme.padding)
        .padding(.top, themeManager.theme.padding)
        .padding(.bottom, themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}

// MARK: - HBargraph

public struct FaustHBargraph: View {
    public let label: String
    public let address: String
    public let min: Double
    public let max: Double
    @Binding var value: Double
    public let unit: String?
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    public init(label: String, address: String, min: Double, max: Double, value: Binding<Double>, unit: String? = nil, tooltip: String? = nil) {
        self.label = label
        self.address = address
        self.min = min
        self.max = max
        _value = value
        self.unit = unit
        self.tooltip = tooltip
    }

    @ViewBuilder
    private var render_label: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label.replacingOccurrences(of: "_", with: " "))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: themeManager.theme.labelSize)

            Text(valueString(value, unit: unit))
                .frame(height: themeManager.theme.labelSize)
                .frame(minWidth: themeManager.theme.labelSize * 2, maxWidth: themeManager.theme.labelSize * 3)
                .background(themeManager.theme.numboxBackgroundColor)
                .foregroundColor(themeManager.theme.numboxTextColor)
                .cornerRadius(themeManager.theme.cornerRadius)

            Spacer().frame(height: themeManager.theme.labelSize * 1)
        }
    }

    public var body: some View {
        HStack(alignment: .top) {
            render_label

            VStack(alignment: .center, spacing: 0) {
                Spacer().frame(height: themeManager.theme.labelSize)
                GeometryReader { geometry in
                    let percent = CGFloat((value - min) / (max - min))
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        Rectangle().fill(Color.green)
                            .frame(width: geometry.size.width * percent)
                    }
                    .cornerRadius(themeManager.theme.cornerRadius)
                }
                .frame(height: themeManager.theme.labelSize * 0.5)
            }
            .frame(height: themeManager.theme.labelSize * 2)
            .frame(width: themeManager.theme.sliderSize)
        }
        .frame(height: themeManager.theme.labelSize * 3)
        .frame(width: themeManager.theme.labelSize * 2 + themeManager.theme.sliderSize)
        .padding(.leading, themeManager.theme.padding)
        .padding(.trailing, themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}

// MARK: - NSwitch (Number Entry)

struct FaustNSwitch: View {
    public let label: String
    public let address: String
    let range: ClosedRange<Double>
    let step: Double
    @Binding var value: Double
    public let unit: String?
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    @State private var text: String

    public init(label: String, address: String, range: ClosedRange<Double>, step: Double, value: Binding<Double>, unit: String? = nil, tooltip: String? = nil) {
        self.label = label
        self.address = address
        self.range = range
        self.step = step
        _value = value
        self.unit = unit
        self.tooltip = tooltip
        _text = State(initialValue: String(value.wrappedValue))
    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(label.replacingOccurrences(of: "_", with: " "))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.center)
                    .frame(height: themeManager.theme.labelSize)

                HStack(spacing: 2) {
                    TextField("Enter a number", text: $text)
                        .onChange(of: text) { newValue in
                            var filtered = ""
                            var hasDecimalPoint = false

                            for (i, char) in newValue.enumerated() {
                                if char.isWholeNumber {
                                    filtered.append(char)
                                } else if char == "." && !hasDecimalPoint {
                                    if i == 0 || newValue[newValue.index(newValue.startIndex, offsetBy: i - 1)].isWholeNumber {
                                        filtered.append(char)
                                    } else {
                                        filtered = "0."
                                    }
                                    hasDecimalPoint = true
                                }
                            }

                            if filtered != newValue {
                                text = filtered
                            }

                            if let floatVal = Double(filtered) {
                                value = floatVal
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: themeManager.theme.labelSize)
                        .frame(minWidth: themeManager.theme.labelSize * 2, maxWidth: themeManager.theme.labelSize * 3)

                    if let unit = unit {
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
                    .frame(height: themeManager.theme.labelSize * 1)
            }
        }
        .frame(height: themeManager.theme.labelSize * 3)
        .frame(minWidth: themeManager.theme.labelSize * 2, maxWidth: themeManager.theme.labelSize * 3)
        .padding(.leading, themeManager.theme.padding)
        .padding(.trailing, themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}

// MARK: - HSlider

struct FaustHSlider: View {
    public let label: String
    public let address: String
    let range: ClosedRange<Double>
    let step: Double
    @Binding var value: Double
    public let unit: String?
    public let tooltip: String?
    public let scale: FaustUIScale
    @EnvironmentObject var themeManager: FaustThemeManager

    @State private var isDragging = false
    @GestureState private var dragOffset: CGSize = .zero

    public init(label: String, address: String, range: ClosedRange<Double>, step: Double, value: Binding<Double>, unit: String? = nil, tooltip: String? = nil, scale: FaustUIScale = .linear) {
        self.label = label
        self.address = address
        self.range = range
        self.step = step
        _value = value
        self.unit = unit
        self.tooltip = tooltip
        self.scale = scale
    }

    @ViewBuilder
    private var render_label: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label.replacingOccurrences(of: "_", with: " "))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: themeManager.theme.labelSize)

            Text(valueString(value, unit: unit))
                .frame(height: themeManager.theme.labelSize)
                .frame(minWidth: themeManager.theme.labelSize * 2, maxWidth: themeManager.theme.labelSize * 3)
                .background(themeManager.theme.numboxBackgroundColor)
                .foregroundColor(themeManager.theme.numboxTextColor)
                .cornerRadius(themeManager.theme.cornerRadius)

            Spacer()
                .frame(height: themeManager.theme.labelSize)
        }
    }

    public var body: some View {
        HStack(alignment: .center) {
            render_label

            VStack(spacing: 0) {
                if value < range.lowerBound || value > range.upperBound {
                    Text("Value out of range: \(value) \(range.lowerBound) \(range.upperBound)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .cornerRadius(0)
                } else {
                    GeometryReader { geo in
                        let height = geo.size.height * 0.75
                        let width = geo.size.width
                        let trackHeight = geo.size.height * 0.25
                        let handleWidth = trackHeight * 1.5
                        let normalized = CGFloat(FaustScaleMapping.toNormalized(value, min: range.lowerBound, max: range.upperBound, scale: scale))
                        let handleX = normalized * (width - handleWidth)

                        ZStack(alignment: .leading) {
                            // Track
                            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: trackHeight)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, (height - trackHeight) / 2)

                            // Handle
                            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                .fill(isDragging ? Color.accentColor : Color.primary.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                        .stroke(Color.accentColor, lineWidth: 1.5)
                                )
                                .frame(width: handleWidth, height: height)
                                .position(x: handleX + handleWidth / 2, y: height * 0.67)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { gesture in
                                            isDragging = true
                                            let location = gesture.location.x
                                            let clamped = min(max(location - handleWidth / 2, 0), width - handleWidth)
                                            let percent = Double(clamped / (width - handleWidth))
                                            let raw = FaustScaleMapping.toValue(percent, min: range.lowerBound, max: range.upperBound, scale: scale)
                                            let stepped = ((raw - range.lowerBound) / step).rounded() * step + range.lowerBound
                                            value = min(max(stepped, range.lowerBound), range.upperBound)
                                        }
                                        .onEnded { _ in
                                            isDragging = false
                                        }
                                )
                        }
                        .onTapGesture(count: 2) {
                            let mid = (range.lowerBound + range.upperBound) / 2
                            value = (mid / step).rounded() * step
                        }
                    }
                    .frame(height: themeManager.theme.labelSize * 2)
                    .frame(width: themeManager.theme.sliderSize)
                }
            }
        }
        .frame(height: themeManager.theme.labelSize * 3)
        .frame(width: themeManager.theme.labelSize * 2 + themeManager.theme.sliderSize)
        .padding(.leading, themeManager.theme.padding)
        .padding(.trailing, themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}

// MARK: - VSlider

struct FaustVSlider: View {
    public let label: String
    public let address: String
    let range: ClosedRange<Double>
    let step: Double
    @Binding var value: Double
    public let unit: String?
    public let tooltip: String?
    public let scale: FaustUIScale
    @EnvironmentObject var themeManager: FaustThemeManager

    @State private var isDragging = false
    @GestureState private var dragOffset: CGSize = .zero

    public init(label: String, address: String, range: ClosedRange<Double>, step: Double, value: Binding<Double>, unit: String? = nil, tooltip: String? = nil, scale: FaustUIScale = .linear) {
        self.label = label
        self.address = address
        self.range = range
        self.step = step
        _value = value
        self.unit = unit
        self.tooltip = tooltip
        self.scale = scale
    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center) {
                Text(label.replacingOccurrences(of: "_", with: " "))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.center)

                if value < range.lowerBound || value > range.upperBound {
                    Text("Value out of range: \(value) \(range.lowerBound) \(range.upperBound)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .cornerRadius(0)
                } else {
                    GeometryReader { geo in

                        let width = geo.size.width * 0.75
                        let height = geo.size.height
                        let trackWidth = geo.size.width * 0.25
                        let handleHeight = trackWidth * 1.5
                        let normalized = CGFloat(FaustScaleMapping.toNormalized(value, min: range.lowerBound, max: range.upperBound, scale: scale))
                        let handleY = (1.0 - normalized) * (height - handleHeight)

                        ZStack(alignment: .top) {
                            // Track
                            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: trackWidth)
                                .frame(maxHeight: .infinity)
                                .padding(.horizontal, (width - trackWidth) / 2)

                            // Handle
                            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                .fill(isDragging ? Color.accentColor : Color.primary.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                        .stroke(Color.accentColor, lineWidth: 2)
                                )
                                .frame(width: width, height: handleHeight)
                                .position(x: width * 0.67, y: handleY + handleHeight / 2)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { gesture in
                                            isDragging = true
                                            let location = gesture.location.y
                                            let clamped = min(max(location - handleHeight / 2, 0), height - handleHeight)
                                            let percent = 1.0 - (clamped / (height - handleHeight))
                                            let raw = FaustScaleMapping.toValue(Double(percent), min: range.lowerBound, max: range.upperBound, scale: scale)
                                            let stepped = ((raw - range.lowerBound) / step).rounded() * step + range.lowerBound
                                            value = min(max(stepped, range.lowerBound), range.upperBound)
                                        }
                                        .onEnded { _ in
                                            isDragging = false
                                        }
                                )
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) {
                            let mid = (range.lowerBound + range.upperBound) / 2
                            value = (mid / step).rounded() * step
                        }
                    }
                    .frame(width: themeManager.theme.labelSize * 2, height: themeManager.theme.sliderSize)

                    HStack {
                        Text(valueString(value, unit: unit))
                            .frame(height: themeManager.theme.labelSize)
                            .frame(minWidth: themeManager.theme.labelSize * 2, maxWidth: themeManager.theme.labelSize * 4)
                            .background(themeManager.theme.numboxBackgroundColor)
                            .foregroundColor(themeManager.theme.numboxTextColor)
                            .cornerRadius(themeManager.theme.cornerRadius)
                    }
                    .padding(.leading, themeManager.theme.padding)
                    .padding(.trailing, themeManager.theme.padding)
                }
            }
        }
        .padding(themeManager.theme.padding)
        .frame(width: themeManager.theme.labelSize * 4)
        .faustTooltip(tooltip)
    }
}

// MARK: - Knob

struct FaustKnob: View {
    public let label: String
    public let address: String
    public let range: ClosedRange<Double>
    public let step: Double
    @Binding var value: Double
    public let unit: String?
    public let tooltip: String?
    public let scale: FaustUIScale
    @EnvironmentObject var themeManager: FaustThemeManager

    @State private var isDragging = false

    private let thickness: CGFloat = 6.0
    private let totalAngle: Angle = .degrees(300)
    private let startAngle: Angle = .degrees(120) // leaves 60deg gap at bottom

    public init(label: String, address: String, range: ClosedRange<Double>, step: Double, value: Binding<Double>, unit: String? = nil, tooltip: String? = nil, scale: FaustUIScale = .linear) {
        self.label = label
        self.address = address
        self.range = range
        self.step = step
        _value = value
        self.unit = unit
        self.tooltip = tooltip
        self.scale = scale
    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center) {
                Text(label.replacingOccurrences(of: "_", with: " "))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.center)

                GeometryReader { geometry in

                    let size = min(geometry.size.width, geometry.size.height)
                    let center = CGPoint(x: size / 2, y: size / 2)
                    let radius = (size - thickness) / 2
                    let offset = Angle(degrees: 1)

                    let normalized = CGFloat(FaustScaleMapping.toNormalized(value, min: range.lowerBound, max: range.upperBound, scale: scale))

                    let angle = (totalAngle.radians - offset.radians) * Double(normalized)
                    let endAngle = startAngle + offset + Angle(radians: angle)

                    let height = geometry.size.height

                    ZStack {
                        // Background fill
                        Circle()
                            .fill(Color.gray.opacity(0.2))

                        // Arc
                        Path { path in
                            path.addArc(
                                center: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false
                            )
                        }
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: thickness, lineCap: .butt))
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                #if os(macOS)
                                if !isDragging {
                                    isDragging = true
                                    NSCursor.hide()
                                }
                                #else
                                isDragging = true
                                #endif

                                let location = gesture.location.y
                                let clamped = min(max(location, 0), height)
                                let percent = 1.0 - (clamped / height)
                                let raw = FaustScaleMapping.toValue(Double(percent), min: range.lowerBound, max: range.upperBound, scale: scale)
                                let stepped = ((raw - range.lowerBound) / step).rounded() * step + range.lowerBound
                                value = min(max(stepped, range.lowerBound), range.upperBound)
                            }
                            .onEnded { _ in
                                isDragging = false
                                #if os(macOS)
                                NSCursor.unhide()
                                #endif
                            }
                    )
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: themeManager.theme.labelSize * 2, maxHeight: themeManager.theme.labelSize * 2)

                HStack {
                    Text(valueString(value, unit: unit))
                        .frame(height: themeManager.theme.labelSize)
                        .frame(minWidth: themeManager.theme.labelSize * 2, maxWidth: themeManager.theme.labelSize * 4)
                        .background(themeManager.theme.numboxBackgroundColor)
                        .foregroundColor(themeManager.theme.numboxTextColor)
                        .cornerRadius(themeManager.theme.cornerRadius)
                }
                .padding(.leading, themeManager.theme.padding)
                .padding(.trailing, themeManager.theme.padding)
            }
        }
        .padding(themeManager.theme.padding)
        .frame(width: themeManager.theme.labelSize * 4)
        .faustTooltip(tooltip)
    }
}

// MARK: - Menu (dropdown for nentry)

struct FaustMenu: View {
    public let label: String
    public let address: String
    public let options: [FaustMenuOption]
    @Binding var value: Double
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.replacingOccurrences(of: "_", with: " "))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: themeManager.theme.labelSize)

            Picker(label, selection: $value) {
                ForEach(options, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .labelsHidden()
        }
        .padding(.leading, themeManager.theme.padding)
        .padding(.trailing, themeManager.theme.padding)
        .padding(.top, themeManager.theme.padding)
        .padding(.bottom, themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}

// MARK: - Radio (segmented picker for nentry)

struct FaustRadio: View {
    public let label: String
    public let address: String
    public let options: [FaustMenuOption]
    @Binding var value: Double
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.replacingOccurrences(of: "_", with: " "))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: themeManager.theme.labelSize)

            Picker(label, selection: $value) {
                ForEach(options, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .padding(.leading, themeManager.theme.padding)
        .padding(.trailing, themeManager.theme.padding)
        .padding(.top, themeManager.theme.padding)
        .padding(.bottom, themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}

// MARK: - LED (indicator for bargraph)

struct FaustLED: View {
    public let label: String
    public let address: String
    public let min: Double
    public let max: Double
    @Binding var value: Double
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    private var ledColor: Color {
        let normalized = (value - min) / (max - min)
        if normalized <= 0 {
            return Color.gray.opacity(0.3)
        } else if normalized < 0.6 {
            return .green
        } else if normalized < 0.85 {
            return .yellow
        } else {
            return .red
        }
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label.replacingOccurrences(of: "_", with: " "))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: themeManager.theme.labelSize)

            Circle()
                .fill(ledColor)
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )
                .frame(width: themeManager.theme.labelSize * 1.5, height: themeManager.theme.labelSize * 1.5)
        }
        .padding(themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}

// MARK: - Numerical (value-only display for sliders/bargraphs)

struct FaustNumerical: View {
    public let label: String
    public let address: String
    public let range: ClosedRange<Double>
    public let step: Double
    @Binding var value: Double
    public let unit: String?
    public let tooltip: String?
    @EnvironmentObject var themeManager: FaustThemeManager

    public var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label.replacingOccurrences(of: "_", with: " "))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: themeManager.theme.labelSize)

            HStack(spacing: 4) {
                Button(action: {
                    let newVal = value - step
                    value = max(newVal, range.lowerBound)
                }) {
                    Image(systemName: "minus")
                        .frame(width: themeManager.theme.labelSize, height: themeManager.theme.labelSize)
                }
                .buttonStyle(.borderless)

                Text(valueString(value, unit: unit))
                    .frame(height: themeManager.theme.labelSize)
                    .frame(minWidth: themeManager.theme.labelSize * 2, maxWidth: themeManager.theme.labelSize * 4)
                    .background(themeManager.theme.numboxBackgroundColor)
                    .foregroundColor(themeManager.theme.numboxTextColor)
                    .cornerRadius(themeManager.theme.cornerRadius)

                Button(action: {
                    let newVal = value + step
                    value = min(newVal, range.upperBound)
                }) {
                    Image(systemName: "plus")
                        .frame(width: themeManager.theme.labelSize, height: themeManager.theme.labelSize)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(themeManager.theme.padding)
        .faustTooltip(tooltip)
    }
}
