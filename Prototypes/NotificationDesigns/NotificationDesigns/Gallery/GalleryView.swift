import SwiftUI

struct GalleryView: View {
    @State private var scenario = SampleScenario.meeting
    @State private var appearance = HarnessAppearance.light
    @State private var textSize = HarnessTextSize.standard
    @State private var layout = HarnessLayout.overview
    @State private var focusedDesign = NotificationDesign.centered

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperView()
                switch layout {
                case .overview: OverviewGrid(alert: scenario.alert, onSelect: focus)
                case .compare: compareList
                case .focus: focusPager
                }
            }
            .navigationTitle(scenario.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { controls }
        }
        .preferredColorScheme(appearance.colorScheme)
        .dynamicTypeSize(textSize.dynamicTypeSize)
        .onAppear(perform: applyLaunchArguments)
    }

    private var compareList: some View {
        ScrollView {
            LazyVStack(spacing: 22) {
                ForEach(NotificationDesign.allCases) { design in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(design.name)
                            .font(.footnote.weight(.semibold))
                            .padding(.leading, 8)
                        MockNotificationView(design: design, alert: scenario.alert, showsActions: false)
                    }
                    .id(design)
                    .onTapGesture { focus(on: design) }
                }
            }
            .padding(12)
        }
    }

    private var focusPager: some View {
        TabView(selection: $focusedDesign) {
            ForEach(NotificationDesign.allCases) { design in
                VStack(spacing: 12) {
                    Spacer(minLength: 0)
                    Text(design.name)
                        .font(.headline)
                    MockNotificationView(design: design, alert: scenario.alert)
                    Spacer(minLength: 48)
                }
                .padding(.horizontal, 12)
                .tag(design)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }

    @ToolbarContentBuilder private var controls: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Picker("Layout", selection: $layout) {
                ForEach(HarnessLayout.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu("Options", systemImage: "slider.horizontal.3") {
                Picker("Scenario", selection: $scenario) {
                    ForEach(SampleScenario.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                Picker("Appearance", selection: $appearance) {
                    ForEach(HarnessAppearance.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                Picker("Text Size", selection: $textSize) {
                    ForEach(HarnessTextSize.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
            }
        }
    }

    private func focus(on design: NotificationDesign) {
        focusedDesign = design
        layout = .focus
    }

    private func applyLaunchArguments() {
        let defaults = UserDefaults.standard
        if let value = defaults.string(forKey: "layout"), let match = HarnessLayout(rawValue: value) {
            layout = match
        }
        if let value = defaults.string(forKey: "scenario"), let match = SampleScenario(rawValue: value) {
            scenario = match
        }
        if let value = defaults.string(forKey: "appearance"), let match = HarnessAppearance(rawValue: value) {
            appearance = match
        }
        if let value = defaults.string(forKey: "textSize"), let match = HarnessTextSize(rawValue: value) {
            textSize = match
        }
        if let value = defaults.object(forKey: "design") as? String, let index = Int(value),
           let match = NotificationDesign(rawValue: index) {
            focusedDesign = match
            layout = .focus
        }
    }
}
