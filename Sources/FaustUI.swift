// FaustUI.swift
// Data model representing JSON UI nodes from Faust

import Foundation

// MARK: - Enums

public enum FaustUIScale: String, Codable {
    case linear, log, exp
}

public enum FaustUIType: String, Codable {
    case vslider, hslider, nentry
    case checkbox, button
    case vgroup, hgroup, tgroup
    case hbargraph, vbargraph
}

// MARK: - Parsed Style

public struct FaustMenuOption: Equatable {
    public let label: String
    public let value: Double
}

public enum FaustParsedStyle: Equatable {
    case knob
    case led
    case numerical
    case menu(options: [FaustMenuOption])
    case radio(options: [FaustMenuOption])

    public init?(from string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        switch trimmed {
        case "knob": self = .knob
        case "led": self = .led
        case "numerical": self = .numerical
        default:
            if trimmed.hasPrefix("menu{") {
                self = .menu(options: Self.parseOptions(trimmed))
            } else if trimmed.hasPrefix("radio{") {
                self = .radio(options: Self.parseOptions(trimmed))
            } else {
                return nil
            }
        }
    }

    private static func parseOptions(_ s: String) -> [FaustMenuOption] {
        guard let start = s.firstIndex(of: "{"),
              let end = s.lastIndex(of: "}") else { return [] }
        let inner = s[s.index(after: start)..<end]
        return inner.split(separator: ";").compactMap { pair in
            let parts = pair.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { return nil }
            let label = parts[0].trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
            guard let value = Double(parts[1].trimmingCharacters(in: .whitespaces)) else { return nil }
            return FaustMenuOption(label: label, value: value)
        }
    }
}

// MARK: - Scale Mapping

public enum FaustScaleMapping {
    /// Convert normalized position (0-1) to parameter value
    public static func toValue(_ normalized: Double, min: Double, max: Double, scale: FaustUIScale) -> Double {
        let n = Swift.min(Swift.max(normalized, 0), 1)
        switch scale {
        case .linear:
            return min + n * (max - min)
        case .log:
            guard min > 0, max > 0 else { return min + n * (max - min) }
            return exp(log(min) + n * (log(max) - log(min)))
        case .exp:
            guard max > min else { return min }
            let k = log(max - min + 1)
            return min + (max - min) * (exp(n * k) - 1) / (exp(k) - 1)
        }
    }

    /// Convert parameter value to normalized position (0-1)
    public static func toNormalized(_ value: Double, min: Double, max: Double, scale: FaustUIScale) -> Double {
        switch scale {
        case .linear:
            guard max != min else { return 0 }
            return (value - min) / (max - min)
        case .log:
            guard min > 0, max > 0, value > 0 else {
                guard max != min else { return 0 }
                return (value - min) / (max - min)
            }
            return (log(value) - log(min)) / (log(max) - log(min))
        case .exp:
            guard max != min else { return 0 }
            let k = log(max - min + 1)
            return log(1 + (value - min) / (max - min) * (exp(k) - 1)) / k
        }
    }
}

// MARK: - Data Structures

public struct FaustUIMeta: Codable {
    public let style: String?
    public let unit: String?
    public let scale: FaustUIScale?
    public let tooltip: String?
    public let hidden: String?  /// NB "0" or "1" in json
}

public struct FaustUIJSON: Codable {
    public let ui: [FaustUI]?
}

public struct FaustUI: Codable, Identifiable {
    public let id: UUID = UUID()

    public let type: FaustUIType
    public let label: String
    public let varname: String?
    public let shortname: String?
    public let address: String?
    public let meta: [FaustUIMeta]?
    public let items: [FaustUI]?

    public let initValue: Double?
    public let min: Double?
    public let max: Double?
    public let step: Double?

    public init(
        type: FaustUIType,
        label: String,
        varname: String? = nil,
        shortname: String? = nil,
        address: String? = nil,
        meta: [FaustUIMeta]? = nil,
        items: [FaustUI]? = nil,
        initValue: Double? = nil,
        min: Double? = nil,
        max: Double? = nil,
        step: Double? = nil
    ) {
        self.type = type
        self.label = label
        self.varname = varname
        self.shortname = shortname
        self.address = address
        self.meta = meta
        self.items = items
        self.initValue = initValue
        self.min = min
        self.max = max
        self.step = step
    }

    enum CodingKeys: String, CodingKey {
        case type, label, varname, shortname, address, meta, items
        case initValue = "init"
        case min, max, step
    }

    // MARK: - Computed Metadata Accessors

    public var parsedStyle: FaustParsedStyle? {
        guard let meta = meta else { return nil }
        for entry in meta {
            if let styleStr = entry.style, let parsed = FaustParsedStyle(from: styleStr) {
                return parsed
            }
        }
        return nil
    }

    public var unit: String? {
        guard let meta = meta else { return nil }
        for entry in meta {
            if let unit = entry.unit { return unit }
        }
        return nil
    }

    public var scale: FaustUIScale {
        guard let meta = meta else { return .linear }
        for entry in meta {
            if let scale = entry.scale { return scale }
        }
        return .linear
    }

    public var tooltip: String? {
        guard let meta = meta else { return nil }
        for entry in meta {
            if let tooltip = entry.tooltip { return tooltip }
        }
        return nil
    }

    public var isHidden: Bool {
        guard let meta = meta else { return false }
        for entry in meta {
            if entry.hidden == "1" { return true }
        }
        return false
    }
}
