# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FaustSwiftUI is a Swift Package that dynamically renders SwiftUI controls from Faust DSP JSON UI metadata. It parses the JSON UI structures output by the Faust compiler and creates native SwiftUI widgets (sliders, knobs, buttons, bargraphs, etc.) with bi-directional value binding. Supports iOS 15+ and macOS 11+. No external dependencies.

## Build & Test

```bash
swift build
swift test
```

SwiftUI previews are available in Xcode via `FaustUIView_Preview` (in `FaustUIPreview.swift`).

## Architecture

The rendering pipeline flows: **JSON → FaustUI model → FaustUIView (recursive renderer) → individual widgets**.

- `FaustUI.swift` — Data model structs decoded from Faust JSON. `FaustUIType` enum defines widget types (vslider, hslider, checkbox, button, nentry, vbargraph, hbargraph) and container types (vgroup, hgroup, tgroup). `FaustUIMeta` carries style/unit/tooltip metadata. Items nest recursively.
- `FaustUIView.swift` — Generic SwiftUI view parameterized on `FaustUIValueBinding`. Recursively walks the item tree, dispatching to the correct widget based on type and style metadata (e.g. a slider with `knob` style renders as `FaustKnob`). Handles hidden items and group layout.
- `FaustUIWidgets.swift` — All widget implementations: `FaustVSlider`, `FaustHSlider`, `FaustKnob` (300° rotary), `FaustCheckbox`, `FaustButton`, `FaustNSwitch` (number entry), `FaustVBargraph`, `FaustHBargraph`. Each widget takes min/max/step/address and binds through the value binding protocol.
- `FaustUIViewModel.swift` — Default `FaustUIValueBinding` implementation. Stores parameter values as `[String: Double]` keyed by Faust address strings. Consumers can provide their own binding implementation via the protocol.
- `FaustUITheme.swift` — `FaustWidgetTheme` protocol and `DefaultTheme`. Theme is distributed via `FaustThemeManager` (ObservableObject).

## Incomplete Features

Menu, radio, LED, and numerical style modifiers are parsed but not rendered. Unit and scale metadata are parsed but not applied to widget display.
